from __future__ import annotations

import json
import math
import os
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
P04_FOLDER = ROOT / "modules/04-relate-electrical-length-to-phase"
GUIDING_QUESTION = (
    "What inputs, observable effects, and failure modes matter when you relate "
    "Electrical Length to Phase?"
)
SPEED_OF_LIGHT_MPS = 299_792_458.0


def reference_model(frequency_hz: float, physical_length_m: float, velocity_factor: float) -> dict[str, complex | float]:
    phase_velocity_mps = velocity_factor * SPEED_OF_LIGHT_MPS
    wavelength_m = phase_velocity_mps / frequency_hz
    delay_s = physical_length_m / phase_velocity_mps
    electrical_cycles = frequency_hz * delay_s
    electrical_length_rad = 2 * math.pi * electrical_cycles
    electrical_length_deg = 360 * electrical_cycles
    unwrapped_phase_deg = -electrical_length_deg
    principal_deg = electrical_length_deg % 360
    if math.isclose(principal_deg, 0, abs_tol=1e-10) or math.isclose(
        principal_deg, 360, abs_tol=1e-10
    ):
        principal_deg = 0.0
    wrapped_phase_deg = (-principal_deg + 180) % 360 - 180
    return {
        "phase_velocity_mps": phase_velocity_mps,
        "wavelength_m": wavelength_m,
        "delay_s": delay_s,
        "electrical_cycles": electrical_cycles,
        "electrical_length_rad": electrical_length_rad,
        "electrical_length_deg": electrical_length_deg,
        "unwrapped_phase_deg": unwrapped_phase_deg,
        "wrapped_phase_deg": wrapped_phase_deg,
        "transfer_phasor": complex(
            math.cos(electrical_length_rad), -math.sin(electrical_length_rad)
        ),
        "principal_equivalent_length_m": principal_deg / 360 * wavelength_m,
        "phase_slope_deg_per_hz": -360 * delay_s,
    }


