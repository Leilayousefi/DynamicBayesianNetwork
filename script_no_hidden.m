clear all
clc

%%%DIABETES DATA
file_spec = 'NewDataset.xlsx';
data0 = xlsread(file_spec);
% data0 = csvread('PaviaDatMacVasc.csv', 1);
data1=data0(:,[1:13]);

data1(:,[2]) = Discretise(data1(:,[2])', 3)';
data1(:,[9:13]) = Discretise(data1(:,[9:13])', 3)';
data1(:,2:13)=data1(:,2:13)+1;

traincases = [1:179];

testcases = [180:356];
% data1= data1(1:2000,:);
% traincases = [1:20];
% testcases = [21:41];

dataa = data1;

[datlen datn]=size(data1);
%datn=datn-1;
datcell={};
datcell_pos= {};
datcell_neg = {};
patcell=[];
patc = [];
patcell_Pos = [];
patcell_Neg = [];
datcell_Pos = [];
datcell_Neg = [];
datc_both ={};
datcell_both = {};
datcell_traincell_BT = {};
classcell={};
count=1;
patlen=0;
ids=[];
patient = 0;
  overlap_p = 0;
        overlap_N = 0;
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
%         limt_1=limt_1+1;
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
for i = 1: seqnum-1
[temp n] = size(datcell{i});

datcelli = cell2num(datcell{i});
variable = 2;
var = variable;
datcellii = datcelli(variable,:)-1;
f =  sum(datcellii==0)
d = n - f;
e = f - d;
% for i=1:5 
% %           
      
           for v = 1:d
                if (d > 1 && e > 1)
              k = (find((datcelli(variable,:)==2),d,'first'));
              j = (find((datcelli(variable,:)==2),1,'last'));
              msize = numel(k);
              u = k(randperm(msize, 2));
              datcelli = datcelli(:,u(1,1):u(1,2));
              k_n = (find((datcelli(variable,:)==1),f,'first'));
              j_n = (find((datcelli(variable,:)==1),1,'last'));
              msize_n = numel(k_n);
              if (msize_n >= 2)
              u_n = k_n(randperm(msize_n, 2));
              if (u_n(1,2)-u_n(1,1)) >1
                  datcelli = datcelli(:,1:u_n(1,1)-1);
              end
              end
              [n1 n] = size(datcelli);
              f =  sum(datcellii==0)
              d = n - f;
              e = f - d;
%        if e > 2
%             datcelli = datcelli(:,k:j);
                 end
           end
      
% %             datcelli=datcelli(:,1);
% end
          datcell{i} = num2cell(datcelli);
          if e < 1
               datcell_pos{i} = datcell{i};
          else
               datcell_neg{i} = datcell{i};
          end
          
          [n1 n] = size(datcell{i});
          
          if n == 0
              datcell{i} = datcell{i+1};
          end
        
%     end
%     end
end
datcell_pos = datcell_pos(~cellfun('isempty',datcell_pos));
datcell_neg = datcell_neg(~cellfun('isempty',datcell_neg));

traincell=datcell(traincases);
testcell=datcell(testcases);
testclass = [];
%%
% Unbalanced Data
ns=[3 2 2 2 2 2 2 3 3 3 3 3];
[dags inter] = PATReveal(ns, traincell);
ns=[3 2 2 2 2 2 2 3 3 3 3 3 3 2 2 2 2 2 2 3 3 3 3 3];
[dags intra] = PATK2(ns, traincell);
intra1 = round(intra);
inter1 = round(inter);
[bnet LLtrace] = TrainHMM_noHidden(traincell, [1:datn],[],2,intra1, inter1)% cell2num(traincell)

[outpred] = TestHMM_noHidden(bnet,testcell,testclass, 2, 2, 2,var)
draw_graph(bnet.dag)
patlen=length(outpred)
y=[];
t=[];
for i = 1:patlen
    temp1=cell2mat(testcell{i}(var,:))
    temp1=temp1(2:length(temp1))'
    temp2=outpred{i}(:,var)

    y = [y;temp2];
    t = [t;temp1];
end
[err cm] = confusion(t'-1,y')
hold on
plotrocc(t'-1,y')
hold off
plotconfusion(t'-1,y')

% Unbalanced Data end
%%

%%
%%
%%Allan algorithm
[traini3 traind3 traincelladd3] = TSBootstrapPAT6(traincell,var);
    traincell3 = [traincell traincelladd3];
ns=[3 2 2 2 2 2 2 3 3 3 3 3];
[dags inter] = PATReveal(ns, traincell3);
ns=[3 2 2 2 2 2 2 3 3 3 3 3 3 2 2 2 2 2 2 3 3 3 3 3];
[dags intra] = PATK2(ns, traincell3);
intra1 = round(intra);
inter1 = round(inter);
[bnet3 LLtrace3] = TrainHMM_noHidden(traincell3, [1:datn],[],2,intra1, inter1)% cell2num(traincell)
[outpred3] = TestHMM_noHidden(bnet3,testcell,testclass, 2, 2, 2,var)
draw_graph(bnet3.dag)
patlen=length(outpred3)
y3=[];
t3=[];
for i = 1:patlen
    temp31=cell2mat(testcell{i}(var,:))
    temp31=temp31(2:length(temp31))'
    temp32=outpred3{i}(:,var)

    y3 = [y3;temp32];
    t3 = [t3;temp31];
end
[err3 cm3] = confusion(t3'-1,y3')
hold on
plotrocc(t3'-1,y3')
hold off
plotconfusion(t3'-1,y3')
%%Allan algorithm
%%
%%
% % % %my Algorithm
% % % for bs = 1:1
% % % [traini traincell1] = TSBootstrap(cell2num(datcell_pos));
% % % end
% % % traincell1 = cell2num(traincell1);
% % % %     traincell1 = [datcell_neg traincell1];
% % % ns=[3 2 2 2 2 2 2 3 3 3 3 3];
% % % [dags inter] = PATReveal(ns, traincell1);
% % % ns=[3 2 2 2 2 2 2 3 3 3 3 3 3 2 2 2 2 2 2 3 3 3 3 3];
% % % [dags intra] = PATK2(ns, traincell1);
% % % 
% % % intra1 = round(intra);
% % % inter1 = round(inter);
% % % [bnet1 LLtrace1] = TrainHMM_noHidden(traincell1, [1:datn],[],2,intra1, inter1)% cell2num(traincell)
% % % 
% % % [outpred1] = TestHMM_noHidden(bnet1,testcell,testclass, 2, 2, 2,var)
% % % draw_graph(bnet1.dag)
% % % patlen=length(outpred1)
% % % y1=[];
% % % t1=[];
% % % for i = 1:patlen
% % %     temp11=cell2mat(testcell{i}(var,:))
% % %     temp11=temp11(2:length(temp11))'
% % %     temp12=outpred1{i}(:,var)
% % % 
% % %     y1 = [y1;temp12];
% % %     t1 = [t1;temp11];
% % % end
% % % [err cm] = confusion(t1'-1,y1')
% % % hold on
% % % plotrocc(t1'-1,y1')
% % % hold off
% % % plotconfusion(t1'-1,y1')
% % % %my Algorthm
%%
%%
% % % %%Allan algorithm+mine
% % % [traini traind traincelladd] = TSBootstrapPAT6(datcell_pos,var);
% % %     traincell2 = [datcell_neg traincelladd];
% % % ns=[3 2 2 2 2 2 2 3 3 3 3 3];
% % % [dags inter] = PATReveal(ns, traincell2);
% % % ns=[3 2 2 2 2 2 2 3 3 3 3 3 3 2 2 2 2 2 2 3 3 3 3 3];
% % % [dags intra] = PATK2(ns, traincell2);
% % % intra1 = round(intra);
% % % inter1 = round(inter);
% % % [bnet2 LLtrace2] = TrainHMM_noHidden(traincell2, [1:datn],[],2,intra1, inter1)% cell2num(traincell)
% % % [outpred2] = TestHMM_noHidden(bnet2,testcell,testclass, 2, 2, 2,var)
% % % draw_graph(bnet2.dag)
% % % patlen=length(outpred2)
% % % y2=[];
% % % t2=[];
% % % for i = 1:patlen
% % %     temp21=cell2mat(testcell{i}(var,:))
% % %     temp21=temp21(2:length(temp21))'
% % %     temp22=outpred2{i}(:,var)
% % % 
% % %     y2 = [y2;temp22];
% % %     t2 = [t2;temp21];
% % % end
% % % [err2 cm2] = confusion(t2'-1,y2')
% % % hold on
% % % plotrocc(t2'-1,y2')
% % % hold off
% % % plotconfusion(t2'-1,y2')
% % % %%Allan algorithm+mine
%%