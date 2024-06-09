function f = cstrDT(x,u,T,UA)

% Parameters
Tf = 350;
V = 100;
EoverR = 8750;
dH = -5e4;
k0 = 7.2e10;
rho = 1000;
Cp = 0.239;
q = 100;

% Steady state conditions
cAss = 0.5;
cAfss = 1;
Tss = 350;
Tcss = 300;

% Inputs
Tc = u(1) + Tcss;
cAf = u(2) + cAfss;
w1 = u(3);
w2 = u(4);

% States
cA = x(1) + cAss;
Temp = x(2) + Tss;

% Dynamics
fcont(1,1) = q/V*(cAf-cA) - k0*exp(-EoverR/Temp)*cA + w1;
fcont(2,1) = q/V*(Tf-Temp) - dH/(rho*Cp)*k0*exp(-EoverR/Temp)*cA + UA/(V*rho*Cp)*(Tc-Temp) + w2;

% Discretize
f = x + T*fcont;

end