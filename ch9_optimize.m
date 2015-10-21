%clear;

%%%%%%%% Load data
inputFile = 'D:/matlab_data/qepm/ch9/data_Ch9_return.txt';
ret = dlmread(inputFile, '\t', 0, 1);
ret = ret';

tickers = textread(inputFile,'%s%*[^\n]','delimiter','\t');

vc = cov(ret) * 12;

meanRet = mean(ret)' * 12;

minRet = min(meanRet);
maxRet = max(meanRet);

step = (maxRet - minRet)/ 100;

dim = size(tickers);
frontier=[];
weights=[];
%%%%Target from minRet to maxRet, find the minimum variance portfolio.
for target = minRet : step : maxRet
    aeq = [meanRet ones(1,dim)']';
    beq = [target*ones(1,1) ones(1,1)]';
    lowerBound = zeros(dim,1);
    result = quadprog(vc,[],[],[], aeq, beq, lowerBound);
    weights = [weights result];
    stdDev = sqrt (result' * vc * result);
    frontier = [frontier; [stdDev target]];
end
weights = weights';

plot(frontier(:,1), frontier(:,2));
xlabel('Standard Deviation');
ylabel('Expected Return');