function interactive
%INTERACTIVE Explore resistance and reactance in a conjugate power match.
modelFcn = @model;
sourceVoltageRms = 1;
sourceResistanceOhm = 50;
sourceReactanceOhm = 50;
baselineLoadResistanceOhm = 50;
baselineLoadReactanceOhm = -50;

fig = uifigure('Name','P03 Match a Load to a Source','Position',[100 100 1180 700]);
gridLayout = uigridlayout(fig,[4 6]);
gridLayout.RowHeight = {'1x',24,58,125};
gridLayout.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

powerAxes = uiaxes(gridLayout);
powerAxes.Layout.Row = 1;
powerAxes.Layout.Column = [1 3];
mismatchAxes = uiaxes(gridLayout);
mismatchAxes.Layout.Row = 1;
mismatchAxes.Layout.Column = [4 6];

resistanceLabel = uilabel(gridLayout,'Text','Load resistance R_L (ohms)');
resistanceLabel.Layout.Row = 2;
resistanceLabel.Layout.Column = [1 2];
reactanceLabel = uilabel(gridLayout,'Text','Load reactance X_L (ohms)');
reactanceLabel.Layout.Row = 2;
reactanceLabel.Layout.Column = [3 4];
brokenCheck = uicheckbox(gridLayout,'Text','Break: copy source reactance','Value',false);
brokenCheck.Layout.Row = 2;
brokenCheck.Layout.Column = 5;
resetButton = uibutton(gridLayout,'Text','Reset conjugate-match baseline');
resetButton.Layout.Row = 2;
resetButton.Layout.Column = 6;

resistanceSlider = uislider(gridLayout,'Limits',[1 200],'Value',baselineLoadResistanceOhm);
resistanceSlider.Layout.Row = 3;
resistanceSlider.Layout.Column = [1 2];
reactanceSlider = uislider(gridLayout,'Limits',[-150 100],'Value',baselineLoadReactanceOhm);
reactanceSlider.Layout.Row = 3;
reactanceSlider.Layout.Column = [3 4];
controlHint = uilabel(gridLayout,'Text','Move one load lever, observe, then reset.','WordWrap','on');
controlHint.Layout.Row = 3;
controlHint.Layout.Column = [5 6];

summary = uilabel(gridLayout,'WordWrap','on');
summary.Layout.Row = 4;
summary.Layout.Column = [1 6];

