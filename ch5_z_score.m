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
cleanData = keepValidRow([allData{col_seq} allData{col_capexratio} ...
    allData{col_debt2equity} allData{col_price2book} allData{col_price2cashflow} ...
    allData{col_price2dividend} allData{col_price2earnings} allData{col_rndratio} ...
    allData{col_roe} allData{col_ret1m} allData{col_ret3m} allData{col_ret6m} ...
    allData{col_ret12m}]);