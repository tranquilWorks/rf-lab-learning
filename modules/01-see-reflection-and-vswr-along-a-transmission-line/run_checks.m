function run_checks
m=model(50,50,0,1);
assert(abs(m.gamma)<1e-12,'Matched load must have zero reflection.');
a=model(50,25,0,1);
b=model(50,100,0,1);
assert(abs(a.vswr-b.vswr)<1e-12,'25 and 100 ohm loads should share VSWR magnitude.');
assert(sign(real(a.gamma))~=sign(real(b.gamma)),'Their reflection phases should differ.');
open=model(50,1e12,0,1);
assert(open.rho>0.999,'Large load should approach open-circuit reflection.');
disp('P01 checks passed.');
end
