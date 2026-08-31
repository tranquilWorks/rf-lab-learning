# Lesson: Match a Load to a Source

## Guiding question

What inputs, observable effects, and failure modes matter when you match a Load to a Source?

## Connection to P01 and P02

P01 showed that a load different from the line impedance produces a reflection coefficient.
P02 showed how a power ratio becomes `10 log10(ratio)` dB. This lesson joins those ideas: a source
and load impedance determine a power-transfer mismatch, and its ratio can be reported in dB.

## Mental model

Represent the source by an open-circuit RMS voltage and a series impedance
`Z_s = R_s + jX_s`. With `Z_L = R_L + jX_L`,

`I = V_s/(Z_s + Z_L)`

and the average load power is `P_L = |I|^2 R_L`. The greatest available load power is
`P_av = V_s^2/(4R_s)`, and the fraction delivered is

`tau = P_L/P_av = 4 R_s R_L / |Z_s + Z_L|^2`.

The missing amount is visible in the mismatch coordinate
`Gamma_m = (Z_L - conj(Z_s))/(Z_L + Z_s)`, because `tau = 1 - |Gamma_m|^2`. When the source
impedance is real, this reduces to P01's familiar reflection form. `Gamma_m` is a power-transfer
coordinate for a complex source; do not automatically call it a measured voltage-wave reflection.

The inequality

`|Z_s + Z_L|^2 - 4 R_s R_L = (R_s - R_L)^2 + (X_s + X_L)^2 >= 0`

shows why `tau` cannot exceed one. It reaches one only when `R_L = R_s` and `X_L = -X_s`, so
`Z_L = conj(Z_s)`.

## One prediction

Before viewing the baseline, decide whether a `50 + j50 ohm` source should see a
`50 + j50 ohm` load or a `50 - j50 ohm` load for maximum power transfer.

## What to observe

The baseline uses a `1 V RMS` open-circuit source. With `Z_s = 50 + j50 ohms` and
`Z_L = 50 - j50 ohms`, the reactances cancel, current is `10 mA RMS`, and the load receives all
`5 mW` of available power (`6.9897 dBm`). The generalized mismatch coefficient is zero.

In Sweep 1, only load resistance changes while reactance stays canceled. Power peaks at 50 ohms;
25 and 100 ohms deliver the same fraction. Reset before Sweep 2. There, only load reactance changes,
and power is symmetric around `-50 ohms`, the cancellation point.

## Deliberately broken case

The broken case copies the source impedance into the load: `50 + j50 ohms`. Equal resistance and
equal impedance magnitude can look persuasive, but the two reactances add to `+100 ohms` instead
of canceling. The load receives only `2.5 mW`, `tau = 0.5`, and the mismatch loss is `3.0103 dB`.
The violated assumption is that complex maximum-power matching means numerical equality. It means
complex conjugation.

## Common mistakes

- Matching only resistance while leaving net reactance.
- Copying the source reactance instead of changing its sign.
- Calling `tau = 1` lossless. It means all *available* power reaches the load; at this
  maximum-power match, the source resistance still dissipates the same real power as the load.
- Treating a larger load-voltage magnitude as proof of greater average load power. Average power
  depends on current and the load's real part.
- Reporting mismatch loss without saying whether the number is a negative transfer dB or a
  positive loss magnitude.

## Completion standard

Run `run_module_checks("P03")`, diagnose the copied-reactance symptom, answer the interpretation
questions, and give a two-sentence teach-back: matching mechanism first, observable power
consequence second.
