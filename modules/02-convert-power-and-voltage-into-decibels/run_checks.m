function run_checks
%RUN_CHECKS Independent numerical, limiting-case, and input-contract checks.
referencePowerW = 1e-3;
referenceResistanceOhm = 50;
referenceVoltageRms = sqrt(referencePowerW*referenceResistanceOhm);
tolerance = 1e-12;

unity = model(referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(abs(unity.powerDb) < tolerance,'A unity power ratio must be 0 dB.');
assert(abs(unity.voltageDb) < tolerance,'A unity voltage ratio must be 0 dB.');
assert(abs(unity.voltagePowerDb) < tolerance,'Equal voltage and resistance references must be 0 dB.');

doublePower = model(2*referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
halfPower = model(0.5*referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(abs(doublePower.powerDb-3.010299956639812) < tolerance,'Doubling power must add 3.0103 dB.');
assert(abs(halfPower.powerDb+3.010299956639812) < tolerance,'Halving power must subtract 3.0103 dB.');
assert(abs(doublePower.powerDb+halfPower.powerDb) < tolerance,'Reciprocal power ratios must negate in dB.');

doubleVoltage = model(referencePowerW,2*referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(abs(doubleVoltage.voltageDb-6.020599913279624) < tolerance,'Doubling RMS voltage must add 6.0206 dB.');
assert(abs(doubleVoltage.voltagePowerDb-doubleVoltage.voltageDb) < tolerance, ...
    'Voltage dB and voltage-derived power dB must agree at equal resistance.');

baseline = model(2*referencePowerW,sqrt(2)*referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(abs(baseline.powerDb-baseline.voltagePowerDb) < tolerance, ...
    'Consistent power and voltage measurements must agree at equal resistance.');

unequalResistanceOhm = 75;
unequalPowerW = referenceVoltageRms^2/unequalResistanceOhm;
unequal = model(unequalPowerW,referenceVoltageRms,unequalResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(abs(unequal.voltageDb) < tolerance,'Equal RMS voltages have a 0 dB amplitude ratio.');
assert(abs(unequal.voltagePowerDb+1.760912590556813) < tolerance, ...
    'Equal voltages across 75 and 50 ohms differ in power by -1.7609 dB.');
assert(abs(unequal.voltagePowerDb-(unequal.voltageDb+unequal.impedanceCorrectionDb)) < tolerance, ...
    'The resistance correction must reconcile amplitude dB with power dB.');

cascadeA = model(2*referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
cascadeB = model(3*referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
cascadeTotal = model(6*referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
    referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(abs(cascadeTotal.powerDb-(cascadeA.powerDb+cascadeB.powerDb)) < tolerance, ...
    'Multiplicative power ratios must add in dB.');

absoluteReferences = model(1,1,referenceResistanceOhm,1,1,referenceResistanceOhm);
assert(abs(absoluteReferences.powerDbm-30) < tolerance,'One watt must be 30 dBm.');
assert(abs(absoluteReferences.powerDbw) < tolerance,'One watt must be 0 dBW.');
assert(abs(absoluteReferences.voltageDbv) < tolerance,'One volt RMS must be 0 dBV.');

zeroSignal = model(0,0,referenceResistanceOhm,referencePowerW,referenceVoltageRms,referenceResistanceOhm);
assert(isinf(zeroSignal.powerDb) && zeroSignal.powerDb < 0,'Zero power must be the -Inf dB limit.');
assert(isinf(zeroSignal.voltageDb) && zeroSignal.voltageDb < 0,'Zero voltage must be the -Inf dB limit.');

mustThrow(@() model(-1,1,50,1,1,50),'negative power');
mustThrow(@() model(1,-1,50,1,1,50),'negative voltage');
mustThrow(@() model(1,1,0,1,1,50),'zero signal resistance');
mustThrow(@() model(1,1,50,0,1,50),'zero reference power');
mustThrow(@() model(1,1,50,1,0,50),'zero reference voltage');
mustThrow(@() model(1,1,50,1,1,0),'zero reference resistance');
mustThrow(@() model(Inf,1,50,1,1,50),'nonfinite power');
mustThrow(@() model(NaN,1,50,1,1,50),'NaN power');
mustThrow(@() model([1 2],1,50,1,1,50),'nonscalar power');
mustThrow(@() model(1,1+1j,50,1,1,50),'complex voltage');

disp('P02 checks passed.');
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
