function run_checks
%RUN_CHECKS Independent numerical, limiting-case, and input-contract checks.
tolerance = 1e-12;
powerTolerance = 1e-14;

matched = model(1,50,50,50,-50);
assert(abs(matched.currentA-0.01) < tolerance,'Matched current must be 10 mA RMS and in phase.');
assert(abs(matched.loadVoltagePhasorRms-(0.5-0.5j)) < tolerance, ...
    'Matched load voltage must be 0.5 - j0.5 V RMS.');
assert(abs(matched.loadPowerW-5e-3) < powerTolerance,'Matched load power must be 5 mW.');
assert(abs(matched.availablePowerW-5e-3) < powerTolerance,'Available source power must be 5 mW.');
assert(abs(matched.sourceLossW-5e-3) < powerTolerance, ...
    'Source resistance and matched load must dissipate equal real power.');
assert(abs(matched.loadReactivePowerVar+5e-3) < powerTolerance, ...
    'The matched capacitive load must have -5 mvar reactive power.');
assert(abs(matched.powerTransferRatio-1) < tolerance,'A conjugate match must have tau = 1.');
assert(abs(matched.powerWaveGamma) < tolerance,'A conjugate match must have Gamma_m = 0.');
assert(abs(matched.mismatchLossDb) < tolerance,'A conjugate match must have zero mismatch loss.');
assert(abs(matched.loadPowerDbm-6.989700043360188) < tolerance,'Five milliwatts must be 6.9897 dBm.');
assert(abs(matched.netReactanceOhm) < tolerance,'Conjugate reactances must cancel.');

identityCases = [10 -50; 25 -50; 50 -100; 50 0; 100 -50];
for index = 1:size(identityCases,1)
    point = model(1,50,50,identityCases(index,1),identityCases(index,2));
    assert(point.powerTransferRatio >= 0 && point.powerTransferRatio <= 1+tolerance, ...
        'Passive-load transfer must remain between zero and one.');
    assert(abs(point.powerTransferRatio-point.loadPowerW/point.availablePowerW) < tolerance, ...
        'tau must equal P_L/P_av.');
    assert(abs(point.powerTransferRatio-(1-abs(point.powerWaveGamma)^2)) < tolerance, ...
        'tau must equal 1 - |Gamma_m|^2.');
end

lowResistance = model(1,50,50,25,-50);
highResistance = model(1,50,50,100,-50);
assert(abs(lowResistance.powerTransferRatio-8/9) < tolerance, ...
    'A 25-ohm load with canceled reactance must have tau = 8/9.');
assert(abs(lowResistance.powerTransferRatio-highResistance.powerTransferRatio) < tolerance, ...
    'The 25-ohm and 100-ohm resistance offsets must transfer equal power.');

lowReactance = model(1,50,50,50,-100);
highReactance = model(1,50,50,50,0);
assert(abs(lowReactance.powerTransferRatio-0.8) < tolerance, ...
    'A 50-ohm reactance offset must have tau = 0.8.');
assert(abs(lowReactance.powerTransferRatio-highReactance.powerTransferRatio) < tolerance, ...
    'Equal reactance offsets around -X_s must transfer equal power.');

p01RealSource = model(1,50,0,100,0);
assert(abs(p01RealSource.powerWaveGamma-1/3) < tolerance, ...
    'A real 50-ohm source and 100-ohm load must recover the P01 Gamma = 1/3 case.');
assert(abs(p01RealSource.powerTransferRatio-8/9) < tolerance, ...
    'The real-source P01 bridge must have tau = 1 - (1/3)^2 = 8/9.');

broken = model(1,50,50,50,50);
assert(abs(broken.currentA-(0.005-0.005j)) < tolerance, ...
    'Copied reactance must rotate and reduce the source current.');
assert(abs(broken.loadPowerW-2.5e-3) < powerTolerance,'Copied reactance must deliver 2.5 mW.');
assert(abs(broken.powerTransferRatio-0.5) < tolerance,'Copied reactance must give tau = 0.5.');
assert(abs(broken.powerWaveGamma-(0.5+0.5j)) < tolerance, ...
    'Copied reactance must produce Gamma_m = 0.5 + j0.5.');
assert(abs(broken.mismatchLossDb-3.010299956639812) < tolerance, ...
    'Half-power transfer must have 3.0103 dB mismatch loss.');
assert(abs(broken.netReactanceOhm-100) < tolerance, ...
    'Copied reactance must leave +100 ohms net reactance.');

shortCircuit = model(1,50,50,0,0);
assert(shortCircuit.loadPowerW == 0,'A zero-resistance load must absorb zero average real power.');
assert(shortCircuit.powerTransferRatio == 0,'A zero-resistance load must have zero power transfer.');
assert(shortCircuit.loadImpedanceOhm == 0,'A short circuit must have Z_L = 0.');
assert(shortCircuit.loadVoltageRms == 0,'A short circuit must have zero load voltage.');
assert(isinf(shortCircuit.loadPowerDbm) && shortCircuit.loadPowerDbm < 0, ...
    'Zero load power must be the -Inf dBm limit.');
