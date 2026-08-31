function baseline = p03_show_baseline
%P03_SHOW_BASELINE Present the single deterministic conjugate-match view.
sourceVoltageRms = 1;
sourceResistanceOhm = 50;
sourceReactanceOhm = 50;
loadResistanceOhm = 50;
loadReactanceOhm = -50;
baseline = model(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
    loadResistanceOhm,loadReactanceOhm);

fprintf('Source: %.3f V RMS open circuit, Z_s = %.1f %+.1fj ohms.\n', ...
    baseline.sourceVoltageRms,real(baseline.sourceImpedanceOhm),imag(baseline.sourceImpedanceOhm));
fprintf('Conjugate load: Z_L = %.1f %+.1fj ohms; current = %.3f mA RMS at %+.3f degrees.\n', ...
    real(baseline.loadImpedanceOhm),imag(baseline.loadImpedanceOhm), ...
    1e3*baseline.currentRmsA,baseline.currentPhaseDeg);
fprintf('Delivered: %.3f mW (%+.6f dBm) of %.3f mW available; tau = %.3f, mismatch loss = %.3f dB.\n', ...
    1e3*baseline.loadPowerW,baseline.loadPowerDbm,1e3*baseline.availablePowerW, ...
    baseline.powerTransferRatio,baseline.mismatchLossDb);
fprintf('Source resistance also dissipates %.3f mW; maximum available-power transfer is not lossless.\n', ...
    1e3*baseline.sourceLossW);

figure('Name','P03 deterministic conjugate-match baseline');
subplot(1,2,1);
bar(1e3*[baseline.availablePowerW baseline.loadPowerW baseline.sourceLossW]);
grid on;
xticks(1:3);
xticklabels({'Available-power reference','Delivered to load','Source-resistance loss'});
ylabel('Real power (mW)');
title('Baseline power metrics');

subplot(1,2,2);
plot(real(baseline.sourceImpedanceOhm),imag(baseline.sourceImpedanceOhm),'s', ...
    'MarkerSize',9,'LineWidth',1.5,'DisplayName','Source Z_s');
hold on;
plot(real(baseline.conjugateMatchOhm),imag(baseline.conjugateMatchOhm),'x', ...
    'MarkerSize',12,'LineWidth',2,'DisplayName','Conjugate-match target');
plot(real(baseline.loadImpedanceOhm),imag(baseline.loadImpedanceOhm),'o', ...
    'MarkerSize',7,'LineWidth',1.3,'DisplayName','Actual load Z_L');
hold off;
grid on;
axis equal;
xlabel('Resistance (ohms)');
ylabel('Reactance (ohms)');
title('Resistance matches while reactance cancels');
legend('Location','best');

tolerance = 1e-12;
assert(abs(baseline.loadPowerW-5e-3) < tolerance, ...
    'The conjugate-match baseline must deliver 5 mW.');
assert(abs(baseline.powerTransferRatio-1) < tolerance, ...
    'The conjugate match must deliver all available power.');
assert(abs(baseline.powerWaveGamma) < tolerance, ...
    'The conjugate match must put the mismatch coordinate at the origin.');
end
