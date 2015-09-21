clear;

%Global parameters (assumptions)
minAccountingLag = 3; %assume 3 months gap in accounting reports.
maxAccountingLag = 5;

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

%Data cleaning and preparation
price = alldata{col_pricem};
ticker = alldata{1};

for i = 1 .. length(alldata{5}) - 1
    if (strcmp(
end
priceReturn =  