clear;

%%%%%%%% Load data
inputFile = 'D:/matlab_data/qepm/ch8/Data_Ch8.csv';
fid = fopen(inputFile);
allData = textscan(fid,'%d%d%f%f%f%f', ...
    'Headerlines',1,'Delimiter',',','TreatAsEmpty','NA');
fclose(fid);

month = allData{2};
market = allData{3};
marketCap = allData{4};
value = allData{5};
momentum = allData{6};

wholePeriod =[market marketCap value momentum];
Y = wholePeriod(1:size(wholePeriod,1)-1,:);

%%%buildin VAR from Matlab
spec=vgxset('n',4,'nAR',1,'Constant',true);
[EstStd,EstStdErrors]=vgxvarx(spec,Y,[],[]);

disp('From Matlab VAR model (maximum likelihood estimation.)');
a = EstStd.a
cov = EstStd.AR{1}
%vgxdisp(EstStd,EstStdErrors);
%error=EstStd.Q;%???/

%%%vare from jplv7
r = vare(Y,1);
all = [r(1).beta';r(2).beta';r(3).beta';r(4).beta'];
disp('From jplv VAR (ols estimation.)');
a2 = all(:,5)
cov2 = all(:,1:4)


%%%Forcast:
disp('Forcast for next month:');
f = a2+cov2 * Y(size(Y,1),:)'
disp('From realdata, next month is:');
wholePeriod(size(wholePeriod,1),:)'


%%%%%Can this be used directly to forcast return? 