function interactive
%INTERACTIVE Explore how frequency and physical length set phase delay.
modelFcn = @model;
baselineFrequencyGHz = 1;
velocityFactor = 0.66;
speedOfLightMps = 299792458;
baselineLengthMm = 1e3*velocityFactor*speedOfLightMps/(4*baselineFrequencyGHz*1e9);

fig = uifigure('Name','P04 Relate Electrical Length to Phase', ...
    'Position',[80 80 1320 720]);
gridLayout = uigridlayout(fig,[4 6]);
gridLayout.RowHeight = {'1x',24,58,125};
gridLayout.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

waveAxes = uiaxes(gridLayout);
waveAxes.Layout.Row = 1;
waveAxes.Layout.Column = [1 2];
phaseAxes = uiaxes(gridLayout);
phaseAxes.Layout.Row = 1;
phaseAxes.Layout.Column = [3 4];
lengthAxes = uiaxes(gridLayout);
lengthAxes.Layout.Row = 1;
lengthAxes.Layout.Column = [5 6];

frequencyLabel = uilabel(gridLayout,'Text','Frequency (GHz)');
frequencyLabel.Layout.Row = 2;
frequencyLabel.Layout.Column = [1 2];
lengthLabel = uilabel(gridLayout,'Text','Physical line length (mm)');
lengthLabel.Layout.Row = 2;
lengthLabel.Layout.Column = [3 4];
brokenCheck = uicheckbox(gridLayout, ...
    'Text','Break: trust wrapped phase alone','Value',false);
brokenCheck.Layout.Row = 2;
brokenCheck.Layout.Column = 5;
resetButton = uibutton(gridLayout,'Text','Reset quarter-wave baseline');
resetButton.Layout.Row = 2;
resetButton.Layout.Column = 6;

frequencySlider = uislider(gridLayout,'Limits',[0.5 2.5], ...
    'Value',baselineFrequencyGHz);
frequencySlider.Layout.Row = 3;
frequencySlider.Layout.Column = [1 2];
lengthSlider = uislider(gridLayout,'Limits',[0 300], ...
    'Value',baselineLengthMm);
lengthSlider.Layout.Row = 3;
lengthSlider.Layout.Column = [3 4];
controlHint = uilabel(gridLayout, ...
    'Text','Move one lever, observe, then reset. Fixed velocity factor = 0.66.', ...
    'WordWrap','on');
controlHint.Layout.Row = 3;
controlHint.Layout.Column = [5 6];

summary = uilabel(gridLayout,'WordWrap','on');
summary.Layout.Row = 4;
summary.Layout.Column = [1 6];

frequencySlider.ValueChangingFcn = @(~,event) ...
    updatePlots(event.Value,lengthSlider.Value);
lengthSlider.ValueChangingFcn = @(~,event) ...
    updatePlots(frequencySlider.Value,event.Value);
