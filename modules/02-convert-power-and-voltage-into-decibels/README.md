# P02 — Convert Power and Voltage into Decibels

**Track:** RF and Microwave Measurement  
**Phase 1:** Waves and impedance  
**Status:** implemented

## Guiding question

What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?

## Physical mental model

A decibel is a logarithm of a ratio, not a physical unit by itself. For power,

`L_P = 10 log10(P/P_ref)`.

For an RMS-voltage ratio,

`L_V = 20 log10(V/V_ref)`.

The factor changes because power is proportional to voltage squared. Treating `L_V` as a power
change also assumes the signal and reference impedances are equal. When they are not, the missing
term is `10 log10(R_ref/R)`.

This compounds on P01: load impedance was already necessary to interpret voltage and reflection;
it is also necessary when voltage is used to infer power.

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

From the repository root, use `launch_lesson("P02")`, or add this folder to the MATLAB path and run
`lesson`. The launch shows only the baseline; continue by running the Sweep 1, Sweep 2, and Broken
case Live Editor sections of `experiment.m`, followed by `interactive`. Run
`run_module_checks("P02")` for the executable numerical checks.

The module uses base MATLAB, Live Editor sections, and `uifigure` controls. Its retained repository
evidence is static unless a separate MATLAB-runtime record says otherwise.
