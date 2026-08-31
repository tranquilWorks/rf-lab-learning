# Lesson: Relate Electrical Length to Phase

## Guiding question

What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?

## Connection to P01, P02, and P03

P03 showed why source/load impedance conditions matter for power transfer, including a complex
conjugate match. That is not automatically a reflectionless transmission-line termination. P04
independently assumes a line with real characteristic impedance `Z_0` whose source and load ports
are each terminated in `Z_0`. The ideal line then has unity magnitude, so P02 would call its
magnitude change `0 dB`, while propagation still changes phase. P01's reflected wave crosses the
line twice, so moving a reflection reference plane by length `l` rotates it by `-2*beta*l`; the
matched one-way path in this module rotates by only `-beta*l`.

## Mental model and sign convention

Let the phase velocity be `v_p = velocity_factor*c_0`, with guided wavelength
`lambda_g = v_p/f`. The propagation delay and positive electrical length are

`tau = l/v_p`

and

`theta = beta*l = 2*pi*f*tau = 2*pi*l/lambda_g`.

This module uses the `exp(+j*omega*t)` phasor convention. A forward matched wave has

`H = exp(-j*theta)`,

so the unwrapped through phase is `phi = -theta`. The time-domain statement is the same:
`v_out(t) = v_in(t-tau)`. A positive delay makes the output lag.

## One prediction

Before viewing the baseline, predict the phase of a 1 GHz signal after one guided quarter wavelength
of a line with velocity factor `0.66`.

## What to observe

The guided wavelength is `197.863 mm`, so the baseline length is `49.466 mm`. Its delay is `250 ps`,
its electrical length is `90 degrees`, and its through transfer is `H = -j`, a `-90 degree` lag.
Magnitude remains one because the model is matched and lossless.

In Sweep 1, only frequency changes. Delay stays `250 ps`, but phase grows linearly because
`phi = -360*f*tau` degrees. The wrapped trace jumps by a cycle even though the unwrapped trace is
continuous. Reset before Sweep 2. There, only physical length changes: both delay and unwrapped
phase grow linearly, while zero and one guided wavelength share the same wrapped `0 degree` reading.

## Deliberately broken case

The broken case measures a path `5*lambda_g/4` long at one frequency. Its actual delay is `1.25 ns`
and its unwrapped through phase is `-450 degrees`, but an instrument-style wrapped reading is only
`-90 degrees`—the same as a `lambda_g/4` path. Calling the shortest principal-phase equivalent the
actual length produces `lambda_g/4` and misses one whole guided wavelength.

The violated assumption is that a single wrapped phase contains an absolute cycle count. Recover
delay from an unwrapped frequency sweep or phase slope, or supply an independent length/delay bound.

## Common mistakes

- Calling the negative through-phase shift the electrical length. `theta = beta*l` is positive;
  the sign of `H` follows the declared phasor convention.
- Using free-space wavelength when the line has a velocity factor below one.
- Mixing degrees and radians in `exp(-j*theta)`.
- Treating wrapped phase in `[-180,180)` as unwrapped phase.
- Applying the one-way `-beta*l` result to a reflected wave that makes a round trip and accumulates
  `-2*beta*l`.
- Inferring phase only from length while ignoring frequency or propagation velocity.
- Applying the constant-velocity result to a dispersive line without checking phase slope.

## Completion standard

Run `run_module_checks("P04")`, diagnose the wrapped-phase alias, answer the interpretation
questions, and give a two-sentence teach-back: governing mechanism first, recognizable failure
symptom and recovery second.