assert(isinf(shortCircuit.mismatchLossDb) && shortCircuit.mismatchLossDb > 0, ...
    'Zero transfer must be the +Inf mismatch-loss limit.');

openCircuit = model(1,50,50,1e12,-50);
assert(openCircuit.currentRmsA < 1.1e-12,'A very large load must approach zero current.');
assert(openCircuit.loadPowerW < 1.1e-12,'A very large load must approach zero real power.');
assert(abs(openCircuit.loadVoltageRms-1) < 1e-9, ...
    'A very large load must approach the open-circuit source voltage.');

doubleVoltage = model(2,50,50,50,-50);
assert(abs(doubleVoltage.loadPowerW/ matched.loadPowerW-4) < tolerance, ...
    'Doubling RMS source voltage must quadruple load power.');
assert(abs((doubleVoltage.loadPowerDbm-matched.loadPowerDbm)-6.020599913279624) < tolerance, ...
    'A fourfold power change must add 6.0206 dB.');
assert(abs(doubleVoltage.powerTransferRatio-matched.powerTransferRatio) < tolerance, ...
    'Source amplitude must not change the impedance-only transfer ratio.');

largeEnvelopeEdge = model(1e6,1e-9,1e12,1e-9,-1e12);
assert(all(isfinite([largeEnvelopeEdge.currentRmsA largeEnvelopeEdge.loadVoltageRms ...
    largeEnvelopeEdge.loadPowerW largeEnvelopeEdge.loadReactivePowerVar ...
    largeEnvelopeEdge.sourceLossW largeEnvelopeEdge.availablePowerW ...
    largeEnvelopeEdge.powerTransferRatio largeEnvelopeEdge.powerWaveGamma])), ...
    'Supported large-value endpoints must keep derived linear metrics finite.');
assert(largeEnvelopeEdge.currentRmsA > 4e14 && ...
    largeEnvelopeEdge.loadVoltageRms > 4e26 && ...
    abs(largeEnvelopeEdge.loadReactivePowerVar) > 2e41, ...
    'The accepted-boundary stress case must exercise large finite derived values.');
smallEnvelopeEdge = model(1e-12,1e12,-1e12,1e12,1e12);
assert(all(isfinite([smallEnvelopeEdge.currentRmsA smallEnvelopeEdge.loadVoltageRms ...
    smallEnvelopeEdge.loadPowerW smallEnvelopeEdge.loadReactivePowerVar ...
    smallEnvelopeEdge.sourceLossW smallEnvelopeEdge.availablePowerW ...
    smallEnvelopeEdge.powerTransferRatio smallEnvelopeEdge.powerWaveGamma])), ...
    'Supported small-value endpoints must keep derived linear metrics finite.');

mustThrow(@() model(-1,50,50,50,-50),'negative source voltage');
mustThrow(@() model(0,50,50,50,-50),'zero source voltage');
mustThrow(@() model(1,0,50,50,-50),'zero source resistance');
mustThrow(@() model(1,-50,50,50,-50),'negative source resistance');
mustThrow(@() model(1,50,50,-1,-50),'negative load resistance');
mustThrow(@() model(Inf,50,50,50,-50),'nonfinite source voltage');
mustThrow(@() model(1,50,NaN,50,-50),'NaN source reactance');
mustThrow(@() model(1,50,50,Inf,-50),'nonfinite load resistance');
mustThrow(@() model(1,50,50,50,NaN),'NaN load reactance');
mustThrow(@() model([1 2],50,50,50,-50),'nonscalar source voltage');
mustThrow(@() model(1,50+1j,50,50,-50),'complex source resistance');
mustThrow(@() model(1,50,50+1j,50,-50),'complex source reactance');
mustThrow(@() model(1,50,50,50,-50+1j),'complex load reactance');
mustThrow(@() model(1e-13,50,50,50,-50),'source voltage below supported envelope');
mustThrow(@() model(1e7,50,50,50,-50),'source voltage above supported envelope');
mustThrow(@() model(1,1e-10,50,50,-50),'source resistance below supported envelope');
mustThrow(@() model(1,1e13,50,50,-50),'source resistance above supported envelope');
mustThrow(@() model(1,50,1e13,50,-50),'source reactance above supported envelope');
mustThrow(@() model(1,50,50,1e13,-50),'load resistance above supported envelope');
mustThrow(@() model(1,50,50,50,-1e13),'load reactance below supported envelope');

disp('P03 checks passed.');
end

function mustThrow(action,label)
didThrow = false;
try
    action();
catch
    didThrow = true;
end
assert(didThrow,'%s must be rejected.',label);
end
