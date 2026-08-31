# Checks: Relate Electrical Length to Phase

## Guiding question

What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?

## Numerical and limiting-case checks

Run:

```matlab
run_module_checks("P04")
```

The executable checks independently cover the 1 GHz guided-quarter-wave baseline; the identities
`theta = 2*pi*f*l/v_p = 2*pi*f*tau`, `H = exp(-j*theta)`, and
`d(phi_deg)/df = -360*tau`; zero-, quarter-, half-, and full-wavelength limits; frequency, length,
and velocity-factor scaling; one-way versus round-trip phase; the `5*lambda_g/4` wrapped-phase
alias; accepted-envelope endpoints; and malformed input.

The scalar calculation envelope is `1 kHz` to `100 GHz`, `0` to `1000 m`, and velocity factor
`0.1` through `1`. These broad finite bounds keep every derived value and fixed-size presentation
array bounded. Interactive controls use the much narrower ranges `0.5` to `2.5 GHz` and `0` to
`300 mm`.

## Interpretation questions

1. Which three inputs set electrical length, and why does a lower velocity factor increase it?
2. Why can a matched lossless line have `|H| = 1` while its output phase is not zero?
3. Why does frequency change phase but not delay in this nondispersive model?
4. Why does a reflected wave in P01 rotate twice as far as the one-way matched path here?
5. What recognizable symptom tells you that wrapped phase has lost a whole-cycle count?
6. What extra measurement or prior knowledge can recover absolute delay or length?

## Teach-back

Answer without relying on MATLAB syntax: What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?

In two sentences, state the length-to-delay-to-phase mechanism and explain why a single wrapped
phase can alias paths separated by a guided wavelength, including one recovery method.
