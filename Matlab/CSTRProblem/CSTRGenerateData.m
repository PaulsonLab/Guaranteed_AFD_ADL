clear

start = datetime('now');

dim = 6;
train_points = 256;

trange = 100;
crange = 1;

p = sobolset(dim);
sp = scramble(p,'MatousekAffineOwen');
train_u = net(sp,train_points).'*2-1;

%high fidelity 2d grid
%Tc ranges from 280 to 370
%c ranges from 0.1 to 0.9
%train_array = [];
%Tc = linspace(0,1,100);
%for i=1:length(Tc)
%    for j=1:length(Tc)
%        train_array = cat(2,train_array,[Tc(i);Tc(j)]);
%    end
%end


to = 0;
errors = 0;
y = zeros(train_points,1);
for i=1:train_points
    try
    y(i) = cstrgetTrueValue(train_u(:,i).',trange,crange);
    catch
        y(i) = 1;
        errors = errors+1;
    end
    if y(i) == 1
        to = to+1;
    end
    if mod(i,20)==0
        disp(i/(train_points/10))
        disp(datetime('now')-start)
    end
end

disp(1-(to/train_points))

tend = datetime('now');

disp(tend-start)
disp(errors/train_points)
%save(['6D256lin-',int2str(zz)])









