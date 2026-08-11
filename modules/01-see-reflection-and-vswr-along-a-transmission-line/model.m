function out = model(Z0,Rload,Xload,lengthWavelengths)
%MODEL Lossless transmission-line voltage standing wave.
arguments
    Z0 (1,1) double {mustBePositive} = 50
    Rload (1,1) double {mustBeNonnegative} = 100
    Xload (1,1) double = 0
    lengthWavelengths (1,1) double {mustBePositive} = 2
end
ZL=Rload+1j*Xload;
gamma=(ZL-Z0)/(ZL+Z0);
z=linspace(0,lengthWavelengths,800);
V=exp(-1j*2*pi*z)+gamma.*exp(1j*2*pi*z);
I=(exp(-1j*2*pi*z)-gamma.*exp(1j*2*pi*z))/Z0;
rho=abs(gamma);
if rho>=1
    vswr=inf;
else
    vswr=(1+rho)/(1-rho);
end
theta=linspace(0,2*pi,400);
out=struct('ZL',ZL,'gamma',gamma,'rho',rho,'vswr',vswr,'z',z, ...
    'voltage',V,'current',I,'unitCircle',exp(1j*theta),'Z0',Z0);
end
