function R = dompc_cstrgetTrueValueFG(input,Frange,Q_dotrange)

    X0 = zonotope([[0 ; 0 ; 0 ; 0], diag([0.6 ; 0.6 ; 3.39 ; 3.34])]); %Initial State
    W = zonotope([[0 ; 0], diag([0.04e12 ; 0.27e9])]); %Disturbance

    N = length(input)/2;
    
    U = [];
    for i=1:N
        U = cat(1,U,[input(i*2-1)*Frange/2,input(i*2)*Q_dotrange/2]);
    end


    C_A0 = (5.7+4.5)/2.0*1.0; % Concentration of A in input Upper bound 5.7 lower bound 4.5 [mol/l]

    R = {};
    %Nominal
    R{end+1} = dompc_cstr_multi_step_reach(X0,U,W,C_A0,N);
    %Flow Control Fault
    F = zeros(length(U),1);
    R{end+1} = dompc_cstr_multi_step_reach(X0,cat(2,F,U(:,2)),W,C_A0,N);
    %Heat Control Fault
    Q_dot = zeros(length(U),1);
    R{end+1} = dompc_cstr_multi_step_reach(X0,cat(2,U(:,1),Q_dot),W,C_A0,N);
    %Low Inlet Concentration
    C_A0_1 = 4.5;
    R{end+1} = dompc_cstr_multi_step_reach(X0,U,W,C_A0_1,N);
    %High Inlet Concentration
    C_A0_2 = 5.7;
    R{end+1} = dompc_cstr_multi_step_reach(X0,U,W,C_A0_2,N);

end