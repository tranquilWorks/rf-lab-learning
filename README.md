# RF and Microwave Measurement

A MATLAB-first, Khan-Academy-style learning track with 24 guided modules.

Each implemented module combines:

- a concise lesson and physical mental model;
- MATLAB `%%` notebook cells;
- deterministic plots;
- actual UI sliders, spinners, or dropdowns;
- two parameter sweeps;
- one deliberately broken case;
- executable numerical checks;
- a tutor protocol that asks one observation question at a time.

## Start

From a shell:

```bash
./bin/learn start
./bin/learn start P01
./bin/learn start P02
./bin/learn start P03
./bin/learn start P04
./bin/learn list
./bin/learn status
```

On Windows PowerShell:

```powershell
python .\bin\learn.py start
```

In MATLAB:

```matlab
launch_lesson("P01")
launch_lesson("P02")
launch_lesson("P03")
launch_lesson("P04")
run_module_checks("P01")
run_module_checks("P02")
run_module_checks("P03")
run_module_checks("P04")
```

After a module's MATLAB checks pass and the learner gives a short teach-back, record completion with
an explicit attestation:

```bash
./bin/learn complete P04 --checks-passed --teach-back "<your explanation>"
```

`P01` is the reference implementation. `P02` through `P04` are governed follow-on lessons covering
decibels, conjugate source/load matching, and the relationship between electrical length and phase.
The `status` field in `curriculum/modules.json` is the current source of truth: implemented modules
are runnable, while scaffolded modules remain intentionally non-runnable until their bounded batch
is verified.

## Module layout

```text
modules/01-example/
├── README.md
├── lesson.m
├── model.m
├── experiment.m
├── interactive.m
├── lesson.md
├── walkthrough.md
├── checks.md
└── run_checks.m
```

## Learning contract

The flow is always:

> question → mental model → baseline → manipulate levers → observe plots → break an assumption → explain → check → teach back

This repository is compatible with the same tutor/build split used by `dsp-radar_learning`.
