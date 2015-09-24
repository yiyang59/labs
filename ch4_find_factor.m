clear;

%%%%%%%%%%%Global parameters (assumptions)
minAccountingLag = 3; %assume 3 months gap in accounting reports.
maxAccountingLag = 5; %Cannot carryover for > 5 months.

%Note, penny stocks screws the regression. 
minPriceUnivers = 5;%filter out penny stocks.
maxReasonableReturn =1; %filter for unrealistic return due to data error.

%load all data.
col_seq=1;           col_ticker=2;     col_month=3;  col_pricedate=4; 
col_pricem=5;        col_acctdate=6;   col_capexq=7; col_cashflowq=8;
col_cashflowshareq=9;col_dividendq=10; col_epsq=11;  col_netincomeq=12;
col_rndq=13;         col_sharesq=14;   col_totalassetsq=15; 
col_totalliabilitiesq=16;

inputFile = 'D:/matlab_data/qepm/ch4/Data_Ch4.csv';
fid = fopen(inputFile);
alldata = textscan (fid,'%d%s%d%s%f%s%f%f%f%f%f%f%f%f%f%f',      ...
          'Delimiter',',','Headerlines',1,'TreatAsEmpty','NA');
fclose(fid);

%%%%%%%%%%%% Data cleaning and preparation

%%Remove Penny stocks, could this caus bias?
%TBD
%%Removed Penny stocks.

price = alldata{col_pricem};
ticker = alldata{col_ticker};

NumRow = length(price);

priceReturn = NaN(NumRow,1);
for i = 1 : NumRow - 1
    if (strcmp(ticker(i), ticker(i+1)) ...
            && alldata{col_month}(i) + 1 == alldata{col_month}(i+1))
        ret = (price(i+1) - price(i)) / price(i);
    else
        ret = nan;
    end
    priceReturn(i) = ret;
end

%Filter out unrealistic returns due to price data error.
priceReturn (find (priceReturn > maxReasonableReturn)) = nan;

%find (priceReturn > 5)
%error('stop');

%%Fill accounting values, from quarterly to monthly 1->3 months.
lastAccountingRow = 0;
lastMonthNumber = 0;
lastTicker = '';
for i = 1 : NumRow
    if (~strcmp(alldata{col_acctdate}(i), 'NA'))
        lastAccountingRow = i;
        lastMonthNumber = alldata{col_month}(i);
        lastTicker = alldata{col_ticker}(i);
    else
        currentMonth = alldata{col_month}(i);
        currentTicker = alldata{col_ticker}(i);
        if (currentMonth <= lastMonthNumber + maxAccountingLag && ...
                lastMonthNumber > 0 && strcmp (lastTicker, currentTicker))
            alldata{col_capexq}(i) = alldata{col_capexq}(lastAccountingRow);
            alldata{col_cashflowq}(i) = alldata{col_cashflowq}(lastAccountingRow);
            alldata{col_cashflowshareq}(i) = alldata{col_cashflowshareq}(lastAccountingRow);
            alldata{col_dividendq}(i) = alldata{col_dividendq}(lastAccountingRow);
            alldata{col_epsq}(i) = alldata{col_epsq}(lastAccountingRow);
            alldata{col_netincomeq}(i) = alldata{col_netincomeq}(lastAccountingRow);
            alldata{col_rndq}(i) = alldata{col_rndq}(lastAccountingRow);
            alldata{col_sharesq}(i) = alldata{col_sharesq}(lastAccountingRow);
            alldata{col_totalassetsq}(i) = alldata{col_totalassetsq}(lastAccountingRow);
            alldata{col_totalliabilitiesq}(i) = alldata{col_totalliabilitiesq}(lastAccountingRow);
        end
    end
end

capExpRatio = alldata{col_capexq} ./ alldata{col_totalassetsq};
capExpRatio = lag(capExpRatio, minAccountingLag);

debtRatio = alldata{col_totalliabilitiesq} ./ alldata{col_totalassetsq};
debtRatio = lag(debtRatio, minAccountingLag);

rndRatio = alldata{col_rndq} ./ alldata{col_totalassetsq};
rndRatio = lag (rndRatio, minAccountingLag);

roe = alldata{col_netincomeq} ./ alldata{col_totalassetsq};
roe = lag (roe, minAccountingLag);

laggedTotalAsset = lag (alldata{col_totalassetsq}, minAccountingLag);
laggedCashFlow = lag (alldata{col_cashflowq}, minAccountingLag);
laggedDividend = lag (alldata{col_dividendq}, minAccountingLag);
laggedEps = lag (alldata{col_epsq}, minAccountingLag);

price2book = price ./ laggedTotalAsset;
price2cashFlow = price ./ laggedCashFlow;
price2dividend = price ./ laggedDividend;
price2earnings = price ./ laggedEps;

%Trim all arrays, first minAccountingLag rows are useless
priceReturn = priceReturn (minAccountingLag+1:NumRow);
capExpRatio = capExpRatio (minAccountingLag+1:NumRow);
debtRatio = debtRatio (minAccountingLag+1:NumRow);
rndRatio = rndRatio (minAccountingLag+1:NumRow);
roe = roe (minAccountingLag+1:NumRow);
price2book = price2book (minAccountingLag+1:NumRow);
price2cashFlow = price2cashFlow (minAccountingLag+1:NumRow);
price2dividend = price2dividend (minAccountingLag+1:NumRow);
price2earnings = price2earnings (minAccountingLag+1:NumRow);


%%%%%%%%%%%% Regression test on factors
[y,x] = keepValidPair(priceReturn, capExpRatio);
result=ols(y,[x ones(size(x))]);
disp('Capital Expenditure / Total Asset Ratio');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, debtRatio);
result=ols(y,[x ones(size(x))]);
disp('Debt / Total Asset Ratio');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, rndRatio);
result=ols(y,[x ones(size(x))]);
disp('RND / Total Asset Ratio');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, roe);
result=ols(y,[x ones(size(x))]);
disp('Return on Equity');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, price2book);
result=ols(y,[x ones(size(x))]);
disp('Price to Book Ratio');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, price2cashFlow);
[y,x] = keepPositivePair(y,x);
[y,x] = keepFinitePair(y,x);
result=ols(y,[x ones(size(x))]);
disp('Price to Cash Flow');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, price2earnings);
[y,x] = keepPositivePair(y,x);
[y,x] = keepFinitePair(y,x);
result=ols(y,[x ones(size(x))]);
disp('Price to Earnings Ratio');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

[y,x] = keepValidPair(priceReturn, price2dividend);
result=ols(y,[x ones(size(x))]);
disp('Price to Dividend');
fprintf('r = %f + %f * factor\n', result.beta(2), result.beta(1));
prt(result);

%%%%%%%%Multivariate Regression on ROE, RND, Debt ratio. 
%remove nan
all = [priceReturn roe rndRatio debtRatio];
cleanAll = keepValidRow(all);
 
y = cleanAll(:,1);
x1 = cleanAll(:,2);
x2 = cleanAll(:,3);
x3 = cleanAll(:,4);


result=ols(y,[x1 x2 x3 ones(size(x1))]);
disp('Multi variable regression');
fprintf('r = %f + %f * roe + %f * rnd + %f * debt\n', ... 
    result.beta(4), result.beta(1), result.beta(2), result.beta(3));
prt(result);