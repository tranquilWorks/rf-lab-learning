# Checks: Match a Load to a Source

## Guiding question

What inputs, observable effects, and failure modes matter when you match a Load to a Source?

## Numerical and limiting-case checks

Run:

```matlab
run_module_checks("P03")
```

The executable checks cover the conjugate-match baseline, both
`tau = P_L/P_av` and `tau = 1 - |Gamma_m|^2`, resistance and reactance symmetry, the real-source
P01 limit, the copied-reactance failure, a short-circuit real-power limit, a large-load
open-circuit limit, source-voltage scaling, stressed accepted-envelope endpoints, and malformed
input. If this module folder is already the MATLAB current folder, calling `run_checks` directly
is equivalent.

The scalar calculation envelope is `1e-12` to `1e6 V RMS`, `1e-9` to `1e12 ohms` for source
resistance, `0` to `1e12 ohms` for load resistance, and `-1e12` to `+1e12 ohms` for either
reactance. These broad bounds prevent overflow in finite-valued linear quantities; logarithmic
zero-transfer and perfect-match limits intentionally remain `-Inf` or `+Inf`. The interactive
controls use much narrower teaching ranges.

## Interpretation questions

1. Why must `R_L = R_s` and `X_L = -X_s` both hold for maximum available-power transfer?
2. How does `tau = 1 - |Gamma_m|^2` connect this lesson to P01 when the source impedance is real?
3. How does P02 turn `tau = 0.5` into `3.0103 dB` of positive mismatch loss?
4. Why does the copied-reactance case fail even though source and load have equal resistance and equal impedance magnitude?
5. Why is `tau = 1` not a claim of lossless circuit efficiency?

## Teach-back

Answer without relying on MATLAB syntax: What inputs, observable effects, and failure modes matter when you match a Load to a Source?

In two sentences, state the conjugate-match condition and use delivered versus available power to
diagnose the copied-reactance failure.
