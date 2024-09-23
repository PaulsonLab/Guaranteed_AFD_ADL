function gtv = dompc_cstrgetTrueValue(input,Frange,Q_dotrange)

    X0 = zonotope([[0 ; 0 ; 0 ; 0], diag([0.6 ; 0.6 ; 3.39 ; 3.34])]); %Initial State
    W = zonotope([[0 ; 0], diag([0.04e12 ; 0.27e9])]); %Disturbance

    N = length(input)/2;
    
    U = [];
    for i=1:N
        U = cat(1,U,[input(i*2-1)*Frange/2,input(i*2)*Q_dotrange/2]);
    end

    C_A0 = 5.1;
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

    nm = length(R);

    R2d = {};
    for i=1:nm
        c = [R{i}.c(1,:);R{i}.c(3,:)];
        g = [R{i}.G(1,:);R{i}.G(3,:)];
        R2d{end+1} = zonotope([c,g]);
    end

    gtv = 0;
    for i=1:nm-1
        for k=i:nm-1
            c = CheckOverlap(R2d{i},R2d{k+1});
            if c
                gtv = 1;
            end
        end
    end

end