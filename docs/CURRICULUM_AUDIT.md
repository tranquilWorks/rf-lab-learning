# Curriculum readiness audit

**Track:** RF and Microwave Measurement

## Baseline conclusion

The repository has 24 uniquely identified modules in a six-phase, prerequisite-ordered sequence. P01 is the complete reference slice; P02-P24 are explicit non-runnable batch scaffolds. The learner flow is read → visualize → move one lever → visualize the delta → read/explain, followed by a broken case, checks, and teach-back.

Static structure and CLI behavior are verified in CI. MATLAB was not available during the 2026-08-11 baseline audit, so numerical execution, UI behavior, and instructional efficacy remain named validation gaps rather than implied evidence.

## Coverage and compounding order

### Phase 1: Waves and impedance

- **P01 — See Reflection and VSWR Along a Transmission Line:** What inputs, observable effects, and failure modes matter when you see Reflection and VSWR Along a Transmission Line?
- **P02 — Convert Power and Voltage into Decibels:** What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?
- **P03 — Match a Load to a Source:** What inputs, observable effects, and failure modes matter when you match a Load to a Source?
- **P04 — Relate Electrical Length to Phase:** What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?

### Phase 2: Network analysis

- **P05 — Interpret S-Parameters:** What inputs, observable effects, and failure modes matter when you interpret S-Parameters?
- **P06 — Calibrate a VNA Measurement:** What inputs, observable effects, and failure modes matter when you calibrate a VNA Measurement?
- **P07 — De-Embed a Cable or Fixture:** What inputs, observable effects, and failure modes matter when you de-Embed a Cable or Fixture?
- **P08 — Measure Filter Bandwidth and Rejection:** What inputs, observable effects, and failure modes matter when you measure Filter Bandwidth and Rejection?

### Phase 3: Active and nonlinear devices

- **P09 — Measure Gain and Compression:** What inputs, observable effects, and failure modes matter when you measure Gain and Compression?
- **P10 — Build a Noise-Figure Budget:** What inputs, observable effects, and failure modes matter when you build a Noise-Figure Budget?
- **P11 — Create Intermodulation Products:** What inputs, observable effects, and failure modes matter when you create Intermodulation Products?
- **P12 — See Phase Noise Around a Carrier:** What inputs, observable effects, and failure modes matter when you see Phase Noise Around a Carrier?

### Phase 4: Frequency conversion and IQ

- **P13 — Mix RF to an Intermediate Frequency:** What inputs, observable effects, and failure modes matter when you mix RF to an Intermediate Frequency?
- **P14 — Find Images and LO Leakage:** What inputs, observable effects, and failure modes matter when you find Images and LO Leakage?
- **P15 — Inject IQ Gain and Phase Error:** What inputs, observable effects, and failure modes matter when you inject IQ Gain and Phase Error?
- **P16 — Lock a Synthesizer to a Reference:** What inputs, observable effects, and failure modes matter when you lock a Synthesizer to a Reference?

### Phase 5: Antennas and propagation

- **P17 — Plot an Antenna Pattern:** What inputs, observable effects, and failure modes matter when you plot an Antenna Pattern?
- **P18 — See Polarization Mismatch:** What inputs, observable effects, and failure modes matter when you see Polarization Mismatch?
- **P19 — Build a Link Budget:** What inputs, observable effects, and failure modes matter when you build a Link Budget?
- **P20 — Model Fading and Multipath:** What inputs, observable effects, and failure modes matter when you model Fading and Multipath?

### Phase 6: Integrated RF labs

- **P21 — Use Couplers and Pads Intentionally:** What inputs, observable effects, and failure modes matter when you use Couplers and Pads Intentionally?
- **P22 — Make a Coherent Two-Channel Measurement:** What inputs, observable effects, and failure modes matter when you make a Coherent Two-Channel Measurement?
- **P23 — Trace an SDR RF Chain:** What inputs, observable effects, and failure modes matter when you trace an SDR RF Chain?
- **P24 — Isolate a Fault Across an RF Path:** What inputs, observable effects, and failure modes matter when you isolate a Fault Across an RF Path?

## Batch readiness gates

A scaffold may become `implemented` only when it has a deterministic model, a sectioned experiment, two independent parameter sweeps, one deliberately broken case, interactive controls, interpretation-focused tutor text, numerical checks, focused static tests, and evidence that says exactly what did and did not run.
