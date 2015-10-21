clear;

%%%%%%%% Load data
inputFile = 'D:/matlab_data/qepm/ch6/Data_Ch6.csv';
fid = fopen(inputFile);
allData = textscan(fid,'%d%s%d%f%f%f%f%f%f%f%f%f%f', ...
    'Headerlines',1,'Delimiter',',','TreatAsEmpty','NA');
fclose(fid);

col_seq = 1; col_ticker = 2; col_month = 3; col_retLead = 4;
col_capExRatio = 5;	col_debt2Equity = 6; col_marketCap = 7;
col_price2Book = 8; col_price2Cashflow = 9; col_price2dividend = 10;
col_price2Earnings =11; col_rndRatio = 12; col_roe = 13;

%%% Calculate 6month return momentum, log(price2cashflow),
%%% log(price2earning)
momentum = nan(size(allData{col_seq},1),1);

for i = 7 : size(momentum,1)
    if (allData{col_month}(i-1) - allData{col_month}(i-6) == 5 ...
            && strcmp(allData{col_ticker}(i-1), allData{col_ticker}(i-6)) ...
            && strcmp(allData{col_ticker}(i-1), allData{col_ticker}(i)))
        momentum(i) = sum(allData{col_retLead}(i-6:i-1));
    end
end

logPrice2Cashflow = log(allData{col_price2Cashflow});
logPrice2Earnings = log(allData{col_price2Earnings});

[cleanData, cleanIndex] = keepValidRow([allData{col_retLead} allData{col_marketCap} ...
                          momentum logPrice2Cashflow ...
                          logPrice2Earnings allData{col_marketCap}]);

%%%Matlab cannot do pooled regression, fix f0
cleanReturn = cleanData(:,1);
cleanMCap = cleanData(:,2);
cleanMomentum = cleanData(:,3);
cleanPrice2Cash = cleanData(:,4);
cleanPrice2Earnings = cleanData(:,5);
cleanRoe = cleanData(:,6);

result = ols(cleanReturn, [ones(size(cleanReturn)) cleanMCap cleanMomentum ...
                           cleanPrice2Cash cleanPrice2Earnings]);
                 
                    