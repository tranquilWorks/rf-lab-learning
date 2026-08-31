function baseline = p02_show_baseline
%P02_SHOW_BASELINE Present the single deterministic P02 baseline transition.
referencePowerW = 1e-3;
referenceResistanceOhm = 50;
referenceVoltageRms = sqrt(referencePowerW*referenceResistanceOhm);
signalPowerW = 2*referencePowerW;
signalVoltageRms = sqrt(2)*referenceVoltageRms;
baseline = model(signalPowerW,signalVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);

fprintf('Baseline power: %.3f mW relative to %.3f mW -> %+.6f dB (%+.6f dBm).\n', ...
    1e3*baseline.powerW,1e3*baseline.referencePowerW,baseline.powerDb,baseline.powerDbm);
fprintf('Baseline voltage: %.6f V RMS relative to %.6f V RMS -> %+.6f dB.\n', ...
    baseline.voltageRms,baseline.referenceVoltageRms,baseline.voltageDb);
fprintf('Voltage-derived power at %.1f ohms -> %+.6f dB; impedance correction %+.6f dB.\n', ...
    baseline.resistanceOhm,baseline.voltagePowerDb,baseline.impedanceCorrectionDb);

figure('Name','P02 deterministic baseline');
subplot(1,2,1);
bar([baseline.powerRatio baseline.voltageRatio baseline.voltagePowerRatio]);
grid on;
xticks(1:3);
xticklabels({'P/P_{ref}','V/V_{ref}','(V^2/R)/(V_{ref}^2/R_{ref})'});
ylabel('Linear ratio');
title('Baseline linear ratios');

subplot(1,2,2);
bar([baseline.powerDb baseline.voltageDb baseline.voltagePowerDb]);
grid on;
xticks(1:3);
xticklabels({'Power','RMS voltage','Power from V and R'});
ylabel('Relative level (dB)');
title('Baseline: both power routes agree');

assert(abs(baseline.powerDb-3.010299956639812) < 1e-12, ...
    'The 2x power baseline must be +3.0103 dB.');
assert(abs(baseline.voltagePowerDb-baseline.powerDb) < 1e-12, ...
    'Consistent voltage and power must agree at equal resistance.');
end
