# Checks: Convert Power and Voltage into Decibels

## Numerical and limiting-case checks

Run:

```matlab
run_checks
```

The executable checks cover unity, doubling, halving, reciprocal ratios, additive cascades,
absolute dBm/dBW/dBV references, the zero-signal `-Inf dB` limit, unequal impedance, and rejection
of negative, nonfinite, complex, nonscalar, or nonpositive-reference inputs.

## Interpretation questions

1. Why does a 2x power ratio produce about 3 dB while a 2x RMS-voltage ratio produces about 6 dB?
2. A signal and reference have equal RMS voltage but different resistance. Which term must be added before the voltage result is interpreted as a power ratio?
3. Why is “5 dB” incomplete as an absolute power measurement, while “5 dBm” is not?
4. What recognizable symptom tells you the deliberately broken case ignored impedance?

## Teach-back

Answer the guiding question without relying on MATLAB syntax: What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?

In two sentences, name the ratio and reference, explain the multiplier, and state the
equal-impedance condition.
