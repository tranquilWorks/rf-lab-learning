from __future__ import annotations

import json
import math
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
P02_FOLDER = ROOT / "modules/02-convert-power-and-voltage-into-decibels"
GUIDING_QUESTION = (
    "What inputs, observable effects, and failure modes matter when you convert "
    "Power and Voltage into Decibels?"
)


class P02ModuleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))
        cls.module = next(module for module in cls.manifest["modules"] if module["id"] == "P02")
        cls.text = {
            path.name: path.read_text(encoding="utf-8")
            for path in P02_FOLDER.iterdir()
            if path.is_file()
        }

    def test_manifest_identity_and_complete_artifact_set_are_permanent(self):
        self.assertEqual(self.module["number"], 2)
        self.assertEqual(self.module["title"], "Convert Power and Voltage into Decibels")
        self.assertEqual(self.module["guiding_question"], GUIDING_QUESTION)
        self.assertEqual(self.module["phase"], 1)
        self.assertEqual(self.module["folder"], "modules/02-convert-power-and-voltage-into-decibels")
        self.assertEqual(self.module["prerequisites"], ["P01"])
        self.assertEqual(self.module["status"], "implemented")
        self.assertNotEqual(self.module["evidence_level"], "none")

        prerequisite = next(module for module in self.manifest["modules"] if module["id"] == "P01")
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
            "p02_show_baseline.m",
        }
        self.assertTrue(required <= self.text.keys())

    def test_model_exposes_the_governing_equations_without_presentation(self):
        model = self.text["model.m"]
        compact = re.sub(r"\s+", "", model)
        for equation in (
            "powerDb=10*log10(powerRatio);",
            "voltageDb=20*log10(voltageRatio);",
            "powerFromVoltageW=voltageRms^2/resistanceOhm;",
            "referencePowerFromVoltageW=referenceVoltageRms^2/referenceResistanceOhm;",
            "voltagePowerRatio=powerFromVoltageW/referencePowerFromVoltageW;",
            "voltagePowerDb=10*log10(voltagePowerRatio);",
            "impedanceCorrectionDb=10*log10(referenceResistanceOhm/resistanceOhm);",
        ):
            self.assertIn(equation, compact)

        for validator in ("mustBeReal", "mustBeFinite", "mustBeNonnegative", "mustBePositive"):
            self.assertIn(validator, model)
        for presentation_call in ("figure(", "plot(", "uifigure(", "disp(", "fprintf("):
            self.assertNotIn(presentation_call, model)

    def test_known_values_limiting_cases_and_malformed_inputs_are_checked(self):
        self.assertAlmostEqual(10 * math.log10(2), 3.010299956639812, places=14)
        self.assertAlmostEqual(20 * math.log10(2), 6.020599913279624, places=14)
        self.assertAlmostEqual(10 * math.log10(50 / 75), -1.760912590556813, places=14)

        checks = self.text["run_checks.m"]
        for expected in (
            "3.010299956639812",
            "6.020599913279624",
            "1.760912590556813",
            "isinf(zeroSignal.powerDb)",
            "isinf(zeroSignal.voltageDb)",
            "Multiplicative power ratios must add in dB.",
            "P02 checks passed.",
        ):
            self.assertIn(expected, checks)
        self.assertGreaterEqual(checks.count("assert("), 15)
        self.assertGreaterEqual(checks.count("mustThrow(@() model("), 10)

    def test_experiment_has_baseline_two_independent_sweeps_and_one_broken_case(self):
        experiment = self.text["experiment.m"]
        baseline_view = self.text["p02_show_baseline.m"]
        lower = experiment.lower()
        self.assertGreaterEqual(experiment.count("%%"), 4)
        self.assertEqual(lower.count("%% sweep 1"), 1)
        self.assertEqual(lower.count("%% sweep 2"), 1)
        self.assertEqual(lower.count("%% broken case"), 1)
        self.assertIn("powerRatios", experiment)
        self.assertIn("voltageRatios", experiment)
        self.assertIn("brokenResistanceOhm = 75", experiment)
        self.assertTrue(experiment.startswith("%% P02 deterministic baseline\n"))
        self.assertIn("baseline = p02_show_baseline;", experiment)
        self.assertNotIn("close all", lower)
        self.assertNotIn("clc", lower)
        self.assertGreaterEqual(lower.count("figure("), 3)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("figure("), 4)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("xlabel("), 2)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("ylabel("), 4)
        self.assertIn("fprintf(", experiment + baseline_view)
        self.assertGreaterEqual(lower.count("assert("), 7)
        for unit in ("mW", "V RMS", "ohms", "dB"):
            self.assertIn(unit, experiment + baseline_view)

    def test_interactive_controls_support_reset_and_the_broken_assumption(self):
        interactive = self.text["interactive.m"]
        for marker in (
            "uifigure(",
            "uiaxes(",
            "Independent power ratio P/P_ref",
            "Independent RMS-voltage ratio V/V_ref",
            "Signal resistance (ohms)",
            "Break: ignore impedance",
            "Reset baseline",
            "ValueChangingFcn",
            "ValueChangedFcn",
            "modelFcn = @model",
        ):
            self.assertIn(marker, interactive)
        self.assertGreaterEqual(interactive.count("uislider("), 3)
        self.assertIn("logspace(-1,1,161)", interactive)
        self.assertIn("independent measurement inputs", interactive.lower())

    def test_tutor_text_is_concept_first_and_compounds_on_p01(self):
        for name in ("README.md", "lesson.m", "lesson.md", "walkthrough.md", "checks.md"):
            with self.subTest(name=name):
                self.assertIn(GUIDING_QUESTION, self.text[name])

        combined = "\n".join(
            self.text[name] for name in ("README.md", "lesson.m", "lesson.md", "walkthrough.md", "checks.md")
        )
        for concept in ("P01", "10 log10", "20 log10", "impedance", "teach-back"):
            self.assertIn(concept.lower(), combined.lower())
        self.assertIn("one prediction", combined.lower())
        self.assertIn("p02_show_baseline;", self.text["lesson.m"])
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
            for name in ("model.m", "experiment.m", "interactive.m", "lesson.m", "run_checks.m")
        ).lower()
        for opaque_call in ("pow2db(", "mag2db(", "db2pow(", "db2mag(", "rfplot("):
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
            "save(",
        ):
            self.assertNotIn(stateful_or_unbounded_call, matlab)
        for global_side_effect in ("close all", "clc;"):
            self.assertNotIn(global_side_effect, matlab)
        for name, content in self.text.items():
            with self.subTest(resource=name):
                self.assertLess(len(content.encode("utf-8")), 24_000)


if __name__ == "__main__":
    unittest.main()
