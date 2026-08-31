# Walkthrough: Convert Power and Voltage into Decibels

Follow one visual transition at a time.

1. Read the guiding question: What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?
2. Make the single prediction in `lesson.m`, then run the baseline Live Editor section of `experiment.m`.
3. Confirm that a 2x power ratio and a `sqrt(2)` voltage ratio both produce `+3.0103 dB` when both resistances are 50 ohms.
4. Run only the Sweep 1 section. Observe that a tenfold power increase adds 10 dB; explain that only the power lever moved.
5. Return to the baseline section, then run only Sweep 2. Observe that a tenfold RMS-voltage increase adds 20 dB at equal impedance.
6. Read the equations in `lesson.md` and explain why the voltage multiplier is twice the power multiplier.
7. Open `interactive.m`. Change the signal resistance while holding both ratios fixed; observe the impedance-corrected voltage-derived power bar.
8. Run only the Broken case section, then toggle `Break: ignore impedance`. Name the violated equal-impedance assumption and use the missing correction to explain the symptom.
9. Reset, run `run_checks.m`, and answer the interpretation questions in `checks.md`.
10. Give a two-sentence teach-back: mechanism first, measurement consequence second.

Expected broken-case observation: equal RMS voltages across 75 ohms and 50 ohms have a 0 dB
amplitude ratio, but their power ratio is `-1.7609 dB`, not 0 dB.
