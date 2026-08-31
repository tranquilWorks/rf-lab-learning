# Walkthrough: Match a Load to a Source

Follow one visual transition at a time.

1. Read the guiding question: What inputs, observable effects, and failure modes matter when you match a Load to a Source?
2. Make the one prediction in `lesson.m`, then view only the baseline. Name `V RMS`, `mA RMS`, `mW`, `dBm`, `ohms`, and the dimensionless mismatch coordinate.
3. Confirm that `50 - j50 ohms` cancels the source reactance and delivers `5 mW`, the maximum available power.
4. Run only Sweep 1. Change load resistance while reactance remains canceled; observe the power peak at `R_L = 50 ohms`.
5. Read the inequality in `lesson.md`. Use its resistance-error term to explain the changed view and why the peak occurs at `R_L = 50 ohms`.
6. Return to the baseline, then run only Sweep 2. Change load reactance while resistance stays fixed; use the reactance-error term to explain symmetry around `X_L = -50 ohms`.
7. Open `interactive.m`. Move one load slider, explain the power and `Gamma_m` changes, then reset before moving the other slider.
8. Reset again before running only the Broken case and toggling `Break: copy source reactance`. Identify the nonzero `X_s + X_L` symptom and its `3.0103 dB` loss.
9. Reset, run `run_module_checks("P03")`, and answer the interpretation questions in `checks.md`.
10. Give a two-sentence teach-back: conjugate-match mechanism first, delivered-power consequence second.

Expected broken-case observation: `Z_L = Z_s = 50 + j50 ohms` leaves `+100 ohms` net reactance,
so only half of the available power reaches the load even though resistance and impedance magnitude
appear matched.
