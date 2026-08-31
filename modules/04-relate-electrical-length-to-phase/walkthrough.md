# Walkthrough: Relate Electrical Length to Phase

Follow one visual transition at a time.

1. Read the guiding question: What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?
2. Make the one prediction in `lesson.m`, then view only the baseline. Name GHz, mm, Mm/s, ps, degrees, and the dimensionless transfer phasor.
3. Confirm that one guided quarter wavelength delays the signal `250 ps` and rotates the one-way through phasor by `-90 degrees`.
4. Run only Sweep 1. Change frequency while physical length and velocity factor remain fixed; observe linear unwrapped phase and constant delay.
5. Read the mechanism in `lesson.md`. Use `phi = -360*f*tau` to explain the changed view and the wrapped-phase jump.
6. Return to the baseline, then run only Sweep 2. Change physical length at fixed frequency; explain why delay and unwrapped phase both grow linearly.
7. Open `interactive.m`. Move one slider, explain the waveform and phase changes, then reset before moving the other slider.
8. Reset again before running only the Broken case and toggling `Break: trust wrapped phase alone`. Identify the missing whole-cycle symptom.
9. Reset, run `run_module_checks("P04")`, and answer the interpretation questions in `checks.md`.
10. Give a two-sentence teach-back: length/frequency/velocity mechanism first, wrapped-phase failure and recovery second.

Expected broken-case observation: `lambda_g/4` and `5*lambda_g/4` both read `-90 degrees` after
wrapping, even though their delays differ by one full period. A phase-only absolute-length estimate
therefore misses one guided wavelength.
