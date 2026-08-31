%% P04 - Relate Electrical Length to Phase
% Guiding question:
% What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?
%
% Mental model:
% Electrical length is beta*l = 2*pi*f*l/v_p. With the exp(+j*omega*t)
% convention, a matched forward path has H = exp(-j*beta*l): physical
% propagation delay appears as a negative through-phase shift.

%% Read and make one prediction
disp('What inputs, observable effects, and failure modes matter when you relate Electrical Length to Phase?');
disp('P03 showed why impedance conditions matter; here both ports terminate a real-Z_0 line in Z_0.');
disp('Prediction: at 1 GHz, what through-phase shift should one guided quarter wavelength produce?');
disp('After the baseline, stop. Run only Sweep 1, observe its changed view, then read the mechanism in lesson.md.');

%% Visualize only the deterministic baseline
% launch_lesson ends after this one visual transition. The first lever,
% mechanism explanation, second lever, and broken case remain separate
% actions ordered by walkthrough.md.
p04_show_baseline;
