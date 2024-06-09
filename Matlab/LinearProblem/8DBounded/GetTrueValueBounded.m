function gtv = GetTrueValueBounded(input,urange)
%% USER INPUTS

%disp(train_u)
train_u = input*urange/2;
% horizon
N = length(train_u)/2;

% define list of models
m = {};
A1 = [0.6, 0.2 ; -0.2, 0.7];
B1 = [-0.3861, 0.1994 ; -0.1994, 0.3861];
C1 = [0.7, 0 ; 0, 0.3];
Bw1 = [0.1215, 0.0598 ; 0.0598, 0.1215];
Dv1 = eye(2);
m = addModel(m, A1, B1, C1, Bw1, Dv1, N);
B2 = [-0.3861, 0 ; -0.1994, 0];
m = addModel(m, A1, B2, C1, Bw1, Dv1, N);
B3 = [0, 0.1994 ; 0, 0.3861];
m = addModel(m, A1, B3, C1, Bw1, Dv1, N);
A4 = [0.6, 0 ; -0.2, 0.7];
m = addModel(m, A4, B1, C1, Bw1, Dv1, N);
A5 = [0.6, 0.2 ; 0, 0.7];
m = addModel(m, A5, B1, C1, Bw1, Dv1, N);

% define initial condition zonotope
cx0 = [2;1];
Gx0 = eye(2);
X0 = zonotope([cx0, Gx0]);

% define disturbance zonotope
cw = [0;0];
Gw = 0.1*eye(2);
W = zonotope([cw, Gw]);

% define noise zonotope
cv = [0;0];
Gv = 0.1*eye(2);
V = zonotope([cv, Gv]);

% parameter for separation
ngen = 4; %should be factor of 2 to ensure correct dimensions

% shorthand for dimensions
nm = length(m)+1;
nu = m{1}.nu;

% get required matrices with reduction in zonotope order
afd = separatingInputZonotope(m, X0, W, V, ngen);

YN{1} = zonotope([[0;1.1],[10,0;0,0.1]]);
for i = 1:nm-1
    YN{i+1} = m{i}.CN*(m{i}.AN*afd.X0+m{i}.BN*train_u(:)+m{i}.BwN*afd.WN)+m{i}.DvN*afd.VN;
end

res = 0;

for i = 1:nm-1
    for k = i:nm-1
        check = CheckOverlap(YN{i},YN{k+1});
        if check
            res = 1;
        end
    end
end

gtv = res;

end