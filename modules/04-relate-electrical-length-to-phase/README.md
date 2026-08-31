# P04 — Relate Electrical Length to Phase

**Track:** RF and Microwave Measurement  
**Phase 1:** Waves and impedance  
**Status:** implemented

## Guiding question

What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?

## Physical mental model

For an ideal matched line with phase velocity `v_p`, physical length `l`, and frequency `f`,

`theta = beta*l = 2*pi*f*l/v_p = 2*pi*l/lambda_g`.

`theta` is positive electrical length. This module uses the `exp(+j*omega*t)` convention, so the
one-way through transfer is `H = exp(-j*theta)` and its unwrapped phase shift is `-theta`. A line
one guided quarter wavelength long therefore delays the waveform by one quarter period and rotates
the through phasor by `-90 degrees`.

The model uses `v_p = velocity_factor*c_0`. P03 established that source/load impedance conditions
matter; P04 independently assumes that both ports terminate a real-`Z_0` line in `Z_0`, suppressing
reflections so propagation phase can be isolated. If a reflection exists as in P01, it travels to
the load and back, accumulating twice the one-way phase. The transparent base-MATLAB model
intentionally omits mismatch, loss, and dispersion so the length-to-phase mechanism remains visible.

## Required learning flow

1. Read the sign convention and make one prediction.
2. View the deterministic guided-quarter-wave baseline.
3. Sweep frequency while physical length and velocity factor stay fixed.
4. Read the mechanism, reset, and sweep physical length at fixed frequency.
5. Compare unwrapped and wrapped phase.
6. Break the assumption that one wrapped phase contains the whole-cycle count.
7. Run independent numerical checks and give a two-sentence teach-back.

## Model boundary

Both ports terminate a real characteristic impedance `Z_0`; the path is lossless and nondispersive
with a constant velocity factor. Within that model, `|H| = 1`, delay is `l/v_p`, and unwrapped phase
is linear in both frequency and length. Real cable loss changes magnitude, dispersion changes phase
slope, and mismatch adds incident and reflected waves; those effects are named limitations rather
than silently folded into this lesson.

## Run the module

From the repository root, use `launch_lesson("P04")`. The launch asks one prediction and shows only
the deterministic baseline. Continue one Live Editor section at a time in `experiment.m`: Sweep 1,
the mechanism in `lesson.md`, reset, Sweep 2, then the deliberately broken wrapped-phase case.
Open `interactive.m` to move frequency and physical length independently. Run
`run_module_checks("P04")` for the executable checks.

The repository evidence is static unless a separate MATLAB-runtime record explicitly says otherwise.
