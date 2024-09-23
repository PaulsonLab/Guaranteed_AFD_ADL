
X0 = zonotope([[0 ; 0 ; 0 ; 0], diag([0.6 ; 0.6 ; 3.39 ; 3.34])]);

W = zonotope([[0 ; 0], diag([0.04 ; 0.27])]);

%Steady state input is
%U = [0.48426430225372314, -0.6043612241744995, 0.5737351953983307, -0.6454931676387787, 0.6253147006034851, -0.561504590511322]; %6D 3 fault soln
%U = [-0.3 , 0.3 , -0.3 , 0.3 , -0.3 , 0.3 , -0.3 , 0.3 , -0.3 , 0.3];
%U = [0.037850890308618546, -0.15233804285526276, 0.10909182578325272, -0.1497896909713745, 0.12135255336761475, -0.18195468187332153, 0.15116238594055176, -0.2067335844039917, 0.19393543899059296, -0.13913887739181519]; %C_A0_1 = 4.0, C_A0_2 = 6.2

%Incorrect k0
%Initial separating set
%U = [-0.160759442878704,-0.799407587200908,0.157333033867095,-0.596388098453466,0.370928388284255,-0.122211348086898,0.621657772329675,-0.226554128047226,0.877542263685388,-0.832916273274745]; %Initial separating set
%BES Soln
%U = [0.049656275659799576, -0.18285775184631348, 0.017987702041864395, -0.1353011578321457, 0.011368188075721264, -0.15167167782783508, 0.16859862208366394, -0.15139572322368622, 0.246567964553833, -0.1719609946012497]; %Final separating set
%ES Soln
%U = [ 0.3366, -0.3128,  0.3360, -0.2823,  0.1328, -0.7211,  0.1208, -0.5545, 0.0473, -0.4306];
%PL Soln
%U = [-0.1608, -0.7994,  0.1573, -0.5964,  0.3709, -0.1222,  0.6217, -0.2266, 0.8775, -0.8329];

%BES Soln
%U = [-0.02397619 -0.21386676  0.06077072 -0.14033371  0.01555564 -0.19066337 0.08605538 -0.13039684  0.21631594 -0.06537761];
%ES Soln
%U = [ 0.26287445 -0.79516804 -0.11865108 -0.07583506  0.0931478  -0.3617043 0.26856938 -0.08622503  0.42209134 -0.5858204 ];
%PL Soln
U = [-0.29681936 -0.9011062  -0.15873109  0.13112547  0.09869198 -0.61859494 0.49092746  0.25719744  0.40598786 -0.33533132];

Frange = 4.27; % Ranges from 0 to 4.27 (Steady state is 2.137 but F can really range from 0 to 100)
Q_dotrange = 8211.72; % Ranges from -8500 to -288.28 (Steady state is -4394.14 but Q_dot can really range from -8500 to 0)
N = length(U)/2; 



inpt = [];
for i=1:N
    inpt = cat(1,inpt,[U(i*2-1)*Frange/2,U(i*2)*Q_dotrange/2]);
end


R = dompc_cstrgetTrueValueFG(U,Frange,Q_dotrange);

npts = 100000;
dt = 0.16;

C_A0 = (5.7+4.5)/2.0*1.0; % Concentration of A in input Upper bound 5.7 lower bound 4.5 [mol/l]

mcpts = {};
label = {};

%Nominal
mcpts{end+1} = simulateMCPts(X0,dt,inpt,C_A0,npts);
label{end+1} = 'Nominal';

%Flow Control Fault
F = zeros(length(inpt),1);
mcpts{end+1} = simulateMCPts(X0,dt,cat(2,F,inpt(:,2)),C_A0,npts);
label{end+1} = 'Flow Control';

%Heat Control Fault
Q_dot = zeros(length(inpt),1);
mcpts{end+1} = simulateMCPts(X0,dt,cat(2,inpt(:,1),Q_dot),C_A0,npts);
label{end+1} = 'Q_{dot} Control';

%Low concentration input
C_A0_1 = 4.5;
mcpts{end+1} = simulateMCPts(X0,dt,inpt,C_A0_1,npts);
label{end+1} = 'Low C_A0';

%High concentration input
C_A0_2 = 5.7;
mcpts{end+1} = simulateMCPts(X0,dt,inpt,C_A0_2,npts);
label{end+1} = 'High C_A0';

figure;
ax = gca;
ax.FontSize = 14; 
set(gcf,'color','white')
hold on;
for i=1:length(mcpts)
    plot(R{i},[1,3],'Color','k','linewidth',3)
    label = [{''},label];
end
colors = {'b','g','c','r','m','k'};
for i=1:length(mcpts)
    scatter(mcpts{i}(1,:),mcpts{i}(3,:),['o' colors{i}])
end
legend(label,'Location','southwest')
xlabel('C_a-C_a0','FontSize',18)
ylabel('T_R-T_R0','FontSize',18)
xlim([-1.3,1.4])
ylim([-26,22])
grid on;

export_fig 10D_do-mpc-CSTR_PL.pdf
