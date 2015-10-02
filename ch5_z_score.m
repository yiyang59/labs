clear;

%%%%%%%% Load data
inputFile = 'D:/matlab_data/qepm/ch5/Data_Ch5.csv';
fid = fopen(inputFile);
allData = textscan(fid,'%f%s%f%f%f%f%f%f%f%f%f%f%f%f', ...
    'Headerlines',1,'Delimiter',',','TreatAsEmpty','NA');

col_seq = 1; col_ticker = 2; col_capexratio = 3; col_debt2equity = 4;
col_price2book = 5;	col_price2cashflow = 6; col_price2dividend = 7;
col_price2earnings = 8; col_rndratio = 9; col_roe = 10;
col_ret1m =11; col_ret3m = 12; col_ret6m = 13; col_ret12m = 14;

%this only keep 193 symbols. 
%cleanData = keepValidRow([allData{col_seq} allData{col_capexratio} ...
%    allData{col_debt2equity} allData{col_price2book} allData{col_price2cashflow} ...
%    allData{col_price2dividend} allData{col_price2earnings} allData{col_rndratio} ...
%    allData{col_roe} allData{col_ret1m} allData{col_ret3m} allData{col_ret6m} ...
%    allData{col_ret12m}]);

capexratio = allData{col_capexratio};
zscore_capexratio = zscore_yy(capexratio);

debt2equity = allData{col_debt2equity};
zscore_debt2equity = zscore_yy(debt2equity);

price2book = allData{col_price2book};
zscore_price2book = zscore_yy(price2book);

price2cashflow = allData{col_price2cashflow};
zscore_price2cashflow = zscore_yy(price2cashflow);

price2dividend = allData{col_price2dividend};
zscore_price2dividend = zscore_yy(price2dividend);

price2earnings = allData{col_price2earnings};
zscore_price2earnings = zscore_yy(price2earnings);

rndratio = allData{col_rndratio};
zscore_rndratio = zscore_yy(rndratio);

roe = allData{col_roe};
zscore_roe = zscore_yy(roe);

%exclude price2dividend, too many missing values.
zscore = (zscore_capexratio+zscore_debt2equity-zscore_price2book ...
    - zscore_price2cashflow - zscore_price2earnings ...
    + zscore_rndratio + zscore_roe) / 8;

ret1m = allData{col_ret1m};
ret3m = allData{col_ret3m};
ret6m = allData{col_ret6m};
ret12m = allData{col_ret12m};

%scatter(zscore, ret1m);
%scatter(zscore, ret3m);
%scatter(zscore, ret6m);
%scatter(zscore, ret12m);

%%%%Pick winners and losers and check returns
[sortedZscore,I] = sort(zscore,'Descend');

%remove NA
indexNonNA = find (~isnan(sortedZscore));
sortedZscore=sortedZscore(indexNonNA);
I = I (indexNonNA);

ticker = allData{col_ticker};

pick = ticker(I);
pickRet1m = allData{col_ret1m}(I);
pickRet3m = allData{col_ret3m}(I);
pickRet6m = allData{col_ret6m}(I);
pickRet12m = allData{col_ret12m}(I);

numStock = 20; %long top 50 and short bottom 50;


nonNARet = pickRet1m(find(~isnan(pickRet1m)));
sizeOfAll = size(nonNARet);
meanRetTop = mean(nonNARet(1:numStock));
meanRetBottom = mean(nonNARet(sizeOfAll-numStock:sizeOfAll));
fprintf('1 month return, Top %d vs bottom %d: %f   %f\n',numStock,numStock, ...
    meanRetTop,meanRetBottom);

nonNARet = pickRet3m(find(~isnan(pickRet3m)));
sizeOfAll = size(nonNARet);
meanRetTop = mean(nonNARet(1:numStock));
meanRetBottom = mean(nonNARet(sizeOfAll-numStock:sizeOfAll));
fprintf('3 month return, Top %d vs bottom %d: %f   %f\n',numStock,numStock, ...
    meanRetTop,meanRetBottom);

nonNARet = pickRet6m(find(~isnan(pickRet6m)));
sizeOfAll = size(nonNARet);
meanRetTop = mean(nonNARet(1:numStock));
meanRetBottom = mean(nonNARet(sizeOfAll-numStock:sizeOfAll));
fprintf('6 month return, Top %d vs bottom %d: %f   %f\n',numStock,numStock, ...
    meanRetTop,meanRetBottom);

nonNARet = pickRet12m(find(~isnan(pickRet12m)));
sizeOfAll = size(nonNARet);
meanRetTop = mean(nonNARet(1:numStock));
meanRetBottom = mean(nonNARet(sizeOfAll-numStock:sizeOfAll));
fprintf('12 month return, Top %d vs bottom %d: %f   %f\n',numStock,numStock, ...
    meanRetTop,meanRetBottom);
