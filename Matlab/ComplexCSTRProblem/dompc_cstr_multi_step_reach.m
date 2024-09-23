
function R = dompc_cstr_multi_step_reach(X0,U,W,C_A0,N)

% N = 10; % number of steps
% X0 = zonotope([[-0.15 ; -45], diag([0;0])]); % initial state zonotope
% W = zonotope([0;0], diag([0.1 ; 2.0])); % disturbance zonotope
% u = 0; % constant value for input (for now)

%N = 3; % number of steps
%X0 = zonotope([[0 ; 0], diag([0.025 ; 1/2])]); % initial state zonotope
%W = zonotope([0;0], diag([0.1/2 ; 2.0/2])); % disturbance zonotope
%U = [10, 5 ; 10, 5 ; 10, 5]; %(Tc, q) pairs at every time point
%UA = 5e4;
X = cell(N+1,1);
X{1} = X0;
for i = 1:N
    X{i+1} = dompc_cstr_one_step_reach(X{i}, U(i,:)', W, C_A0);
end

%figure; hold on;
%colors = {'k', 'b', 'r', 'g'};
%for i = 1:N
%    plot(X{i}, [1,2], colors{i}, 'linewidth', 2); %[1,2], 'FaceColor', [0.5, 0.5, 0.5]
%end
%xlabel('C-C_0');
%ylabel('T-T_0');

R = X{end};

end
