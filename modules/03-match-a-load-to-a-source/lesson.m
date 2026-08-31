%% P03 - Match a Load to a Source
% Guiding question:
% What inputs, observable effects, and failure modes matter when you match a Load to a Source?
%
% Mental model:
% A passive Thevenin source delivers its maximum available power when the
% load equals the complex conjugate of the source impedance. Resistance
% matches; reactance cancels.

%% Read and make one prediction
disp('What inputs, observable effects, and failure modes matter when you match a Load to a Source?');
disp('P01 connected impedance error to reflection; P02 connected a power ratio to decibels.');
disp('Prediction: for a 50 + j50 ohm source, does maximum load power require 50 + j50 or 50 - j50 ohms?');
disp('After the baseline, stop. Run only Sweep 1, observe its changed view, then read the mechanism in lesson.md.');

%% Visualize only the deterministic baseline
% launch_lesson ends after this one visual transition. The first lever,
% mechanism explanation, second lever, and broken case remain separate
% actions ordered by walkthrough.md.
p03_show_baseline;
