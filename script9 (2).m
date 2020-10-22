clear all
clc

%%%DIABETES DATA
file_spec = 'Dataset_Comorbidities.xlsx';
data0 = xlsread(file_spec);
% Pavdat = csvread('NEWDATA.csv', 1);
data1=data0(:,[1:13]);

data1(:,[2]) = Discretise(data1(:,[2])', 3)';
data1(:,[8:13]) = Discretise(data1(:,[8:13])', 3)';
data1(:,2:13)=data1(:,2:13)+1;
% data1(:,[2]) = standardise(data1(:,[2]));
% data1(:,[8:13]) = standardise(data1(:,[8:13]));
traincases = [1:181];

testcases = [182:363];
% data1= data1(1:1000,:);
% traincases = [1:33];
% testcases = [34:67];
% traincases = [1:2];
% testcases = [3:4];
dataa = data1;

[datlen datn]=size(data1);
datcell={};
patcell= [];%dataa(1,:);
patc = [];
classcell={};
count=1;
patlen=0;
ids=[];
patient = 0;
datc = [];
traindat = {};
trainIDout = {};
testdat = {};
testIDout = {};
 
    ID = [];
for i = 2:datlen
    if (dataa(i,1)==dataa(i-1,1))
        patcell=[patcell;dataa(i,:)];
        patlen=patlen+1;
    else
        if (patlen>1)
            patient = patient +1;
            datcell{count}=[num2cell(patcell(:,2:datn)')];
            classcell{count}=[num2cell(patcell(:,3)')];
            count=count+1;
            ids = [ids dataa(i,1)];
        end
        patcell=[dataa(i,:)];  
        patlen=1;
    end
end
seqnum=length(datcell);
    [temp n] = size(datcell{1});
    traincell=datcell(traincases);
testcell=datcell(testcases);
testclass = [];
% for k = 1:seqnum 
%     [temp n] = size(datcell{k});
%     for var = 1:13
%        g = (find((cell2num(datcell{k}(var,:))==2),1,'first'));
%            if g == 0
%                var = var+1;
%            elseif g > n
%                
%                 for h = g:n-1
%                    datcell{k}(var,h+1) = num2cell(cell2num(datcell{k}(var,h+1)) + 1);
%                 end % endfor
% %            else var = var+1;
%            
%            end % endif
%             
%      end % endfor
%     end % endfor
% %%
% %
% f1 = length(datcell)
% tot_f = {};
% 
% for var = 2:13
%     f3=[];
%     for i = 1:f1
%         t31=cell2num(datcell{i}(var,:))';
%         f3 = [f3;t31];
%     end
%     tot_f{var} = f3-1;
% end

%
%%

tot_t = {};
tot_y = {};
tot_x = {};
tot_t_unbalanced = {};
tot_y_unbalanced = {};

%%

for var = 2:6

%%
% Unbalanced Data
ns=[3 2 2 2 2 2 3 3 3 3 3 3];
[dags inter] = PATReveal(ns, traincell);
ns=[3 2 2 2 2 2 3 3 3 3 3 3 3 2 2 2 2 2 3 3 3 3 3 3];
[dags intra] = PATK2(ns, traincell);
intra1 = round(intra);
inter1 = round(inter);
[bnet LLtrace] = TrainHMM(traincell, [1:datn],[],2,intra1, inter1)% cell2num(traincell)

[outpred] = TestHMM(bnet,testcell,testclass, 2, 2, 2,var+1)
draw_graph(bnet.dag)
patlen=length(outpred)
y=[];
t=[];
x=[];
for i = 1:patlen
    temp1=cell2mat(testcell{i}(var,:))
    temp1=temp1(2:length(temp1))'
    temp2=outpred{i}(:,var+1)

    temp3=outpred{i}(:,1);
    x = [x;temp3];
    y = [y;temp2];
    t = [t;temp1];
end
%%
%%
%%Allan algorithm
[traini3 traind3 traincelladd3] = TSBootstrapPAT6(datcell,var);
    traincell3 = [traincelladd3];
ns=[3 2 2 2 2 2 3 3 3 3 3 3];
[dags inter] = PATReveal(ns, traincell3);
ns=[3 2 2 2 2 2 3 3 3 3 3 3 3 2 2 2 2 2 3 3 3 3 3 3];
[dags intra] = PATK2(ns, traincell3);
intra1 = round(intra);
inter1 = round(inter);
[bnet3 LLtrace3] = TrainHMM(traincell3, [1:datn],[],2,intra1, inter1)% cell2num(traincell)
[outpred3] = TestHMM(bnet3,testcell,testclass, 2, 2, 2,var+1)
draw_graph(bnet3.dag)
patlen=length(outpred3)
y3=[];
t3=[];
x3=[];
for i = 1:patlen
    temp31=cell2mat(testcell{i}(var,:));
    temp31=temp31(2:length(temp31))';
    temp32=outpred3{i}(:,var+1);
    temp33=outpred3{i}(:,1);
    x3 = [x3;temp33];
    y3 = [y3;temp32];
    t3 = [t3;temp31];
end
disp('for var result is')
tot_t{var} = t3;
tot_y{var} = y3;
tot_x{var} = x3;
tot_t_unbalanced{var} = t;
tot_y_unbalanced{var} = y;

end
% tot_y = [tot_y,y]
% end %for var
%%Allan algorithm
%%
hba1c = [];
for i = 1:patlen
temp31=cell2mat(testcell{i}(1,:));
temp31=temp31(2:length(temp31))'-1;
hba1c = [hba1c;temp31];
end

BMI = [];for i = 1:patlen
temp31=cell2mat(testcell{i}(7,:));
temp31=temp31(2:length(temp31))'-1;
BMI= [BMI;temp31];
end
CREATININE = [];for i = 1:patlen
temp31=cell2mat(testcell{i}(8,:));
temp31=temp31(2:length(temp31))'-1;
CREATININE= [CREATININE;temp31];
end
HDL = [];for i = 1:patlen
temp31=cell2mat(testcell{i}(10,:));
temp31=temp31(2:length(temp31))'-1;
HDL= [HDL;temp31];
end
DBP = [];for i = 1:patlen
temp31=cell2mat(testcell{i}(1,:));
temp31=temp31(2:length(temp31))'-1;
DBP= [DBP;temp31];
end
CHOLESTROL = [];for i = 1:patlen
temp31=cell2mat(testcell{i}(9,:));
temp31=temp31(2:length(temp31))'-1;
CHOLESTROL= [CHOLESTROL;temp31];
end
SBP = [];for i = 1:patlen
temp31=cell2mat(testcell{i}(12,:));
temp31=temp31(2:length(temp31))'-1;
SBP= [SBP;temp31];
end
% TRIG = [];for i = 1:patlen
% temp31=cell2mat(testcell{i}(14,:));
% temp31=temp31(2:length(temp31))'-1;
% TRIG= [TRIG;temp31];
% end
% MICROALBUNIMIA = [];for i = 1:patlen
% temp31=cell2mat(testcell{i}(19,:));
% temp31=temp31(2:length(temp31))'-1;
% MICROALBUNIMIA = [MICROALBUNIMIA ;temp31];
% end
% CREATININE_CLR = [];for i = 1:patlen
% temp31=cell2mat(testcell{i}(16,:));
% temp31=temp31(2:length(temp31))'-1;
% CREATININE_CLR= [CREATININE_CLR;temp31];
% end
L = cellfun('size',testcell,2)'
% plotrocc(tot_t{2}'-1,tot_y{2}','lipid + nepropathy + liver',tot_t_unbalanced{2}'-1,tot_y_unbalanced{2}','UNB lipid + nepropathy + liver',tot_t{3}'-1,tot_y{3}','lipid',tot_t_unbalanced{3}'-1,tot_y_unbalanced{3}','UNBALANCED lipid',tot_t{4}'-1,tot_y{4}','nepropathy',tot_t_unbalanced{4}'-1,tot_y_unbalanced{4}','UNBALANCED nepropathy',tot_t{5}'-1,tot_y{5}','liver',tot_t_unbalanced{5}'-1,tot_y_unbalanced{5}','UNBALANCED liver',tot_t{6}'-1,tot_y{6}','neuropathy',tot_t_unbalanced{6}'-1,tot_y_unbalanced{6}','UNBALANCED neuropathy',tot_t{7}'-1,tot_y{7}','retinopathy',tot_t_unbalanced{7}'-1,tot_y_unbalanced{7}','UNBALANCED retinopathy')
% plotconfusion(tot_t{2}'-1,tot_y{2}','Retinopathy',tot_t_unbalanced{2}'-1,tot_y_unbalanced{2}','UNB Retinopathy',tot_t{3}'-1,tot_y{3}','Polyneuropathy',tot_t_unbalanced{3}'-1,tot_y_unbalanced{3}','UNB Polyneuropathy',tot_t{4}'-1,tot_y{4}','nepropathy',tot_t_unbalanced{4}'-1,tot_y_unbalanced{4}','UNBALANCED nepropathy',tot_t{5}'-1,tot_y{5}','liver',tot_t_unbalanced{5}'-1,tot_y_unbalanced{5}','UNBALANCED liver',tot_t{6}'-1,tot_y{6}','Hypertention',tot_t_unbalanced{6}'-1,tot_y_unbalanced{6}','UNBALANCED Hypertention',tot_t{7}'-1,tot_y{7}','retinopathy',tot_t_unbalanced{7}'-1,tot_y_unbalanced{7}','UNBALANCED retinopathy')