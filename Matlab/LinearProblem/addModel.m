function m = addModel(m, A, B, C, Bw, Dv, N, full_meas)

% set default function values
if nargin < 7
    1
    error('not enough inputs...')
elseif nargin < 8
    full_meas = 0;
end

% calculate N step propagation of system matrices
nx = size(A,1);
nu = size(B,2);
nw = size(Bw,2);
ny = size(C,1);
[AN,BN] = create_CHS(A,B,eye(nx),N);
[~,BwN] = create_CHS(A,Bw,eye(nx),N);
if full_meas
    CCell = repmat({C}, 1, N);
    CN = blkdiag(CCell{:});
    DvCell = repmat({Dv}, 1, N);
    DvN = blkdiag(DvCell{:});    
else
    CN = zeros(ny,nx*N);
    CN(:,end-nx+1:end) = C;
    DvN = Dv;
end

% add to end of model structure m
m{end+1}.A = A;
m{end}.B = B;
m{end}.C = C;
m{end}.Bw = Bw;
m{end}.Dv = Dv;
m{end}.AN = AN;
m{end}.BN = BN;
m{end}.BwN = BwN;
m{end}.CN = CN;
m{end}.DvN = DvN;
m{end}.N = N;
m{end}.nx = nx;
m{end}.nu = nu;
m{end}.nw = nw;
m{end}.ny = ny;
m{end}.full_meas = full_meas;

end