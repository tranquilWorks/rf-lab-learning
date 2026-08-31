%% P03 deterministic baseline
% A 1 V RMS source with Z_s = 50 + j50 ohms delivers its maximum
% available power to Z_L = 50 - j50 ohms. Run one section at a time.
baseline = p03_show_baseline;
assert(abs(baseline.powerTransferRatio-1) < 1e-12, ...
    'The conjugate-match baseline must have a unity transfer ratio.');

%% Sweep 1 - load resistance lever with reactance canceled
sourceVoltageRms = 1;
sourceResistanceOhm = 50;
sourceReactanceOhm = 50;
loadReactanceOhm = -50;
loadResistanceValues = [10 25 50 100 250];
loadPowerMilliwatt = zeros(size(loadResistanceValues));
powerTransferPercent = zeros(size(loadResistanceValues));
for index = 1:numel(loadResistanceValues)
    point = model(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
        loadResistanceValues(index),loadReactanceOhm);
    loadPowerMilliwatt(index) = 1e3*point.loadPowerW;
    powerTransferPercent(index) = 100*point.powerTransferRatio;
end

figure('Name','P03 load-resistance sweep');
subplot(2,1,1);
semilogx(loadResistanceValues,loadPowerMilliwatt,'o-','LineWidth',1.3, ...
    'MarkerFaceColor',[0 0.45 0.74]);
grid on;
xlabel('Load resistance R_L (ohms)');
ylabel('Delivered load power (mW)');
title('Sweep 1: delivered power peaks when R_L = R_s');

subplot(2,1,2);
semilogx(loadResistanceValues,powerTransferPercent,'s-','LineWidth',1.3, ...
    'MarkerFaceColor',[0.47 0.67 0.19]);
grid on;
xlabel('Load resistance R_L (ohms)');
ylabel('Available-power transfer tau (%)');
title('Reactance remains canceled at X_L = -50 ohms');

assert(loadPowerMilliwatt(loadResistanceValues == 50) == max(loadPowerMilliwatt), ...
    'Load power must peak at equal source and load resistance.');
assert(abs(powerTransferPercent(loadResistanceValues == 25)- ...
    powerTransferPercent(loadResistanceValues == 100)) < 1e-12, ...
    'Reciprocal resistance offsets must have equal transfer.');

%% Sweep 2 - load reactance lever with resistance matched
sourceVoltageRms = 1;
sourceResistanceOhm = 50;
sourceReactanceOhm = 50;
loadResistanceOhm = 50;
loadReactanceValues = [-150 -100 -50 0 50];
loadPowerMilliwatt = zeros(size(loadReactanceValues));
currentPhaseDegrees = zeros(size(loadReactanceValues));
for index = 1:numel(loadReactanceValues)
    point = model(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
        loadResistanceOhm,loadReactanceValues(index));
    loadPowerMilliwatt(index) = 1e3*point.loadPowerW;
    currentPhaseDegrees(index) = point.currentPhaseDeg;
end

figure('Name','P03 load-reactance sweep');
subplot(2,1,1);
plot(loadReactanceValues,loadPowerMilliwatt,'o-','LineWidth',1.3, ...
    'MarkerFaceColor',[0.85 0.33 0.10]);
grid on;
xlabel('Load reactance X_L (ohms)');
ylabel('Delivered load power (mW)');
title('Sweep 2: power peaks where X_L cancels X_s');

subplot(2,1,2);
plot(loadReactanceValues,currentPhaseDegrees,'d-','LineWidth',1.3, ...
    'MarkerFaceColor',[0.49 0.18 0.56]);
grid on;
xlabel('Load reactance X_L (ohms)');
ylabel('Source-current phase (degrees)');
title('Net series reactance rotates the source current');

assert(loadPowerMilliwatt(loadReactanceValues == -50) == max(loadPowerMilliwatt), ...
    'Load power must peak when the source and load reactances cancel.');
assert(abs(loadPowerMilliwatt(loadReactanceValues == -100)- ...
    loadPowerMilliwatt(loadReactanceValues == 0)) < 1e-12, ...
    'Equal reactance offsets around the conjugate match must deliver equal power.');

%% Broken case - copy source reactance instead of conjugating it
sourceVoltageRms = 1;
sourceResistanceOhm = 50;
sourceReactanceOhm = 50;
loadResistanceOhm = 50;
correct = model(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
    loadResistanceOhm,-sourceReactanceOhm);
broken = model(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
    loadResistanceOhm,sourceReactanceOhm);

figure('Name','P03 deliberately broken copied-reactance match');
subplot(1,2,1);
bar(1e3*[correct.loadPowerW broken.loadPowerW]);
grid on;
xticks(1:2);
xticklabels({'Conjugate: 50 - j50','Broken copy: 50 + j50'});
ylabel('Delivered load power (mW)');
title('Copied reactance halves delivered power');

subplot(1,2,2);
bar([correct.mismatchLossDb broken.mismatchLossDb]);
grid on;
xticks(1:2);
xticklabels({'Conjugate match','Broken copy'});
ylabel('Mismatch loss (dB)');
title('The hidden residual reactance costs 3.0103 dB');

fprintf('Correct load Z_L = %.1f %+.1fj ohms: %.3f mW, tau %.3f, net X %.1f ohms.\n', ...
    real(correct.loadImpedanceOhm),imag(correct.loadImpedanceOhm), ...
    1e3*correct.loadPowerW,correct.powerTransferRatio,correct.netReactanceOhm);
fprintf('Broken load Z_L = %.1f %+.1fj ohms: %.3f mW, tau %.3f, net X %+.1f ohms, loss %.6f dB.\n', ...
    real(broken.loadImpedanceOhm),imag(broken.loadImpedanceOhm), ...
    1e3*broken.loadPowerW,broken.powerTransferRatio,broken.netReactanceOhm,broken.mismatchLossDb);

assert(abs(broken.powerTransferRatio-0.5) < 1e-12, ...
    'Copying the source reactance must deliver half the available power.');
assert(abs(broken.mismatchLossDb-3.010299956639812) < 1e-12, ...
    'The copied-reactance failure must produce 3.0103 dB mismatch loss.');
assert(abs(broken.netReactanceOhm-100) < 1e-12, ...
    'The broken case must expose +100 ohms of uncanceled series reactance.');
