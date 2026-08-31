%% P04 deterministic baseline
% A matched, ideal line is one guided quarter wavelength long at 1 GHz.
% Run one section at a time so each lever produces one visible transition.
baseline = p04_show_baseline;
assert(abs(baseline.electricalLengthDeg-90) < 1e-12, ...
    'The deterministic baseline must be one guided quarter wavelength.');

%% Sweep 1 - frequency lever at fixed physical length
velocityFactor = 0.66;
speedOfLightMps = 299792458;
baselineFrequencyHz = 1e9;
fixedLengthM = velocityFactor*speedOfLightMps/(4*baselineFrequencyHz);
frequencyValuesGHz = [0.5 1.0 1.5 2.0 2.5];
unwrappedPhaseDeg = zeros(size(frequencyValuesGHz));
wrappedPhaseDeg = zeros(size(frequencyValuesGHz));
delayPicosecond = zeros(size(frequencyValuesGHz));
for index = 1:numel(frequencyValuesGHz)
    point = model(1e9*frequencyValuesGHz(index),fixedLengthM,velocityFactor);
    unwrappedPhaseDeg(index) = point.unwrappedTransferPhaseDeg;
    wrappedPhaseDeg(index) = point.wrappedTransferPhaseDeg;
    delayPicosecond(index) = 1e12*point.propagationDelayS;
end

figure('Name','P04 frequency sweep at fixed physical length');
subplot(2,1,1);
plot(frequencyValuesGHz,unwrappedPhaseDeg,'o-','LineWidth',1.3, ...
    'MarkerFaceColor',[0 0.45 0.74],'DisplayName','Unwrapped through phase');
hold on;
plot(frequencyValuesGHz,wrappedPhaseDeg,'s--','LineWidth',1.3, ...
    'MarkerFaceColor',[0.85 0.33 0.10],'DisplayName','Wrapped instrument view');
hold off;
grid on;
xlabel('Frequency (GHz)');
ylabel('Through phase (degrees)');
title('Sweep 1: beta*l grows with frequency while length stays fixed');
legend('Location','best');

subplot(2,1,2);
plot(frequencyValuesGHz,delayPicosecond,'d-','LineWidth',1.3, ...
    'MarkerFaceColor',[0.47 0.67 0.19]);
grid on;
xlabel('Frequency (GHz)');
ylabel('Propagation delay (ps)');
title('Nondispersive assumption: physical delay remains 250 ps');

assert(abs(unwrappedPhaseDeg(frequencyValuesGHz == 2)+180) < 1e-12, ...
    'Doubling frequency at fixed length must double phase magnitude.');
assert(max(delayPicosecond)-min(delayPicosecond) < 1e-12, ...
    'Frequency alone must not change delay in the nondispersive model.');

%% Sweep 2 - physical-length lever at fixed frequency
velocityFactor = 0.66;
speedOfLightMps = 299792458;
frequencyHz = 1e9;
quarterWaveLengthM = velocityFactor*speedOfLightMps/(4*frequencyHz);
lengthValuesM = quarterWaveLengthM*[0 1 2 3 4];
unwrappedPhaseDeg = zeros(size(lengthValuesM));
wrappedPhaseDeg = zeros(size(lengthValuesM));
delayPicosecond = zeros(size(lengthValuesM));
for index = 1:numel(lengthValuesM)
    point = model(frequencyHz,lengthValuesM(index),velocityFactor);
    unwrappedPhaseDeg(index) = point.unwrappedTransferPhaseDeg;
    wrappedPhaseDeg(index) = point.wrappedTransferPhaseDeg;
    delayPicosecond(index) = 1e12*point.propagationDelayS;
end

figure('Name','P04 physical-length sweep at fixed frequency');
subplot(2,1,1);
plot(1e3*lengthValuesM,unwrappedPhaseDeg,'o-','LineWidth',1.3, ...
    'MarkerFaceColor',[0.49 0.18 0.56],'DisplayName','Unwrapped through phase');
