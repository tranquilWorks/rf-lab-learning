# P03 — Match a Load to a Source

**Track:** RF and Microwave Measurement  
**Phase 1:** Waves and impedance  
**Status:** implemented

## Guiding question

What inputs, observable effects, and failure modes matter when you match a Load to a Source?

## Physical mental model

A source can be represented by an open-circuit RMS voltage in series with a complex impedance
`Z_s = R_s + jX_s`. The load receives the most available power when

`Z_L = conj(Z_s) = R_s - jX_s`.

For `Z_L = R_L + jX_L`, the delivered fraction of available power is

`tau = 4 R_s R_L / |Z_s + Z_L|^2 = 1 - |Gamma_m|^2`.

Both conditions matter: the resistances must be equal and the reactances must cancel. Copying a
complex source impedance into the load leaves residual reactance and loses delivered power.

This compounds on P01's reflection coefficient and P02's power-ratio decibels. When the source
impedance is real, `Gamma_m` reduces to the P01 form. P02 then converts `tau` into transfer dB or
mismatch loss without changing the matching physics.

## Required learning flow

1. Establish a deterministic baseline.
2. Show at least two complementary plots or views.
3. Expose meaningful parameters as MATLAB controls or clearly editable Live Editor variables.
4. Sweep two parameters independently.
5. Include one deliberately broken or misleading case.
6. Ask one observation question at a time.
7. Finish with a teach-back and a deterministic check.

## Implementation contract

The completed module owns these files:

- `lesson.m` — notebook-style MATLAB sections (`%%`) and concise narrative.
- `interactive.m` — `uifigure` controls, plots, and immediate feedback.
- `model.m` — deterministic calculations separated from presentation.
- `experiment.m` — reproducible baseline, sweeps, and broken case.
- `lesson.md` — tutor-facing explanation and misconceptions.
- `walkthrough.md` — expected observations in order.
- `checks.md` and `run_checks.m` — conceptual and numerical completion checks.

Prefer base MATLAB. Optional toolbox comparisons may be added only after the underlying operation is visible.

## Run the module

From the repository root, use `launch_lesson("P03")`. The launch asks one prediction and shows only
the deterministic conjugate-match baseline. Continue by running one Live Editor section at a time
in `experiment.m`: Sweep 1, read its mechanism in `lesson.md`, reset, Sweep 2, then the deliberately
broken case. Open `interactive.m` to move load resistance and load reactance independently, and run
`run_module_checks("P03")` for the executable checks.

The implementation uses transparent base-MATLAB arithmetic and fixed-size plots. Repository
evidence is static unless a separate MATLAB-runtime record explicitly says otherwise.
