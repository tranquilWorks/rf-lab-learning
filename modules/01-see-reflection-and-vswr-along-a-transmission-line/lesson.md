# Lesson: See Reflection and VSWR Along a Transmission Line

## Guiding question

What inputs, observable effects, and failure modes matter when you see Reflection and VSWR Along a Transmission Line?

## Mental model

A load mismatch launches a reflected wave. The forward and reflected waves add differently along the line, creating position-dependent voltage and current.

## What to manipulate

Use `interactive.m`. Change one lever at a time before combining effects.

## First observation

Move the load resistance toward Z0 and watch the reflected-wave magnitude collapse. Add reactance and watch the reflection phase rotate even when its magnitude is similar.

## Common mistakes

- VSWR describes mismatch magnitude, not the sign or phase of the load error.
- A cable does not remove a reflection; it rotates the reflection phase and adds loss in real hardware.
- A perfect 50-ohm source does not guarantee a matched load.

## Completion standard

The learner can explain the baseline, identify what each lever changes, diagnose the deliberately broken case, and pass `run_checks.m`.
