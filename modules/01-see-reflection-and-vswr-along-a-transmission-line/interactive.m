function interactive
fig=uifigure('Name','P01 Transmission Line Reflection','Position',[100 100 1120 720]);
g=uigridlayout(fig,[3 5]); g.RowHeight={'1x','1x',100};
axV=uiaxes(g); axV.Layout.Row=1; axV.Layout.Column=[1 5];
axG=uiaxes(g); axG.Layout.Row=2; axG.Layout.Column=[1 4];
summary=uilabel(g,'WordWrap','on'); summary.Layout.Row=2; summary.Layout.Column=5;

z0S=uislider(g,'Limits',[20 100],'Value',50); z0S.Layout.Row=3; z0S.Layout.Column=1;
rS=uislider(g,'Limits',[0 250],'Value',100); rS.Layout.Row=3; rS.Layout.Column=2;
xS=uislider(g,'Limits',[-200 200],'Value',0); xS.Layout.Row=3; xS.Layout.Column=3;
lS=uislider(g,'Limits',[0.25 5],'Value',2); lS.Layout.Row=3; lS.Layout.Column=4;
summary2=uilabel(g,'Text','Z0 | Rload | Xload | line length','WordWrap','on');
summary2.Layout.Row=3; summary2.Layout.Column=5;
controls=[z0S rS xS lS];
for i=1:numel(controls)
    controls(i).ValueChangingFcn=@(~,~) updatePlots();
    controls(i).ValueChangedFcn=@(~,~) updatePlots();
end
updatePlots();

    function updatePlots
        out=model(z0S.Value,rS.Value,xS.Value,lS.Value);
        cla(axV); plot(axV,out.z,abs(out.voltage),'LineWidth',1.3);
        grid(axV,'on'); xlabel(axV,'Distance from load (wavelengths)'); ylabel(axV,'|V|');
        title(axV,'Forward plus reflected wave');

        cla(axG); plot(axG,real(out.unitCircle),imag(out.unitCircle),':');
        hold(axG,'on'); plot(axG,real(out.gamma),imag(out.gamma),'o','MarkerFaceColor',[0.85 0.33 0.10]);
        hold(axG,'off'); axis(axG,'equal'); grid(axG,'on');
        xlabel(axG,'Real Gamma'); ylabel(axG,'Imag Gamma'); title(axG,'Reflection coefficient');

        if isinf(out.vswr), vs='Inf'; else, vs=sprintf('%.2f',out.vswr); end
        summary.Text=sprintf(['ZL = %.1f %+.1fj ohm\nGamma = %.3f %+.3fj\n' ...
            '|Gamma| = %.3f\nVSWR = %s'],real(out.ZL),imag(out.ZL), ...
            real(out.gamma),imag(out.gamma),out.rho,vs);
    end
end
