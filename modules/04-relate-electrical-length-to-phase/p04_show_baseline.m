function baseline = p04_show_baseline
%P04_SHOW_BASELINE Present one deterministic quarter-wave transition.
frequencyHz = 1e9;
velocityFactor = 0.66;
speedOfLightMps = 299792458;
physicalLengthM = velocityFactor*speedOfLightMps/(4*frequencyHz);
baseline = model(frequencyHz,physicalLengthM,velocityFactor);

fprintf('Matched ideal path: f = %.3f GHz, length = %.3f mm, velocity factor = %.2f.\n', ...
    baseline.frequencyHz/1e9,1e3*baseline.physicalLengthM,baseline.velocityFactor);
fprintf('v_p = %.6f Mm/s, guided wavelength = %.3f mm, delay = %.3f ps.\n', ...
    baseline.phaseVelocityMps/1e6,1e3*baseline.wavelengthM,1e12*baseline.propagationDelayS);
fprintf('Electrical length beta*l = %.3f degrees; H = %.3f %+.3fj.\n', ...
    baseline.electricalLengthDeg,real(baseline.transferPhasor),imag(baseline.transferPhasor));
fprintf('Through phase: %.3f degrees unwrapped, %.3f degrees wrapped.\n', ...
    baseline.unwrappedTransferPhaseDeg,baseline.wrappedTransferPhaseDeg);

timeS = linspace(0,2/frequencyHz,401);
inputWave = cos(2*pi*frequencyHz*timeS);
outputWave = cos(2*pi*frequencyHz*(timeS-baseline.propagationDelayS));
unitCircle = exp(1j*linspace(0,2*pi,241));

figure('Name','P04 deterministic quarter-wave baseline');
subplot(1,2,1);
plot(1e9*timeS,inputWave,'LineWidth',1.3,'DisplayName','Input');
hold on;
plot(1e9*timeS,outputWave,'LineWidth',1.3,'DisplayName','Output after line');
hold off;
grid on;
xlabel('Time (ns)');
ylabel('Normalized voltage (V/V_0)');
title('Quarter-wave delay: output lags by 90 degrees');
legend('Location','best');

subplot(1,2,2);
plot(real(unitCircle),imag(unitCircle),':','DisplayName','Unit circle');
hold on;
plot([0 1],[0 0],'-','LineWidth',1.4,'DisplayName','Input phasor');
plot([0 real(baseline.transferPhasor)],[0 imag(baseline.transferPhasor)], ...
    '-','LineWidth',1.8,'DisplayName','Output phasor');
plot(real(baseline.transferPhasor),imag(baseline.transferPhasor),'o', ...
    'MarkerSize',8,'MarkerFaceColor',[0.85 0.33 0.10],'DisplayName','H = e^{-j beta l}');
hold off;
axis equal;
xlim([-1.1 1.1]);
ylim([-1.1 1.1]);
grid on;
xlabel('In-phase component (dimensionless)');
ylabel('Quadrature component (dimensionless)');
title('One-way transfer phasor at -90 degrees');
legend('Location','best');

tolerance = 1e-12;
assert(abs(baseline.propagationDelayS-250e-12) < 1e-21, ...
    'The quarter-wave baseline must delay a 1 GHz signal by 250 ps.');
assert(abs(baseline.electricalLengthDeg-90) < tolerance, ...
    'The baseline physical length must equal one guided quarter wavelength.');
assert(abs(baseline.transferPhasor+1j) < tolerance, ...
    'A quarter-wave path must rotate the through phasor to -j.');
end
