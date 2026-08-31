from __future__ import annotations

import json
import math
import os
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
P03_FOLDER = ROOT / "modules/03-match-a-load-to-a-source"
GUIDING_QUESTION = (
    "What inputs, observable effects, and failure modes matter when you match "
    "a Load to a Source?"
)


def reference_model(
    source_voltage_rms: float,
    source_resistance_ohm: float,
    source_reactance_ohm: float,
    load_resistance_ohm: float,
    load_reactance_ohm: float,
) -> dict[str, complex | float]:
    source_impedance = complex(source_resistance_ohm, source_reactance_ohm)
    load_impedance = complex(load_resistance_ohm, load_reactance_ohm)
    total_impedance = source_impedance + load_impedance
    current = source_voltage_rms / total_impedance
    load_power_w = abs(current) ** 2 * load_resistance_ohm
    available_power_w = source_voltage_rms**2 / (4 * source_resistance_ohm)
    transfer_ratio = (
        4 * source_resistance_ohm * load_resistance_ohm / abs(total_impedance) ** 2
    )
    gamma_m = (load_impedance - source_impedance.conjugate()) / total_impedance
    return {
        "current": current,
        "load_voltage": current * load_impedance,
        "load_power_w": load_power_w,
        "available_power_w": available_power_w,
        "transfer_ratio": transfer_ratio,
        "gamma_m": gamma_m,
        "net_reactance_ohm": source_reactance_ohm + load_reactance_ohm,
    }


