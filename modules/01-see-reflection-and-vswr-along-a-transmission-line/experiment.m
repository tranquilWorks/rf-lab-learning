%% P01 - See Reflection and VSWR Along a Transmission Line
close all; clc;
out=model(50,100,0,2);

figure('Name','P01 baseline');
subplot(2,1,1);
plot(out.z,abs(out.voltage),'LineWidth',1.3); grid on;
xlabel('Distance from load (wavelengths)'); ylabel('|V|');
title(sprintf('Standing wave, |Gamma| = %.3f, VSWR = %.2f',out.rho,out.vswr));
subplot(2,1,2);
plot(real(out.unitCircle),imag(out.unitCircle),':'); hold on;
plot(real(out.gamma),imag(out.gamma),'o','MarkerFaceColor',[0.85 0.33 0.10]);
axis equal; grid on; xlabel('Real Gamma'); ylabel('Imag Gamma');
title('Reflection coefficient magnitude and phase');

%% Sweep 1 - resistance
R=[25 50 100 200];
figure('Name','P01 resistance sweep'); hold on; grid on;
for i=1:numel(R)
    s=model(50,R(i),0,1);
    plot(s.z,abs(s.voltage),'LineWidth',1.1,'DisplayName', ...
        sprintf('R_L %g ohm, VSWR %.2f',R(i),s.vswr));
end
xlabel('Distance (wavelengths)'); ylabel('|V|'); title('Resistance controls mismatch');
legend('Location','best');

%% Sweep 2 - reactance
X=[-100 -25 0 25 100];
figure('Name','P01 reactance sweep'); hold on; grid on; axis equal;
plot(real(out.unitCircle),imag(out.unitCircle),':','DisplayName','|Gamma| = 1');
for i=1:numel(X)
    s=model(50,50,X(i),1);
    plot(real(s.gamma),imag(s.gamma),'o','DisplayName',sprintf('X_L %+g ohm',X(i)));
end
xlabel('Real Gamma'); ylabel('Imag Gamma'); title('Reactance rotates the reflection');
legend('Location','best');

%% Broken case - report VSWR only
a=model(50,25,0,1);
b=model(50,100,0,1);
figure('Name','P01 broken case');
plot(a.z,abs(a.voltage),'LineWidth',1.2,'DisplayName','25 ohm load'); hold on;
plot(b.z,abs(b.voltage),'--','LineWidth',1.2,'DisplayName','100 ohm load');
grid on; xlabel('Distance (wavelengths)'); ylabel('|V|');
title(sprintf('Broken: both have VSWR %.1f, but reflection phase differs',a.vswr));
legend('Location','best');

matched=model(50,50,0,1);
assert(abs(matched.gamma)<eps,'Matched load must have zero reflection.');
