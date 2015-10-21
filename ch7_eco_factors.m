clear;

%%%%%%%% Load data
inputFile = 'D:/matlab_data/qepm/ch7/Data_Ch7.csv';
fid = fopen(inputFile);
allData = textscan(fid,'%d%s%d%f%f%f%f%f%f%f%f%f%f%f', ...
    'Headerlines',1,'Delimiter',',','TreatAsEmpty','NA');
fclose(fid);

col_seq = 1; col_ticker = 2; col_month = 3; col_retLead = 4;
col_capExRatio = 5;	col_debt2Equity = 6; col_marketCap = 7;
col_momentum = 8;
col_price2Book = 9; col_price2Cashflow = 10; col_price2dividend = 11;
col_price2Earnings =12; col_rndRatio = 13; col_roe = 14;


%%%%%%TO DO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Load data in Matrix format!%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ticker = allData{col_ticker};
retLead = allData{col_retLead};
month = allData{col_month};
marketCap = allData{col_marketCap};
momentum = allData{col_momentum};
p2earnings = allData{col_price2Earnings};

%calculate factor premiums
[premiumMarketCap, monthIndexMC] = calcFactorPremium_yy(month, [retLead marketCap], 0.2);
 
[premiumMomentum, monthIndexMT] = calcFactorPremium_yy(month, [retLead momentum], 0.2);

[premiumP2Earnings, monthIndexP2E] = calcFactorPremium_yy(month, [retLead p2earnings], 0.2);

%find common date that both factors are available.
validDates = [];
validPremiumMC = [];
validPremiumMT = [];

i=1;j=1;
while(i<size(premiumMarketCap,1) && j<size(premiumMomentum,1))
    if (monthIndexMC(i) == monthIndexMT(j))
        validDates = [validDates monthIndexMC(i)];
        validPremiumMC = [validPremiumMC; i];
        validPremiumMT = [validPremiumMT; j];
        i = i+1;
        j = j+1;
    elseif (monthIndexMC(i) > monthIndexMT(j))
        j = j+1;
    else 
        i = i+1;
    end
end
validDates = validDates';%this is sorted.

%Regression for IBM. 
disp('Starting regression for IBM');
ibmIndex = find(strcmp(ticker,'IBM'));
currentM = 1;
retIbm=[];
for i = 1:size(ibmIndex,1)
    indexInAll = ibmIndex(i);
    if (month(indexInAll) == validDates(currentM))
        retIbm = [retIbm retLead(indexInAll)];
        currentM = currentM+1;
    end
    if (currentM > size(validDates, 1))
        fprintf('Found all month\n');
        break;
    end
end
retIbm = retIbm';

premiumMC = premiumMarketCap(validPremiumMC);
premiumMT = premiumMomentum(validPremiumMT);

result=ols(retIbm,[ones(size(retIbm)) premiumMC premiumMT]);

%Regression for AAPL.

 