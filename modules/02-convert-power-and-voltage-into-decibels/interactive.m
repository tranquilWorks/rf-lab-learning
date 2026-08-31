function interactive
%INTERACTIVE Explore power, voltage, and resistance contributions to dB.
modelFcn = @model;
referencePowerW = 1e-3;
referenceResistanceOhm = 50;
referenceVoltageRms = sqrt(referencePowerW*referenceResistanceOhm);
baselinePowerRatio = 2;
baselineVoltageRatio = sqrt(2);
baselineResistanceOhm = 50;

fig = uifigure('Name','P02 Power and Voltage in Decibels','Position',[100 100 1180 700]);
gridLayout = uigridlayout(fig,[4 6]);
gridLayout.RowHeight = {'1x',24,58,105};
gridLayout.ColumnWidth = {'1x','1x','1x','1x','1x','1x'};

curveAxes = uiaxes(gridLayout);
curveAxes.Layout.Row = 1;
curveAxes.Layout.Column = [1 3];
comparisonAxes = uiaxes(gridLayout);
comparisonAxes.Layout.Row = 1;
comparisonAxes.Layout.Column = [4 6];

powerLabel = uilabel(gridLayout,'Text','Independent power ratio P/P_ref');
powerLabel.Layout.Row = 2;
powerLabel.Layout.Column = [1 2];
voltageLabel = uilabel(gridLayout,'Text','Independent RMS-voltage ratio V/V_ref');
voltageLabel.Layout.Row = 2;
voltageLabel.Layout.Column = [3 4];
resistanceLabel = uilabel(gridLayout,'Text','Signal resistance (ohms)');
resistanceLabel.Layout.Row = 2;
resistanceLabel.Layout.Column = 5;
brokenCheck = uicheckbox(gridLayout,'Text','Break: ignore impedance','Value',false);
brokenCheck.Layout.Row = 2;
brokenCheck.Layout.Column = 6;

powerSlider = uislider(gridLayout,'Limits',[0.1 10],'Value',baselinePowerRatio);
powerSlider.Layout.Row = 3;
powerSlider.Layout.Column = [1 2];
voltageSlider = uislider(gridLayout,'Limits',[0.1 3],'Value',baselineVoltageRatio);
voltageSlider.Layout.Row = 3;
voltageSlider.Layout.Column = [3 4];
resistanceSlider = uislider(gridLayout,'Limits',[25 200],'Value',baselineResistanceOhm);
resistanceSlider.Layout.Row = 3;
resistanceSlider.Layout.Column = 5;
resetButton = uibutton(gridLayout,'Text','Reset baseline');
resetButton.Layout.Row = 3;
resetButton.Layout.Column = 6;

summary = uilabel(gridLayout,'WordWrap','on');
summary.Layout.Row = 4;
summary.Layout.Column = [1 6];

powerSlider.ValueChangingFcn = @(~,event) updatePlots(event.Value,voltageSlider.Value,resistanceSlider.Value);
voltageSlider.ValueChangingFcn = @(~,event) updatePlots(powerSlider.Value,event.Value,resistanceSlider.Value);
resistanceSlider.ValueChangingFcn = @(~,event) updatePlots(powerSlider.Value,voltageSlider.Value,event.Value);
powerSlider.ValueChangedFcn = @(~,~) updateCurrent();
voltageSlider.ValueChangedFcn = @(~,~) updateCurrent();
resistanceSlider.ValueChangedFcn = @(~,~) updateCurrent();
brokenCheck.ValueChangedFcn = @(~,~) updateCurrent();
resetButton.ButtonPushedFcn = @(~,~) resetBaseline();
updateCurrent();

    function updateCurrent
        updatePlots(powerSlider.Value,voltageSlider.Value,resistanceSlider.Value);
    end

    function resetBaseline
        powerSlider.Value = baselinePowerRatio;
        voltageSlider.Value = baselineVoltageRatio;
        resistanceSlider.Value = baselineResistanceOhm;
        brokenCheck.Value = false;
        updateCurrent();
    end

    function updatePlots(powerRatio,voltageRatio,resistanceOhm)
        powerW = powerRatio*referencePowerW;
        voltageRms = voltageRatio*referenceVoltageRms;
        out = modelFcn(powerW,voltageRms,resistanceOhm,referencePowerW, ...
            referenceVoltageRms,referenceResistanceOhm);

        ratioGrid = logspace(-1,1,161);
        cla(curveAxes);
        semilogx(curveAxes,ratioGrid,10*log10(ratioGrid),'LineWidth',1.3, ...
            'DisplayName','Power: 10 log_{10}(ratio)');
        hold(curveAxes,'on');
        semilogx(curveAxes,ratioGrid,20*log10(ratioGrid),'--','LineWidth',1.3, ...
            'DisplayName','Voltage: 20 log_{10}(ratio)');
        plot(curveAxes,powerRatio,out.powerDb,'o','MarkerFaceColor',[0 0.45 0.74], ...
            'DisplayName','Selected power ratio');
        plot(curveAxes,voltageRatio,out.voltageDb,'s','MarkerFaceColor',[0.85 0.33 0.10], ...
            'DisplayName','Selected voltage ratio');
        hold(curveAxes,'off');
        grid(curveAxes,'on');
        xlabel(curveAxes,'Linear ratio');
        ylabel(curveAxes,'Relative level (dB)');
        title(curveAxes,'The multiplier controls the logarithmic slope');
        legend(curveAxes,'Location','northwest');

        if brokenCheck.Value
            reportedVoltagePowerDb = out.voltageDb;
            caseText = sprintf(['BROKEN: the third bar omits the %+.3f dB resistance correction. ' ...
                'Its %+.3f dB error can coincidentally match the independent direct-power input.'], ...
                out.impedanceCorrectionDb,out.sameImpedanceAssumptionErrorDb);
            comparisonTitle = 'Broken view: impedance is ignored';
        else
            reportedVoltagePowerDb = out.voltagePowerDb;
            caseText = sprintf('Correct: voltage-derived power includes the %+.3f dB resistance correction.', ...
                out.impedanceCorrectionDb);
            comparisonTitle = 'Direct and voltage-derived dB views';
        end

        cla(comparisonAxes);
        bars = bar(comparisonAxes,[out.powerDb out.voltageDb reportedVoltagePowerDb]);
        if brokenCheck.Value
            bars.FaceColor = 'flat';
            bars.CData(3,:) = [0.85 0.33 0.10];
        end
        grid(comparisonAxes,'on');
        xticks(comparisonAxes,1:3);
        xticklabels(comparisonAxes,{'Independent P input','RMS voltage','Power reported from V'});
        ylabel(comparisonAxes,'Relative level (dB)');
        title(comparisonAxes,comparisonTitle);

        summary.Text = sprintf([ ...
            'Independent measurement inputs; compare them only through the difference metric.  ' ...
            'Reference: %.3f mW, %.6f V RMS, %.1f ohms.  ' ...
            'Signal: %.3f mW (%+.3f dB, %+.3f dBm), %.6f V RMS (%+.3f dB), %.1f ohms.\n' ...
            'Voltage-derived power: %.3f mW (%+.3f dB).  Direct-versus-derived difference: %+.3f dB.\n%s'], ...
            1e3*referencePowerW,referenceVoltageRms,referenceResistanceOhm, ...
            1e3*out.powerW,out.powerDb,out.powerDbm,out.voltageRms,out.voltageDb, ...
            out.resistanceOhm,1e3*out.powerFromVoltageW,out.voltagePowerDb, ...
            out.consistencyErrorDb,caseText);
    end
end
