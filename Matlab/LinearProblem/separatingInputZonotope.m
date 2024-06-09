function afd = separatingInputZonotope(m, X0, W, V, ngen)

% extract necessary dimensions
N = m{1}.N;

% N step sequence of disturbances
cw = W.center;
Gw = W.generators;
cwN = repmat(cw,[N,1]);
GwN = repmat({Gw}, 1, N);
GwN = blkdiag(GwN{:});
WN = zonotope([cwN, GwN]);

% measurement noise
if m{1}.full_meas
    cv = V.center;
    Gv = V.generators;
    cvN = repmat(cv,[N,1]);
    GvN = repmat({Gv}, 1, N);
    GvN = blkdiag(GvN{:});
    VN = zonotope([cvN, GvN]);    
else
    VN = V;
end

% calculate output prediction matrix (without input effect)
nm = length(m);
for i = 1:nm
    m{i}.FN = m{i}.CN*m{i}.AN*X0 + m{i}.CN*m{i}.BwN*WN + m{i}.DvN*VN;
end

% calculate the matrix and set used for characterizing separating inputs
dLN = cell(nm);
ZN = cell(nm);
for i = 1:nm
    for j = i+1:nm
        dLN{i,j} = m{j}.CN*m{j}.BN - m{i}.CN*m{i}.BN;
        minusFNj = zonotope([-m{j}.FN.center, m{j}.FN.generators]);
        ZN{i,j} = m{i}.FN + minusFNj;
    end
end

% get reduced number of generators, if defined
if ~exist('ngen')
    ngen = size(ZN{i,j}.generators,2);
    ZredN = ZN;
else
    for i = 1:nm
        for j = i+1:nm
            ZredN{i,j} = reduce(ZN{i,j},'girard',ceil(ngen/2));
        end
    end
end

% add to afd model structure
afd.models = m;
afd.X0 = X0;
afd.W = W;
afd.V = V;
afd.ngen = ngen;
afd.WN = WN;
afd.VN = VN;
afd.dLN = dLN;
afd.ZN = ZN;
afd.ZredN = ZredN;

end