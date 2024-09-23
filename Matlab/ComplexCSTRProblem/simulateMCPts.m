function ipts = simulateMCPts(x,dt,U,C_A0,npts)
    

ipts = generateInitialMCPts(zonotope(x),npts);
        
% Certain parameters
K0_ab = 1.287e12; % K0 [h^-1]
K0_bc = 1.287e12; % K0 [h^-1]
K0_ad = 9.043e9; % K0 [l/mol.h]
R_gas = 8.3144621e-3; % Universal gas constant
E_A_ab = 9758.3*1.00; % R_gas# [kj/mol]
E_A_bc = 9758.3*1.00; % R_gas# [kj/mol]
E_A_ad = 8560.0*1.0; % R_gas# [kj/mol]
H_R_ab = 4.2; % [kj/mol A]
H_R_bc = -11.0; % [kj/mol B] Exothermic
H_R_ad = -41.85; % [kj/mol A] Exothermic
Rou = 0.9342; % Density [kg/l]
Cp = 3.01; % Specific Heat capacity [kj/Kg.K]
Cp_k = 2.0; % Coolant heat capacity [kj/kg.k]
A_R = 0.215; % Area of reactor wall [m^2]
V_R = 10.01; %0.01 # Volume of reactor [l]
m_k = 5.0; % Coolant mass[kg]
T_in = 403.15; % Temp of inflow [Celsius]
K_w = 4032.0; % [kj/h.m^2.K]


% Steady state conditions
C_ass = 3.741722281158712;
C_bss = 0.6;
T_Rss = 339.0730762317452;
T_Kss = 334.0041582935749;
Fss = 2.137399577359103;
Q_dotss = -4394.14358224101;

Time_Steps = 10;


for j=1:size(U,1)
    for k=1:Time_Steps
        pts = ipts;
        ipts = [];
        for i=1:length(pts)
            % Inputs
            F = U(j,1) + Fss;
            Q_dot = U(j,2) + Q_dotss;
            w1 = (rand(1)*0.04-0.02)*1e12;
            w2 = (rand(1)*0.04-0.02)*1e12;
            w3 = (rand(1)*0.27-0.135)*1e9;
            
            % States
            C_a = pts(1,i) + C_ass;
            C_b = pts(2,i) + C_bss;
            T_R = pts(3,i) + T_Rss;
            T_K = pts(4,i) + T_Kss;
            
            %Uncertain terms
            K_1 = (K0_ab + w1)*exp(-E_A_ab/T_R);
            K_2 =  (K0_bc + w2)*exp(-E_A_bc/T_R);
            K_3 = (K0_ad + w3)*exp(-E_A_ad/T_R);

            % Dynamics
            T_dif = T_R - T_K;
            fcont(1,1) = F*(C_A0 - C_a) -K_1*C_a - K_3*(C_a^2);
            fcont(2,1) = -F*C_b + K_1*C_a - K_2*C_b;
            fcont(3,1) = ((K_1*C_a*H_R_ab + K_2*C_b*H_R_bc + K_3*(C_a^2)*H_R_ad)/(-Rou*Cp)) + F*(T_in-T_R) +(((K_w*A_R)*(-T_dif))/(Rou*Cp*V_R));
            fcont(4,1) = (Q_dot + K_w*A_R*(T_dif))/(m_k*Cp_k);

            f = pts(:,i) + dt/Time_Steps*fcont;

            ipts = cat(2,ipts,f);
        end
    end
end

end