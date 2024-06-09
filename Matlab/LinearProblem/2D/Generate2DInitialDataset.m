
clear

%% USER INPUTS

% horizon
dim = 2;
train_points=32;
u_range = 20;

p = sobolset(dim);
sp = scramble(p,'MatousekAffineOwen');
train_u = net(sp,train_points).'*2-1;
%train_u = Generate_Set(2,-1,1,100,[]);
N = dim/2;

% define list of models
m = {};    A1 = [0.6, 0.2 ; -0.2, 0.7];
B1 = [-0.3861, 0.1994 ; -0.1994, 0.3861];
C1 = [0.7, 0 ; 0, 0.3];
Bw1 = [0.1215, 0.0598 ; 0.0598, 0.1215];
Dv1 = eye(2);
m = addModel(m, A1, B1, C1, Bw1, Dv1, N);
B2 = [-0.3861, 0 ; -0.1994, 0];
m = addModel(m, A1, B2, C1, Bw1, Dv1, N);
B3 = [0, 0.1994 ; 0, 0.3861];
m = addModel(m, A1, B3, C1, Bw1, Dv1, N);

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


% constraints on inputs
u_min = -2.5;
u_max = 2.5;

% parameter for separation
ngen = 4; %should be factor of 2 to ensure correct dimensions

%% CONSTRUCT SEPARATING INPUT OPTIMIZATION PROBLEM

% shorthand for dimensions
nm = length(m);
nu = m{1}.nu;

% get required matrices with reduction in zonotope order
afd = separatingInputZonotope(m, X0, W, V, ngen);


% plot N step output reachable sets
YN = cell(nm,1);


%generates pseudorandom set

co = ones(nm-1,nm-1)*10;
y = zeros(train_points,1);
noverlap=0;

for j = 1:train_points
%    figure;
    for i = 1:nm

        YN{i} = m{i}.CN*(m{i}.AN*afd.X0+m{i}.BN*train_u(:,j)*u_range/2+m{i}.BwN*afd.WN)+m{i}.DvN*afd.VN;

%        plot(YN{i}); hold on;
    end

    for i = 1:nm-1
        for k = i:nm-1
            check = CheckOverlap(YN{i},YN{k+1});
            co(i,k) = check;
            if check
                y(j) = 1;
            end
        end
    end
    if ~y(j)
            noverlap = noverlap + 1;
    end
%    legend('1','2','3','4','5')
%    hold off;
end

disp(noverlap/train_points)
%disp(train_u)
%disp(y.')
save('2D32')


%% GENERATE PLOTS

% plot N step output reachable sets
%YN = cell(nm,1);
%figure; hold on;
%for i = 1:nm
%    YN{i} = m{i}.CN*(m{i}.AN*afd.X0+m{i}.BN*usep+m{i}.BwN*afd.WN)+m{i}.DvN*afd.VN;
%    plot(YN{i});
%    YN{i}
%end
%    plot(plus(YN{1},YN{2}))
