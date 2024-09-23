clear

start = datetime('now');

dim = 10;
train_points = 512;

Frange = 4.27; % Ranges from 0 to 4.27 (Steady state is 2.137 but F can really range from 0 to 100)
Q_dotrange = 8211; % Ranges from -8500 to -288.28 (Steady state is -4394.14 but Q_dot can really range from -8500 to 0)


for zz=1:1
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
        y(i) = dompc_cstrgetTrueValue(train_u(:,i).',Frange,Q_dotrange);
        catch
            y(i) = 1;
            errors = errors+1;
            disp('ERR:')
            disp(errors/i)
        end
        if y(i) == 1
            to = to+1;
        else
            disp('Separate:')
            disp((i-to)/i)
        end
    end
    
    disp(1-(to/train_points))
    
    tend = datetime('now');
    
    disp(tend-start)
    disp(errors/train_points)
    disp(zz)
    save(['6D512-',num2str(zz)])
end