resistanceSlider.ValueChangingFcn = @(~,event) updatePlots(event.Value,reactanceSlider.Value);
reactanceSlider.ValueChangingFcn = @(~,event) updatePlots(resistanceSlider.Value,event.Value);
resistanceSlider.ValueChangedFcn = @(~,~) updateCurrent();
reactanceSlider.ValueChangedFcn = @(~,~) updateCurrent();
brokenCheck.ValueChangedFcn = @(~,~) updateCurrent();
resetButton.ButtonPushedFcn = @(~,~) resetBaseline();
updateCurrent();

    function updateCurrent
        updatePlots(resistanceSlider.Value,reactanceSlider.Value);
    end

    function resetBaseline
        resistanceSlider.Value = baselineLoadResistanceOhm;
        reactanceSlider.Value = baselineLoadReactanceOhm;
        reactanceSlider.Enable = 'on';
        brokenCheck.Value = false;
        updateCurrent();
    end

    function updatePlots(loadResistanceOhm,requestedLoadReactanceOhm)
        if brokenCheck.Value
            effectiveLoadReactanceOhm = sourceReactanceOhm;
            reactanceSlider.Enable = 'off';
            caseText = ['BROKEN: X_L copies X_s instead of changing sign; ' ...
                'the reactance slider is intentionally bypassed.'];
        else
            effectiveLoadReactanceOhm = requestedLoadReactanceOhm;
            reactanceSlider.Enable = 'on';
            caseText = 'Correct model: the load uses the selected resistance and reactance.';
        end

        out = modelFcn(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
            loadResistanceOhm,effectiveLoadReactanceOhm);

        resistanceGridOhm = linspace(1,200,161);
        transferCurvePercent = zeros(size(resistanceGridOhm));
        for index = 1:numel(resistanceGridOhm)
            curvePoint = modelFcn(sourceVoltageRms,sourceResistanceOhm,sourceReactanceOhm, ...
                resistanceGridOhm(index),effectiveLoadReactanceOhm);
            transferCurvePercent(index) = 100*curvePoint.powerTransferRatio;
        end

        cla(powerAxes);
        plot(powerAxes,resistanceGridOhm,transferCurvePercent,'LineWidth',1.3, ...
            'DisplayName','Transfer versus R_L');
        hold(powerAxes,'on');
        plot(powerAxes,loadResistanceOhm,100*out.powerTransferRatio,'o', ...
            'MarkerSize',8,'MarkerFaceColor',[0.85 0.33 0.10],'DisplayName','Selected load');
        hold(powerAxes,'off');
        grid(powerAxes,'on');
        xlabel(powerAxes,'Load resistance R_L (ohms)');
        ylabel(powerAxes,'Available-power transfer tau (%)');
        title(powerAxes,sprintf('Resistance view at X_L = %+.1f ohms',effectiveLoadReactanceOhm));
        legend(powerAxes,'Location','best');

        unitCircle = exp(1j*linspace(0,2*pi,201));
        cla(mismatchAxes);
        plot(mismatchAxes,real(unitCircle),imag(unitCircle),':','DisplayName','|Gamma_m| = 1');
        hold(mismatchAxes,'on');
        plot(mismatchAxes,0,0,'+','MarkerSize',12,'LineWidth',1.5, ...
            'DisplayName','Conjugate match');
        plot(mismatchAxes,real(out.powerWaveGamma),imag(out.powerWaveGamma),'o', ...
            'MarkerSize',8,'MarkerFaceColor',[0 0.45 0.74],'DisplayName','Selected Gamma_m');
        hold(mismatchAxes,'off');
        axis(mismatchAxes,'equal');
        xlim(mismatchAxes,[-1.05 1.05]);
        ylim(mismatchAxes,[-1.05 1.05]);
        grid(mismatchAxes,'on');
        xlabel(mismatchAxes,'Real Gamma_m');
        ylabel(mismatchAxes,'Imaginary Gamma_m');
        title(mismatchAxes,'P01 connection: mismatch moves away from zero');
        legend(mismatchAxes,'Location','best');

        summary.Text = sprintf([ ...
            'Fixed source: %.3f V RMS, Z_s = %.1f %+.1fj ohms; target Z_L = %.1f %+.1fj ohms.  ' ...
            'Selected Z_L = %.1f %+.1fj ohms; net X = %+.1f ohms.\n' ...
            'Current: %.3f mA RMS at %+.2f degrees; |V_L| = %.4f V RMS.  ' ...
            'Load: %.3f mW (%+.3f dBm) of %.3f mW available; tau = %.2f%%; mismatch loss = %.3f dB.\n' ...
            'The load receives %.1f%% of source-plus-load resistive dissipation; this is not lossless efficiency.  %s'], ...
            sourceVoltageRms,real(out.sourceImpedanceOhm),imag(out.sourceImpedanceOhm), ...
            real(out.conjugateMatchOhm),imag(out.conjugateMatchOhm), ...
            real(out.loadImpedanceOhm),imag(out.loadImpedanceOhm),out.netReactanceOhm, ...
            1e3*out.currentRmsA,out.currentPhaseDeg,out.loadVoltageRms, ...
            1e3*out.loadPowerW,out.loadPowerDbm,1e3*out.availablePowerW, ...
            100*out.powerTransferRatio,out.mismatchLossDb, ...
            100*out.loadShareOfDissipatedPower,caseText);
    end
end