frequencySlider.ValueChangedFcn = @(~,~) updateCurrent();
lengthSlider.ValueChangedFcn = @(~,~) updateCurrent();
brokenCheck.ValueChangedFcn = @(~,~) updateCurrent();
resetButton.ButtonPushedFcn = @(~,~) resetBaseline();
updateCurrent();

    function updateCurrent
        updatePlots(frequencySlider.Value,lengthSlider.Value);
    end

    function resetBaseline
        frequencySlider.Value = baselineFrequencyGHz;
        lengthSlider.Value = baselineLengthMm;
        frequencySlider.Enable = 'on';
        lengthSlider.Enable = 'on';
        brokenCheck.Value = false;
        updateCurrent();
    end

    function updatePlots(frequencyGHz,lengthMm)
        if brokenCheck.Value
            effectiveFrequencyGHz = baselineFrequencyGHz;
            effectiveLengthMm = 5*baselineLengthMm;
            frequencySlider.Value = effectiveFrequencyGHz;
            lengthSlider.Value = effectiveLengthMm;
            frequencySlider.Enable = 'off';
            lengthSlider.Enable = 'off';
        else
            effectiveFrequencyGHz = frequencyGHz;
            effectiveLengthMm = lengthMm;
            frequencySlider.Enable = 'on';
            lengthSlider.Enable = 'on';
        end
        out = modelFcn(1e9*effectiveFrequencyGHz,1e-3*effectiveLengthMm,velocityFactor);

        timeS = linspace(0,2/out.frequencyHz,401);
        inputWave = cos(2*pi*out.frequencyHz*timeS);
        outputWave = cos(2*pi*out.frequencyHz*(timeS-out.propagationDelayS));
        cla(waveAxes);
        plot(waveAxes,1e9*timeS,inputWave,'LineWidth',1.2,'DisplayName','Input');
        hold(waveAxes,'on');
        plot(waveAxes,1e9*timeS,outputWave,'LineWidth',1.2, ...
            'DisplayName','Output after line');
        hold(waveAxes,'off');
        grid(waveAxes,'on');
        xlabel(waveAxes,'Time (ns)');
        ylabel(waveAxes,'Normalized voltage (V/V_0)');
        title(waveAxes,sprintf('Time view: delay %.1f ps',1e12*out.propagationDelayS));
        legend(waveAxes,'Location','best');

        frequencyGridGHz = linspace(0.5,2.5,161);
        unwrappedCurveDeg = zeros(size(frequencyGridGHz));
        wrappedCurveDeg = zeros(size(frequencyGridGHz));
        for index = 1:numel(frequencyGridGHz)
            curvePoint = modelFcn(1e9*frequencyGridGHz(index), ...
                out.physicalLengthM,velocityFactor);
            unwrappedCurveDeg(index) = curvePoint.unwrappedTransferPhaseDeg;
            wrappedCurveDeg(index) = curvePoint.wrappedTransferPhaseDeg;
        end
        cla(phaseAxes);
        plot(phaseAxes,frequencyGridGHz,unwrappedCurveDeg,'LineWidth',1.2, ...
            'DisplayName','Unwrapped phase');
        hold(phaseAxes,'on');
        plot(phaseAxes,frequencyGridGHz,wrappedCurveDeg,'--','LineWidth',1.2, ...
            'DisplayName','Wrapped phase');
        plot(phaseAxes,effectiveFrequencyGHz,out.wrappedTransferPhaseDeg,'o', ...
            'MarkerSize',8,'MarkerFaceColor',[0.85 0.33 0.10], ...
            'DisplayName','Selected wrapped phase');
        hold(phaseAxes,'off');
        grid(phaseAxes,'on');
        xlabel(phaseAxes,'Frequency (GHz)');
        ylabel(phaseAxes,'Through phase (degrees)');
        title(phaseAxes,'Phase view: wrapping hides complete cycles');
        legend(phaseAxes,'Location','best');

        cla(lengthAxes);
        bars = bar(lengthAxes,1e3*[out.physicalLengthM out.phaseEquivalentLengthM]);
        if brokenCheck.Value
            bars.FaceColor = [0.85 0.33 0.10];
            decisionText = sprintf([ ...
                'BROKEN preset: a 5 lambda_g/4 path is interpreted from its -90 degree wrapped ' ...
                'phase alone, so it is reported as %.3f mm and is wrong by %.3f mm.'], ...
                1e3*out.phaseEquivalentLengthM, ...
                1e3*(out.physicalLengthM-out.phaseEquivalentLengthM));
            lengthTitle = 'BROKEN: principal equivalent is called actual length';
        else
            bars.FaceColor = [0.47 0.67 0.19];
            decisionText = ['Correct interpretation: preserve unwrapped phase or use phase slope ' ...
                'to recover delay; wrapped phase alone has no whole-cycle count.'];
            lengthTitle = 'Diagnostic: actual versus principal equivalent';
        end
        grid(lengthAxes,'on');
        xticks(lengthAxes,1:2);
        xticklabels(lengthAxes,{'Actual path','Wrapped-phase equivalent'});
        ylabel(lengthAxes,'Physical line length (mm)');
        title(lengthAxes,lengthTitle);

        wholeCycles = floor(out.electricalCycles+1e-12);
        summary.Text = sprintf([ ...
            'Ideal matched, lossless, nondispersive path: f = %.4f GHz, length = %.3f mm, ' ...
            'velocity factor = %.2f, guided wavelength = %.3f mm.\n' ...
            'Delay = %.3f ps; beta*l = %.3f degrees (%.4f cycles); ' ...
            'H phase = %.3f degrees unwrapped and %.3f degrees wrapped in [-180,180).\n' ...
            '|H| = %.6f; complete cycles omitted by the wrapped view = %d.  %s'], ...
            out.frequencyHz/1e9,1e3*out.physicalLengthM,out.velocityFactor, ...
            1e3*out.wavelengthM,1e12*out.propagationDelayS, ...
            out.electricalLengthDeg,out.electricalCycles, ...
            out.unwrappedTransferPhaseDeg,out.wrappedTransferPhaseDeg, ...
            out.transferMagnitude,wholeCycles,decisionText);
    end
end