class P03ModuleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))
        cls.module = next(module for module in cls.manifest["modules"] if module["id"] == "P03")
        cls.text = {
            path.name: path.read_text(encoding="utf-8")
            for path in P03_FOLDER.iterdir()
            if path.is_file()
        }

    def test_manifest_identity_and_complete_artifact_set_are_permanent(self):
        self.assertEqual(self.module["number"], 3)
        self.assertEqual(self.module["title"], "Match a Load to a Source")
        self.assertEqual(self.module["guiding_question"], GUIDING_QUESTION)
        self.assertEqual(self.module["phase"], 1)
        self.assertEqual(self.module["folder"], "modules/03-match-a-load-to-a-source")
        self.assertEqual(self.module["prerequisites"], ["P02"])
        self.assertEqual(self.module["status"], "implemented")
        self.assertNotEqual(self.module["evidence_level"], "none")

        prerequisite = next(module for module in self.manifest["modules"] if module["id"] == "P02")
        self.assertEqual(prerequisite["status"], "implemented")

        required = {
            "README.md",
            "lesson.m",
            "model.m",
            "experiment.m",
            "interactive.m",
            "lesson.md",
            "walkthrough.md",
            "checks.md",
            "run_checks.m",
            "p03_show_baseline.m",
        }
        self.assertTrue(required <= self.text.keys())

    def test_cli_check_routes_p03_to_the_public_matlab_check_runner(self):
        environment = os.environ.copy()
        environment["PYTHONDONTWRITEBYTECODE"] = "1"
        checked = subprocess.run(
            [str(ROOT / "bin/learn"), "check", "P03"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            env=environment,
            timeout=10,
        )
        self.assertEqual(checked.returncode, 0, checked.stderr)
        self.assertEqual(checked.stderr, "")
        self.assertEqual(
            checked.stdout,
            "Run in MATLAB: run_module_checks('P03')\n",
        )

    def test_model_exposes_conjugate_match_equations_without_presentation(self):
        model = self.text["model.m"]
        compact = re.sub(r"\s+", "", model)
        for equation in (
            "sourceImpedanceOhm=sourceResistanceOhm+1j*sourceReactanceOhm;",
            "loadImpedanceOhm=loadResistanceOhm+1j*loadReactanceOhm;",
            "conjugateMatchOhm=conj(sourceImpedanceOhm);",
            "currentA=sourceVoltageRms/totalImpedanceOhm;",
            "loadPowerW=currentRmsA^2*loadResistanceOhm;",
            "availablePowerW=sourceVoltageRms^2/(4*sourceResistanceOhm);",
            "powerTransferRatio=4*sourceResistanceOhm*loadResistanceOhm/abs(totalImpedanceOhm)^2;",
            "powerWaveGamma=(loadImpedanceOhm-conj(sourceImpedanceOhm))/totalImpedanceOhm;",
            "powerTransferDb=10*log10(powerTransferRatio);",
            "mismatchLossDb=-powerTransferDb;",
            "loadPowerDbm=10*log10(loadPowerW/1e-3);",
        ):
            self.assertIn(equation, compact)

        for validator in (
            "mustBeReal",
            "mustBeFinite",
            "mustBeNonnegative",
            "mustBePositive",
            "mustBeGreaterThanOrEqual",
            "mustBeLessThanOrEqual",
        ):
            self.assertIn(validator, model)
        for presentation_call in ("figure(", "plot(", "uifigure(", "disp(", "fprintf("):
            self.assertNotIn(presentation_call, model)

    def test_reference_arithmetic_limits_and_malformed_inputs_are_retained(self):
        matched = reference_model(1, 50, 50, 50, -50)
        self.assertAlmostEqual(matched["current"].real, 0.01, places=14)
        self.assertAlmostEqual(matched["current"].imag, 0, places=14)
        self.assertAlmostEqual(matched["load_voltage"].real, 0.5, places=14)
        self.assertAlmostEqual(matched["load_voltage"].imag, -0.5, places=14)
        self.assertAlmostEqual(matched["load_power_w"], 5e-3, places=14)
        self.assertAlmostEqual(matched["available_power_w"], 5e-3, places=14)
        self.assertAlmostEqual(matched["transfer_ratio"], 1, places=14)
        self.assertAlmostEqual(abs(matched["gamma_m"]), 0, places=14)
        self.assertAlmostEqual(10 * math.log10(5), 6.989700043360188, places=14)

        low_resistance = reference_model(1, 50, 50, 25, -50)
        high_resistance = reference_model(1, 50, 50, 100, -50)
        self.assertAlmostEqual(low_resistance["transfer_ratio"], 8 / 9, places=14)
        self.assertAlmostEqual(
            low_resistance["transfer_ratio"], high_resistance["transfer_ratio"], places=14
        )

        low_reactance = reference_model(1, 50, 50, 50, -100)
        high_reactance = reference_model(1, 50, 50, 50, 0)
        self.assertAlmostEqual(low_reactance["transfer_ratio"], 0.8, places=14)
        self.assertAlmostEqual(
            low_reactance["transfer_ratio"], high_reactance["transfer_ratio"], places=14
        )

        broken = reference_model(1, 50, 50, 50, 50)
        self.assertAlmostEqual(broken["load_power_w"], 2.5e-3, places=14)
        self.assertAlmostEqual(broken["transfer_ratio"], 0.5, places=14)
        self.assertAlmostEqual(broken["gamma_m"].real, 0.5, places=14)
        self.assertAlmostEqual(broken["gamma_m"].imag, 0.5, places=14)
        self.assertAlmostEqual(-10 * math.log10(broken["transfer_ratio"]), 3.010299956639812, places=14)

        for point in (matched, low_resistance, high_resistance, low_reactance, high_reactance, broken):
            self.assertAlmostEqual(
                point["transfer_ratio"],
                point["load_power_w"] / point["available_power_w"],
                places=14,
            )
            self.assertAlmostEqual(
                point["transfer_ratio"], 1 - abs(point["gamma_m"]) ** 2, places=14
            )

        short_circuit = reference_model(1, 50, 50, 0, 0)
        open_circuit = reference_model(1, 50, 50, 1e12, -50)
        self.assertEqual(short_circuit["load_power_w"], 0)
        self.assertEqual(short_circuit["transfer_ratio"], 0)
        self.assertEqual(abs(short_circuit["load_voltage"]), 0)
        self.assertLess(abs(open_circuit["current"]), 1.1e-12)
        self.assertLess(open_circuit["load_power_w"], 1.1e-12)
        self.assertAlmostEqual(abs(open_circuit["load_voltage"]), 1, places=9)

        large_envelope_edge = reference_model(1e6, 1e-9, 1e12, 1e-9, -1e12)
        self.assertGreater(abs(large_envelope_edge["current"]), 4e14)
        self.assertGreater(abs(large_envelope_edge["load_voltage"]), 4e26)
        self.assertTrue(math.isfinite(large_envelope_edge["load_power_w"]))
        self.assertAlmostEqual(large_envelope_edge["transfer_ratio"], 1, places=14)

        checks = self.text["run_checks.m"]
        for expected in (
            "tau must equal P_L/P_av.",
            "tau must equal 1 - |Gamma_m|^2.",
            "3.010299956639812",
            "6.020599913279624",
            "isinf(shortCircuit.loadPowerDbm)",
            "isinf(shortCircuit.mismatchLossDb)",
            "shortCircuit.loadImpedanceOhm == 0",
            "shortCircuit.loadVoltageRms == 0",
            "source voltage below supported envelope",
            "source resistance above supported envelope",
            "load reactance below supported envelope",
            "Supported large-value endpoints must keep derived linear metrics finite.",
            "The accepted-boundary stress case must exercise large finite derived values.",
            "Supported small-value endpoints must keep derived linear metrics finite.",
            "P03 checks passed.",
        ):
            self.assertIn(expected, checks)
        self.assertGreaterEqual(checks.count("assert("), 30)
        self.assertGreaterEqual(checks.count("mustThrow(@() model("), 12)

    def test_experiment_has_baseline_two_independent_sweeps_and_one_broken_case(self):
        experiment = self.text["experiment.m"]
        baseline_view = self.text["p03_show_baseline.m"]
        lower = experiment.lower()
        self.assertTrue(experiment.startswith("%% P03 deterministic baseline\n"))
        self.assertGreaterEqual(experiment.count("%%"), 4)
        self.assertEqual(lower.count("%% sweep 1"), 1)
        self.assertEqual(lower.count("%% sweep 2"), 1)
        self.assertEqual(lower.count("%% broken case"), 1)
        self.assertIn("baseline = p03_show_baseline;", experiment)
        self.assertIn("loadResistanceValues = [10 25 50 100 250]", experiment)
        self.assertIn("loadReactanceValues = [-150 -100 -50 0 50]", experiment)
        self.assertIn("loadResistanceOhm,-sourceReactanceOhm", experiment)
        self.assertIn("loadResistanceOhm,sourceReactanceOhm", experiment)
        self.assertNotIn("close all", lower)
        self.assertNotIn("clc", lower)
        self.assertGreaterEqual(lower.count("figure("), 3)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("figure("), 4)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("xlabel("), 5)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("ylabel("), 7)
        self.assertIn("fprintf(", experiment + baseline_view)
        self.assertGreaterEqual(lower.count("assert("), 7)
        for unit in ("V RMS", "mA RMS", "mW", "dBm", "ohms", "dB"):
            self.assertIn(unit, experiment + baseline_view)

    def test_interactive_controls_support_reset_and_the_broken_conjugation(self):
        interactive = self.text["interactive.m"]
        for marker in (
            "uifigure(",
            "uiaxes(",
            "Load resistance R_L (ohms)",
            "Load reactance X_L (ohms)",
            "Break: copy source reactance",
            "Reset conjugate-match baseline",
            "ValueChangingFcn",
            "ValueChangedFcn",
            "modelFcn = @model",
            "reactanceSlider.Enable = 'off'",
            "reactanceSlider.Enable = 'on'",
            "linspace(1,200,161)",
            "linspace(0,2*pi,201)",
        ):
            self.assertIn(marker, interactive)
        self.assertEqual(interactive.count("uislider("), 2)
        self.assertIn("function resetBaseline", interactive)
        self.assertIn("This is not lossless efficiency".lower(), interactive.lower())

    def test_tutor_text_is_concept_first_and_compounds_on_p01_and_p02(self):
        for name in ("README.md", "lesson.m", "lesson.md", "walkthrough.md", "checks.md"):
            with self.subTest(name=name):
                self.assertIn(GUIDING_QUESTION, self.text[name])

        combined = "\n".join(
            self.text[name]
            for name in ("README.md", "lesson.m", "lesson.md", "walkthrough.md", "checks.md")
        )
        for concept in (
            "P01",
            "P02",
            "conjugate",
            "available power",
            "RMS",
            "10 log10",
            "Gamma_m",
            "teach-back",
            "one prediction",
        ):
            self.assertIn(concept.lower(), combined.lower())
        self.assertIn("p03_show_baseline;", self.text["lesson.m"])
        self.assertIn(
            "observe its changed view, then read the mechanism", self.text["lesson.m"]
        )
        self.assertTrue(self.text["lesson.m"].rstrip().endswith("p03_show_baseline;"))
        walkthrough = self.text["walkthrough.md"]
        self.assertLess(
            walkthrough.index("Run only Sweep 1"), walkthrough.index("Read the inequality")
        )
        self.assertLess(
            walkthrough.index("Read the inequality"), walkthrough.index("run only Sweep 2")
        )
        self.assertIn("Reset again before", walkthrough)
        self.assertNotIn("experiment;", self.text["lesson.m"])
        self.assertNotIn("interactive;", self.text["lesson.m"])

    def test_no_placeholder_opaque_toolbox_state_or_unbounded_work_remains(self):
        combined = "\n".join(self.text.values()).lower()
        for placeholder in (
            "curriculum-scaffolded",
            "not implemented",
            "activate its governed implementation batch",
            "planned learner sequence",
            "planned concept loop",
        ):
            self.assertNotIn(placeholder, combined)

        matlab = "\n".join(
            self.text[name]
            for name in (
                "model.m",
                "experiment.m",
                "interactive.m",
                "lesson.m",
                "p03_show_baseline.m",
                "run_checks.m",
            )
        ).lower()
        for opaque_call in (
            "smithplot(",
            "sparameters(",
            "rfplot(",
            "matchingnetwork(",
            "rational(",
        ):
            self.assertNotIn(opaque_call, matlab)
        for statement in ("global", "persistent", "while", "parfor"):
            self.assertIsNone(re.search(rf"(?m)^\s*{statement}\b", matlab))
        for stateful_or_unbounded_call in (
            "timer(",
            "pause(",
            "rand(",
            "randn(",
            "rng(",
            "webread(",
            "readtable(",
            "fileread(",
            "fopen(",
            "save(",
            "system(",
        ):
            self.assertNotIn(stateful_or_unbounded_call, matlab)
        for global_side_effect in ("close all", "clc;"):
            self.assertNotIn(global_side_effect, matlab)
        for name, content in self.text.items():
            with self.subTest(resource=name):
                self.assertLess(len(content.encode("utf-8")), 24_000)

    def test_text_format_resource_bounds_isolation_compatibility_and_recovery(self):
        for path in P03_FOLDER.iterdir():
            if not path.is_file():
                continue
            raw = path.read_bytes()
            with self.subTest(path=path.name):
                self.assertNotIn(b"\r", raw)
                self.assertTrue(raw.endswith(b"\n"))
                self.assertFalse(raw.endswith(b"\n\n"))

        model = self.text["model.m"].lower()
        interactive = self.text["interactive.m"]
        self.assertNotIn("addpath(", model)
        self.assertNotIn("path(", model)
        self.assertIn("modelFcn = @model", interactive)
        self.assertIn("brokenCheck.Value = false", interactive)
        self.assertIn("resistanceSlider.Value = baselineLoadResistanceOhm", interactive)
        self.assertIn("reactanceSlider.Value = baselineLoadReactanceOhm", interactive)


if __name__ == "__main__":
    unittest.main()
