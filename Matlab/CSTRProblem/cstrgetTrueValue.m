function gtv = cstrgetTrueValue(input,trange,crange)

    X0 = zonotope([[0 ; 0], diag([0.0025 ; 0.05])]); % initial state zonotope
    W = zonotope([0;0], diag([0.1/2 ; 2.0/2])); % disturbance zonotope

    N = length(input)/2;
    
    U = [];
    for i=1:N
        U = cat(1,U,[input(i*2-1)*trange/2,input(i*2)*crange/2]);
    end

    R = {};
    %Nominal
    UA = 5e4;
    R{end+1} = cstr_multi_step_reach(X0,W,U,UA,N);
    %Temperature Contorl Fault
    T1 = zeros(length(U),1);
    R{end+1} = cstr_multi_step_reach(X0,W,cat(2,T1,U(:,2)),UA,N);
    %Pump Control Fault
    Caf1 = zeros(length(U),1);
    R{end+1} = cstr_multi_step_reach(X0,W,cat(2,U(:,1),Caf1),UA,N);
    %Reactor Wall Buildup Fault (Increase UA)
    UA1 = 6e4;
    R{end+1} = cstr_multi_step_reach(X0,W,U,UA1,N);
 
    %Remved the concentration faults because resulting zonotopes were
    %rather linear
    %Feed Below Concentration Spec
    %R{end+1} = getcstrFinalSet(x,u,dt,T_c0,q,UA,0.9);
    %Feed Above Concentration Spec
    %R{end+1} = getcstrFinalSet(x,u,dt,T_c0,q,UA,1.1);

    nm = length(R);

    gtv = 0;
    for i=1:nm-1
        for k=i:nm-1
            c = CheckOverlap(R{i},R{k+1});
            if c
                gtv = 1;
            end
        end
    end

end