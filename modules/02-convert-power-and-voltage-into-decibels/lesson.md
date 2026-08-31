# Lesson: Convert Power and Voltage into Decibels

## Guiding question

What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?

## Connection to P01

P01 showed that a voltage observation is inseparable from its impedance context. The same rule
appears here: an RMS voltage determines power through `P = V_rms^2/R`. A voltage ratio can stand in
for a power ratio only when the signal and reference impedances are equal.

## Mental model

A decibel compresses a ratio so multiplication becomes addition:

- Power ratio: `L_P = 10 log10(P/P_ref)` dB.
- RMS-voltage ratio: `L_V = 20 log10(V/V_ref)` dB.
- Voltage-derived power ratio: `L_P = L_V + 10 log10(R_ref/R)` dB.

The `20` is not a different definition of the decibel. It is the power equation's voltage-squared
term brought through the logarithm.

## One prediction

Before viewing the baseline, predict whether doubling power and multiplying RMS voltage by
`sqrt(2)` at the same impedance will produce the same dB change.

## What to observe

The baseline uses a 1 mW reference into 50 ohms. A 2 mW signal and its corresponding RMS voltage
both sit `3.0103 dB` above their references. In the first sweep, each factor-of-ten power change
moves the result by 10 dB. In the second, each factor-of-ten voltage change moves the result by
20 dB.

After resetting, change only the signal resistance. The raw voltage ratio does not move, but the
power inferred from that voltage does. This is the exact assumption hidden by the common phrase
“use 20 log for voltage.”

The interactive power and voltage sliders are independent measurement inputs. They agree at the
baseline; after either is moved alone, the direct-versus-derived difference is a diagnostic rather
than an extra conversion rule.

## Deliberately broken case

The broken view reports `20 log10(V/V_ref)` as a power change while the signal is measured across
75 ohms and the reference across 50 ohms. Equal voltages then appear to mean 0 dB, but the actual
power ratio is `50/75`, or `-1.7609 dB`. The recognizable symptom is a missing impedance correction,
not a failure of logarithms.

## Common mistakes

- Using `20 log10` on a power ratio doubles the correct dB magnitude.
- Using `10 log10` on a voltage ratio misses the voltage-squared relationship.
- Calling dB an absolute power without naming a reference. dBm uses 1 mW; dBW uses 1 W; dBV uses
  1 V RMS.
- Mixing peak and RMS voltage. Their ratio includes `sqrt(2)`, which becomes 3.0103 dB.
- Taking a logarithm of a negative quantity. Zero is only the `-Inf dB` limiting case.

## Completion standard

Run `run_checks.m`, diagnose the broken impedance assumption, and give a two-sentence teach-back:
first explain why power and voltage use different multipliers, then state when voltage dB can be
interpreted as power dB.
