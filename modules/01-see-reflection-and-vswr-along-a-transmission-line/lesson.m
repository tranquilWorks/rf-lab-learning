%% P01 - See Reflection and VSWR Along a Transmission Line
% Guiding question:
% What inputs, observable effects, and failure modes matter when you see Reflection and VSWR Along a Transmission Line?
%
% Mental model:
% A load mismatch launches a reflected wave. The forward and reflected waves add differently along the line, creating position-dependent voltage and current.

%% Read the baseline lesson
disp('What inputs, observable effects, and failure modes matter when you see Reflection and VSWR Along a Transmission Line?');
disp('A load mismatch launches a reflected wave. The forward and reflected waves add differently along the line, creating position-dependent voltage and current.');

%% Run the deterministic experiment
experiment;

%% Open the live lever panel
% Move one control at a time and connect the visible change to the model.
interactive;
