function Xnew = cstr_one_step_reach(X0, ucenter, W, UA)

dt = 0.18;

params.tStart = 0;
params.tFinal = dt;
params.R0 = X0;
params.u = [ucenter ; 0 ; 0];
params.U = zonotope([zeros(4,1), diag([0 ; 0 ; W.G(1,1) ; W.G(2,2)])]);

options.verbose = false;
options.zonotopeOrder = 50;
options.tensorOrder = 3;
options.errorOrder = 5;
options.alg = 'lin';


fun = @(x,u) cstrDT(x,u,0.02,UA);
sysDisc = nonlinearSysDT('cstr',fun,0.02);

R = reach(sysDisc,params,options);

Xnew = R.timePoint.set{end};

end