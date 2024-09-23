function Xnew = dompc_cstr_one_step_reach(X0, ucenter, W, C_A0)

dt = 0.16;

params.tStart = 0;
params.tFinal = dt;
params.R0 = X0;
params.u = [ucenter; 0; 0];
params.U = zonotope([zeros(4,1), diag([0 ; 0 ; W.G(1,1); W.G(2,2)])]);

options.verbose = true;
options.zonotopeOrder = 50;
options.tensorOrder = 3;
options.errorOrder = 5;
options.alg = 'lin';

state_dim = size(X0.c,1);
input_dim = size(ucenter, 1)+2;

fun = @(x,u) dompc_cstrDT(x,u,dt/10,C_A0);
sysDisc = nonlinearSysDT(fun,dt/10,state_dim,input_dim);

R = reach(sysDisc,params,options);

Xnew = R.timePoint.set{end};

end