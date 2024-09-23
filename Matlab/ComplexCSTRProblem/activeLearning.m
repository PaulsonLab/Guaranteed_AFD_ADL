function gtv = activeLearning(input,trange,crange)
try
    gtv = dompc_cstrgetTrueValue(input,trange,crange);
catch
    gtv = 1;
end
end