class P04ModuleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / "curriculum/modules.json").read_text(encoding="utf-8"))
        cls.module = next(module for module in cls.manifest["modules"] if module["id"] == "P04")
        cls.text = {
            path.name: path.read_text(encoding="utf-8")
            for path in P04_FOLDER.iterdir()
            if path.is_file()
        }

    def test_manifest_identity_and_complete_artifact_set_are_permanent(self):
        self.assertEqual(self.module["number"], 4)
        self.assertEqual(self.module["title"], "Relate Electrical Length to Phase")
        self.assertEqual(self.module["guiding_question"], GUIDING_QUESTION)
        self.assertEqual(self.module["phase"], 1)
        self.assertEqual(
            self.module["folder"], "modules/04-relate-electrical-length-to-phase"
        )
        self.assertEqual(self.module["prerequisites"], ["P03"])
        self.assertEqual(self.module["status"], "implemented")
        self.assertNotEqual(self.module["evidence_level"], "none")

        prerequisite = next(
            module for module in self.manifest["modules"] if module["id"] == "P03"
        )
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
            "p04_show_baseline.m",
        }
        self.assertTrue(required <= self.text.keys())

    def test_cli_check_routes_p04_to_the_public_matlab_check_runner(self):
        environment = os.environ.copy()
        environment["PYTHONDONTWRITEBYTECODE"] = "1"
        checked = subprocess.run(
            [str(ROOT / "bin/learn"), "check", "P04"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            env=environment,
            timeout=10,
        )
        self.assertEqual(checked.returncode, 0, checked.stderr)
        self.assertEqual(checked.stderr, "")
        self.assertEqual(checked.stdout, "Run in MATLAB: run_module_checks('P04')\n")

    def test_model_exposes_length_delay_phase_equations_without_presentation(self):
        model = self.text["model.m"]
        compact = re.sub(r"\s+", "", model)
        for equation in (
            "speedOfLightMps=299792458;",
            "phaseVelocityMps=velocityFactor*speedOfLightMps;",
            "wavelengthM=phaseVelocityMps/frequencyHz;",
            "propagationDelayS=physicalLengthM/phaseVelocityMps;",
            "electricalCycles=frequencyHz*propagationDelayS;",
            "electricalLengthRad=2*pi*electricalCycles;",
            "electricalLengthDeg=360*electricalCycles;",
            "unwrappedTransferPhaseDeg=-electricalLengthDeg;",
            "transferPhasor=exp(-1j*electricalLengthRad);",
            "wrappedTransferPhaseDeg=mod(-principalElectricalLengthDeg+180,360)-180;",
            "phaseEquivalentLengthM=principalElectricalLengthDeg/360*wavelengthM;",
            "phaseSlopeDegPerHz=-360*propagationDelayS;",
        ):
            self.assertIn(equation, compact)

        for validator in (
            "mustBeReal",
            "mustBeFinite",
            "mustBeNonnegative",
            "mustBeGreaterThanOrEqual",
            "mustBeLessThanOrEqual",
        ):
            self.assertIn(validator, model)
        for presentation_call in ("figure(", "plot(", "uifigure(", "disp(", "fprintf("):
            self.assertNotIn(presentation_call, model)

    def test_reference_arithmetic_limits_broken_case_and_malformed_inputs_are_retained(self):
        velocity_factor = 0.66
        frequency_hz = 1e9
        wavelength_m = velocity_factor * SPEED_OF_LIGHT_MPS / frequency_hz
        quarter_length_m = wavelength_m / 4
        baseline = reference_model(frequency_hz, quarter_length_m, velocity_factor)

        self.assertAlmostEqual(baseline["phase_velocity_mps"], 197_863_022.28, places=6)
        self.assertAlmostEqual(baseline["wavelength_m"], 0.19786302228, places=14)
        self.assertAlmostEqual(quarter_length_m, 0.04946575557, places=14)
        self.assertAlmostEqual(baseline["delay_s"], 250e-12, places=20)
        self.assertAlmostEqual(baseline["electrical_cycles"], 0.25, places=14)
        self.assertAlmostEqual(baseline["electrical_length_deg"], 90, places=14)
        self.assertAlmostEqual(baseline["unwrapped_phase_deg"], -90, places=14)
        self.assertAlmostEqual(baseline["wrapped_phase_deg"], -90, places=14)
        self.assertAlmostEqual(baseline["transfer_phasor"].real, 0, places=14)
        self.assertAlmostEqual(baseline["transfer_phasor"].imag, -1, places=14)
        self.assertAlmostEqual(
            baseline["phase_slope_deg_per_hz"], -360 * baseline["delay_s"], places=20
        )

        zero = reference_model(frequency_hz, 0, velocity_factor)
        half = reference_model(frequency_hz, wavelength_m / 2, velocity_factor)
        full = reference_model(frequency_hz, wavelength_m, velocity_factor)
        self.assertEqual(zero["delay_s"], 0)
        self.assertEqual(zero["wrapped_phase_deg"], 0)
        self.assertAlmostEqual(half["unwrapped_phase_deg"], -180, places=13)
        self.assertAlmostEqual(half["wrapped_phase_deg"], -180, places=13)
        self.assertAlmostEqual(full["unwrapped_phase_deg"], -360, places=13)
        self.assertAlmostEqual(full["wrapped_phase_deg"], 0, places=13)
        self.assertAlmostEqual(full["principal_equivalent_length_m"], 0, places=13)

        below_half = reference_model(
            frequency_hz, (0.5 - 1e-6) * wavelength_m, velocity_factor
        )
        above_half = reference_model(
            frequency_hz, (0.5 + 1e-6) * wavelength_m, velocity_factor
        )
        self.assertLess(below_half["wrapped_phase_deg"], -179.99)
        self.assertGreater(above_half["wrapped_phase_deg"], 179.99)
        self.assertGreater(
            above_half["wrapped_phase_deg"] - below_half["wrapped_phase_deg"], 359.98
        )
        self.assertLess(
            abs(above_half["transfer_phasor"] - below_half["transfer_phasor"]), 2e-5
        )

        long_path = reference_model(frequency_hz, 5 * quarter_length_m, velocity_factor)
        self.assertAlmostEqual(long_path["delay_s"], 1.25e-9, places=20)
        self.assertAlmostEqual(long_path["unwrapped_phase_deg"], -450, places=13)
        self.assertAlmostEqual(long_path["wrapped_phase_deg"], -90, places=13)
        self.assertAlmostEqual(
            abs(long_path["transfer_phasor"] - baseline["transfer_phasor"]), 0, places=13
        )
        self.assertAlmostEqual(
            long_path["principal_equivalent_length_m"], quarter_length_m, places=13
        )
        self.assertAlmostEqual(
            5 * quarter_length_m - long_path["principal_equivalent_length_m"],
            wavelength_m,
            places=13,
        )

        slower = reference_model(frequency_hz, quarter_length_m, 0.33)
        self.assertAlmostEqual(slower["delay_s"], 2 * baseline["delay_s"], places=20)
        self.assertAlmostEqual(
            slower["electrical_length_deg"], 2 * baseline["electrical_length_deg"], places=13
        )

        checks = self.text["run_checks.m"]
        for expected in (
            "The 1 GHz guided wavelength must be 0.19786302228 m.",
            "A guided quarter wavelength must delay 1 GHz by 250 ps.",
            "Wrapped through phase must stay in the half-open interval [-180,180).",
            "A half wavelength must have H = -1.",
            "Crossing the half-wave branch cut must expose the wrapped-phase jump.",
            "The physical phasor must remain continuous across the wrapped-phase branch cut.",
            "One wavelength must wrap to zero phase.",
            "Adding one guided wavelength must preserve the transfer phasor.",
            "A reflected quarter-wave path must accumulate -180 degrees on its round trip.",
            "Wrapped phase alone must alias 5 lambda_g/4 to lambda_g/4.",
            "A frequency-sweep finite difference must recover delay from phase slope.",
            "Supported upper endpoints must keep every derived metric finite.",
            "frequency below supported envelope",
            "length above supported envelope",
            "velocity factor above unity",
            "negative velocity factor",
            "P04 checks passed.",
        ):
            self.assertIn(expected, checks)
        self.assertGreaterEqual(checks.count("assert("), 45)
        self.assertGreaterEqual(checks.count("mustThrow(@() model("), 18)

    def test_experiment_has_baseline_two_independent_sweeps_and_one_broken_case(self):
        experiment = self.text["experiment.m"]
        baseline_view = self.text["p04_show_baseline.m"]
        lower = experiment.lower()
        self.assertTrue(experiment.startswith("%% P04 deterministic baseline\n"))
        self.assertGreaterEqual(experiment.count("%%"), 4)
        self.assertEqual(lower.count("%% sweep 1"), 1)
        self.assertEqual(lower.count("%% sweep 2"), 1)
        self.assertEqual(lower.count("%% broken case"), 1)
        self.assertIn("baseline = p04_show_baseline;", experiment)
        self.assertIn("frequencyValuesGHz = [0.5 1.0 1.5 2.0 2.5]", experiment)
        self.assertIn("lengthValuesM = quarterWaveLengthM*[0 1 2 3 4]", experiment)
        self.assertIn("actualLongPath = model(frequencyHz,5*guidedQuarterWaveM", experiment)
        self.assertIn("naiveLengthM = actualLongPath.phaseEquivalentLengthM", experiment)
        transition_sections = {
            section.splitlines()[0]: section
            for section in re.split(r"(?m)^%% ", experiment)[1:]
        }
        for heading in (
            "Sweep 1 - frequency lever at fixed physical length",
            "Sweep 2 - physical-length lever at fixed frequency",
            "Broken case - treat wrapped phase as total phase",
        ):
            with self.subTest(clean_workspace_section=heading):
                section = transition_sections[heading]
                self.assertIn("velocityFactor = 0.66;", section)
                self.assertIn("speedOfLightMps = 299792458;", section)
        self.assertNotIn("close all", lower)
        self.assertNotIn("clc", lower)
        self.assertGreaterEqual(lower.count("figure("), 3)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("figure("), 4)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("xlabel("), 5)
        self.assertGreaterEqual((experiment + baseline_view).lower().count("ylabel("), 8)
        self.assertIn("fprintf(", experiment + baseline_view)
        self.assertGreaterEqual(lower.count("assert("), 9)
        for unit in ("GHz", "mm", "Mm/s", "ps", "degrees"):
            self.assertIn(unit, experiment + baseline_view)

    def test_interactive_controls_support_reset_and_broken_phase_interpretation(self):
        interactive = self.text["interactive.m"]
        for marker in (
            "uifigure(",
            "uiaxes(",
            "Frequency (GHz)",
            "Physical line length (mm)",
            "Break: trust wrapped phase alone",
            "Reset quarter-wave baseline",
            "ValueChangingFcn",
            "ValueChangedFcn",
            "modelFcn = @model",
            "linspace(0.5,2.5,161)",
            "linspace(0,2/out.frequencyHz,401)",
            "wrapped phase alone has no whole-cycle count",
            "effectiveLengthMm = 5*baselineLengthMm",
            "frequencySlider.Value = effectiveFrequencyGHz",
            "lengthSlider.Value = effectiveLengthMm",
            "frequencySlider.Enable = 'off'",
            "lengthSlider.Enable = 'off'",
            "frequencySlider.Enable = 'on'",
            "lengthSlider.Enable = 'on'",
        ):
            self.assertIn(marker, interactive)
        self.assertEqual(interactive.count("uislider("), 2)
        self.assertGreaterEqual(interactive.count("uiaxes("), 3)
        self.assertIn("function resetBaseline", interactive)
        self.assertIn("brokenCheck.Value = false", interactive)
        self.assertIn("frequencySlider.Value = baselineFrequencyGHz", interactive)
        self.assertIn("lengthSlider.Value = baselineLengthMm", interactive)

    def test_tutor_text_is_concept_first_and_compounds_on_prerequisites(self):
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
            "P03",
            "characteristic impedance",
            "matched",
            "velocity factor",
            "guided wavelength",
            "propagation delay",
            "wrapped phase",
            "round trip",
            "teach-back",
            "one prediction",
        ):
            self.assertIn(concept.lower(), combined.lower())
        self.assertIn("p04_show_baseline;", self.text["lesson.m"])
        self.assertIn(
            "observe its changed view, then read the mechanism", self.text["lesson.m"]
        )
        self.assertTrue(self.text["lesson.m"].rstrip().endswith("p04_show_baseline;"))
        walkthrough = self.text["walkthrough.md"]
        self.assertLess(
            walkthrough.index("Run only Sweep 1"), walkthrough.index("Read the mechanism")
        )
        self.assertLess(
            walkthrough.index("Read the mechanism"), walkthrough.index("run only Sweep 2")
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
                "p04_show_baseline.m",
                "run_checks.m",
            )
        ).lower()
        for opaque_call in (
            "physconst(",
            "wrapto180(",
            "unwrap(",
            "sparameters(",
            "rfplot(",
            "phasedelay(",
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

    def test_text_format_resource_bounds_isolation_compatibility_and_recovery(self):
        for path in P04_FOLDER.iterdir():
            if not path.is_file():
                continue
            raw = path.read_bytes()
            with self.subTest(path=path.name):
                self.assertNotIn(b"\r", raw)
                self.assertTrue(raw.endswith(b"\n"))
                self.assertFalse(raw.endswith(b"\n\n"))
                self.assertLess(len(raw), 24_000)

        model = self.text["model.m"].lower()
        interactive = self.text["interactive.m"]
        self.assertNotIn("addpath(", model)
        self.assertNotIn("path(", model)
        self.assertNotIn("figure(", model)
        self.assertIn("modelFcn = @model", interactive)
        self.assertIn("brokenCheck.Value = false", interactive)
        self.assertIn("frequencySlider.Value = baselineFrequencyGHz", interactive)
        self.assertIn("lengthSlider.Value = baselineLengthMm", interactive)
        self.assertIn("frequencyGridGHz = linspace(0.5,2.5,161)", interactive)
        self.assertIn("timeS = linspace(0,2/out.frequencyHz,401)", interactive)


if __name__ == "__main__":
    unittest.main()
