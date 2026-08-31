%% P02 deterministic baseline
% A 2x power ratio and sqrt(2)x RMS-voltage ratio at equal resistance
% must both produce +3.0103 dB. Run one Live Editor section at a time.
baseline = p02_show_baseline;
assert(abs(baseline.powerDb-baseline.voltagePowerDb) < 1e-12, ...
    'The two consistent baseline routes must agree.');

%% Sweep 1 - power ratio lever
referencePowerW = 1e-3;
referenceResistanceOhm = 50;
referenceVoltageRms = sqrt(referencePowerW*referenceResistanceOhm);
powerRatios = [0.1 0.25 0.5 1 2 4 10];
powerSweepDb = zeros(size(powerRatios));
for index = 1:numel(powerRatios)
    point = model(powerRatios(index)*referencePowerW,referenceVoltageRms, ...
        referenceResistanceOhm,referencePowerW,referenceVoltageRms,referenceResistanceOhm);
    powerSweepDb(index) = point.powerDb;
end

figure('Name','P02 power-ratio sweep');
semilogx(powerRatios,powerSweepDb,'o-','LineWidth',1.3,'MarkerFaceColor',[0 0.45 0.74]);
grid on;
xlabel('Power ratio P/P_{ref}');
ylabel('Relative power (dB)');
title('Sweep 1: a 10x power change is 10 dB');

assert(abs(powerSweepDb(powerRatios == 1)) < 1e-12,'Unity power ratio must be 0 dB.');
assert(abs(powerSweepDb(powerRatios == 10)-10) < 1e-12,'Tenfold power must be +10 dB.');

%% Sweep 2 - RMS-voltage ratio lever at equal resistance
referencePowerW = 1e-3;
referenceResistanceOhm = 50;
referenceVoltageRms = sqrt(referencePowerW*referenceResistanceOhm);
voltageRatios = [0.1 0.25 0.5 1 sqrt(2) 2 4 10];
voltageSweepDb = zeros(size(voltageRatios));
voltagePowerSweepDb = zeros(size(voltageRatios));
for index = 1:numel(voltageRatios)
    pointVoltageRms = voltageRatios(index)*referenceVoltageRms;
    pointPowerW = pointVoltageRms^2/referenceResistanceOhm;
    point = model(pointPowerW,pointVoltageRms,referenceResistanceOhm, ...
        referencePowerW,referenceVoltageRms,referenceResistanceOhm);
    voltageSweepDb(index) = point.voltageDb;
    voltagePowerSweepDb(index) = point.voltagePowerDb;
end

figure('Name','P02 voltage-ratio sweep');
semilogx(voltageRatios,voltageSweepDb,'o-','LineWidth',1.3, ...
    'DisplayName','20 log_{10}(V/V_{ref})');
hold on;
semilogx(voltageRatios,voltagePowerSweepDb,'x--','LineWidth',1.1, ...
    'DisplayName','10 log_{10}((V^2/R)/(V_{ref}^2/R_{ref}))');
hold off;
grid on;
xlabel('RMS-voltage ratio V/V_{ref}');
ylabel('Relative level (dB)');
title('Sweep 2: equal resistance makes the two routes coincide');
legend('Location','best');

assert(abs(voltageSweepDb(voltageRatios == 10)-20) < 1e-12, ...
    'Tenfold RMS voltage must be +20 dB.');
assert(max(abs(voltageSweepDb-voltagePowerSweepDb)) < 1e-12, ...
    'Voltage and voltage-derived power dB must agree at equal resistance.');

%% Broken case - ignore unequal resistance
referencePowerW = 1e-3;
referenceResistanceOhm = 50;
referenceVoltageRms = sqrt(referencePowerW*referenceResistanceOhm);
brokenResistanceOhm = 75;
brokenPowerW = referenceVoltageRms^2/brokenResistanceOhm;
broken = model(brokenPowerW,referenceVoltageRms,brokenResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
brokenReportedPowerDb = broken.voltageDb;

figure('Name','P02 deliberately broken impedance assumption');
bar([brokenReportedPowerDb broken.voltagePowerDb]);
grid on;
xticks(1:2);
xticklabels({'Broken: voltage-only report','Actual power from V^2/R'});
ylabel('Relative power (dB)');
title('Broken: equal voltage does not mean equal power at unequal resistance');

fprintf('Broken case: equal RMS voltages imply %+.6f dB if resistance is ignored.\n', ...
    brokenReportedPowerDb);
fprintf('Actual 75-ohm versus 50-ohm power ratio: %+.6f dB; omitted correction: %+.6f dB.\n', ...
    broken.voltagePowerDb,broken.impedanceCorrectionDb);

assert(abs(brokenReportedPowerDb) < 1e-12,'Equal RMS voltages must have a 0 dB amplitude ratio.');
assert(abs(broken.voltagePowerDb+1.760912590556813) < 1e-12, ...
    'The unequal-resistance case must reveal a -1.7609 dB power change.');
