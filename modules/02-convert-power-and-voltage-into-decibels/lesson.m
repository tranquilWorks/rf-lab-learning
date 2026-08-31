%% P02 - Convert Power and Voltage into Decibels
% Guiding question:
% What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?
%
% Mental model:
% A decibel reports a ratio on a logarithmic scale. Power uses 10*log10,
% while RMS voltage uses 20*log10 because power is proportional to V^2/R.
% The voltage shortcut describes a power change only when the two
% impedances are equal.

%% Read and make one prediction
disp('What inputs, observable effects, and failure modes matter when you convert Power and Voltage into Decibels?');
disp('P01 showed that impedance changes voltage behavior. Here impedance also decides how voltage maps to power.');
disp('Prediction: if power doubles and RMS voltage grows by sqrt(2) at equal impedance, will their dB changes agree?');

%% Visualize only the deterministic baseline
% launch_lesson stops after this one visual transition. The sweeps and
% broken case remain explicit next actions so they are not revealed early.
p02_show_baseline;

%% Read the mechanism after observing the baseline
disp('Mechanism: 10*log10(P/P_ref) is for power ratios.');
disp('Mechanism: 20*log10(V/V_ref) follows from squaring voltage in P = V_rms^2/R.');
disp('If R differs from R_ref, add 10*log10(R_ref/R) before calling the voltage result a power change.');

%% Continue one transition at a time
disp('Next, open experiment.m and run only the Sweep 1 Live Editor section. Return to its baseline section before Sweep 2.');
disp('After explaining both slopes, run only the Broken case section, then open interactive.');
disp('The interactive power and voltage controls are independent measurement inputs; the difference metric exposes inconsistency.');

%% Check and teach back when all transitions are complete
disp('Run run_checks, then explain the factor of two and the equal-impedance assumption without referring to MATLAB syntax.');
