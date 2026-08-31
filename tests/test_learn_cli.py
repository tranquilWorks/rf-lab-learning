from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LearnCliTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))

    def make_fixture(self, temporary: str) -> Path:
        fixture = Path(temporary) / "repo"
        shutil.copytree(ROOT / "bin", fixture / "bin")
        shutil.copytree(ROOT / "curriculum", fixture / "curriculum")
        manifest = json.loads((fixture / "curriculum/modules.json").read_text(encoding="utf-8"))
        for module in manifest["modules"]:
            source = ROOT / module["folder"]
            target = fixture / module["folder"]
            target.mkdir(parents=True, exist_ok=True)
            for name in ("README.md", "lesson.md", "walkthrough.md", "checks.md"):
                shutil.copy2(source / name, target / name)
        return fixture

    def run_cli_in_fixture(self, fixture: Path, *args: str) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment["PYTHONDONTWRITEBYTECODE"] = "1"
        return subprocess.run(
            [str(fixture / "bin/learn"), *args],
            cwd=fixture,
            text=True,
            capture_output=True,
            env=environment,
            timeout=10,
        )

    def run_cli(self, *args: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as temporary:
            return self.run_cli_in_fixture(self.make_fixture(temporary), *args)

    def test_status_and_list(self):
        status = self.run_cli("status")
        self.assertEqual(status.returncode, 0, status.stderr)
        implemented = sum(module["status"] == "implemented" for module in self.manifest["modules"])
        self.assertIn(f"24 total, {implemented} implemented", status.stdout)
        listing = self.run_cli("list")
        self.assertEqual(listing.returncode, 0, listing.stderr)
        self.assertEqual(len([line for line in listing.stdout.splitlines() if line.strip()]), 24)

    def test_implemented_modules_start_and_current_scaffold_refuses(self):
        reference = self.run_cli("start", "P01")
        self.assertEqual(reference.returncode, 0, reference.stderr)
        self.assertIn("Guiding question:", reference.stdout)

        p02 = self.run_cli("start", "P02")
        self.assertEqual(p02.returncode, 0, p02.stderr)
        self.assertIn("Convert Power and Voltage into Decibels", p02.stdout)

        scaffolded = next(
            (module for module in self.manifest["modules"] if module["status"] == "scaffolded"),
            None,
        )
        if scaffolded is not None:
            scaffold = self.run_cli("start", scaffolded["id"])
            self.assertEqual(scaffold.returncode, 2)
            self.assertIn("Activate its governed implementation batch", scaffold.stdout)

    def test_refused_start_preserves_the_resumable_module(self):
        with tempfile.TemporaryDirectory() as temporary:
            fixture = self.make_fixture(temporary)
            manifest_path = fixture / "curriculum/modules.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            refused_module = next(module for module in manifest["modules"] if module["id"] == "P03")
            refused_module["status"] = "scaffolded"
            manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

            started = self.run_cli_in_fixture(fixture, "start", "P02")
            self.assertEqual(started.returncode, 0, started.stderr)

            refused = self.run_cli_in_fixture(fixture, "start", refused_module["id"])
            self.assertEqual(refused.returncode, 2)

            resumed = self.run_cli_in_fixture(fixture, "continue")
            self.assertEqual(resumed.returncode, 0, resumed.stderr)
            self.assertIn("P02 — Convert Power and Voltage into Decibels", resumed.stdout)

            state = json.loads((fixture / ".learning/progress.json").read_text(encoding="utf-8"))
            self.assertEqual(state["current"], "P02")


if __name__ == "__main__":
    unittest.main()
