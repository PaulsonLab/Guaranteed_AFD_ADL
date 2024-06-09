function ipts = simulateMCPts(x,dt,U,UA,npts)
    

ipts = generateInitialMCPts(zonotope(x),npts);
        
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

Time_Steps = 9;


for j=1:length(U)
    for k=1:Time_Steps
        pts = ipts;
        ipts = [];
        for i=1:length(pts)
            % Inputs
            Tc = U(j,1) + Tcss;
            cAf = U(j,2) + cAfss;
            w1 = rand(1)*0.1-.05;
            w2 = rand(1)*2-1;
            
            % States
            cA = pts(1,i) + cAss;
            Temp = pts(2,i) + Tss;

            % Dynamics
            fcont(1,1) = q/V*(cAf-cA) - k0*exp(-EoverR/Temp)*cA + w1;
            fcont(2,1) = q/V*(Tf-Temp) - dH/(rho*Cp)*k0*exp(-EoverR/Temp)*cA + UA/(V*rho*Cp)*(Tc-Temp) + w2;

            f = pts(:,i) + dt/Time_Steps*fcont;

            ipts = cat(2,ipts,f);
        end
    end
end

end