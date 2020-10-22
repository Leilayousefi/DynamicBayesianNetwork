
var=2;
patlen=length(outpred)
y=[];
t=[];
for i = 1:patlen
    temp1=cell2mat(testcell{i}(var,:))
    temp1=temp1(2:length(temp1))'
    temp2=outpred{i}(:,var+1)

    y = [y;temp2];
    t = [t;temp1];
end
[err cm] = confusion(t'-1,y')
[fp tp]= roc([t-1,y])
auc1 = auc([t-1,y])
plot(tp,fp)