hold on;
plot(1e3*lengthValuesM,wrappedPhaseDeg,'s--','LineWidth',1.3, ...
    'MarkerFaceColor',[0.93 0.69 0.13],'DisplayName','Wrapped instrument view');
hold off;
grid on;
xlabel('Physical line length (mm)');
ylabel('Through phase (degrees)');
title('Sweep 2: each guided quarter wavelength adds -90 degrees');
legend('Location','best');

subplot(2,1,2);
plot(1e3*lengthValuesM,delayPicosecond,'d-','LineWidth',1.3, ...
    'MarkerFaceColor',[0.30 0.75 0.93]);
grid on;
xlabel('Physical line length (mm)');
ylabel('Propagation delay (ps)');
title('Delay grows linearly with physical length');

assert(abs(unwrappedPhaseDeg(end)+360) < 1e-12, ...
    'One guided wavelength must accumulate -360 degrees of through phase.');
assert(abs(wrappedPhaseDeg(1)-wrappedPhaseDeg(end)) < 1e-12, ...
    'Zero and one guided wavelength must look identical after phase wrapping.');
assert(abs(delayPicosecond(end)-1000) < 1e-9, ...
    'One guided wavelength at 1 GHz must produce 1 ns of delay.');

%% Broken case - treat wrapped phase as total phase
frequencyHz = 1e9;
velocityFactor = 0.66;
speedOfLightMps = 299792458;
guidedQuarterWaveM = velocityFactor*speedOfLightMps/(4*frequencyHz);
shortPath = model(frequencyHz,guidedQuarterWaveM,velocityFactor);
actualLongPath = model(frequencyHz,5*guidedQuarterWaveM,velocityFactor);
naiveLengthM = actualLongPath.phaseEquivalentLengthM;
lengthErrorM = actualLongPath.physicalLengthM-naiveLengthM;

figure('Name','P04 deliberately broken wrapped-phase length inference');
subplot(1,2,1);
bar(1e3*[actualLongPath.physicalLengthM naiveLengthM]);
grid on;
xticks(1:2);
xticklabels({'Actual 5 lambda_g/4 path','Broken phase-only estimate'});
ylabel('Physical line length (mm)');
title('Wrapped phase drops one whole guided wavelength');

subplot(1,2,2);
bar([shortPath.wrappedTransferPhaseDeg actualLongPath.wrappedTransferPhaseDeg]);
grid on;
xticks(1:2);
xticklabels({'lambda_g/4 path','5 lambda_g/4 path'});
ylabel('Wrapped through phase (degrees)');
title('Different delays produce the same -90 degree reading');

fprintf('Actual path: %.3f mm, delay %.3f ps, unwrapped phase %.1f degrees.\n', ...
    1e3*actualLongPath.physicalLengthM,1e12*actualLongPath.propagationDelayS, ...
    actualLongPath.unwrappedTransferPhaseDeg);
fprintf('Wrapped reading: %.1f degrees; broken phase-only estimate: %.3f mm.\n', ...
    actualLongPath.wrappedTransferPhaseDeg,1e3*naiveLengthM);
fprintf('Recognizable symptom: the estimate is short by one guided wavelength (%.3f mm).\n', ...
    1e3*lengthErrorM);

assert(abs(actualLongPath.wrappedTransferPhaseDeg-shortPath.wrappedTransferPhaseDeg) < 1e-12, ...
    'Paths separated by one guided wavelength must have the same wrapped phase.');
assert(abs(actualLongPath.unwrappedTransferPhaseDeg-shortPath.unwrappedTransferPhaseDeg+360) < 1e-12, ...
    'The two paths must differ by one complete cycle of unwrapped phase.');
assert(abs(naiveLengthM-guidedQuarterWaveM) < 1e-12, ...
    'The broken phase-only inference must alias 5 lambda_g/4 to lambda_g/4.');
assert(abs(lengthErrorM-shortPath.wavelengthM) < 1e-12, ...
    'The broken estimate must miss exactly one guided wavelength.');
