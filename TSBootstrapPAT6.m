function [trainIDpat, trainIDpos, traindat] = TSBootstrapPAT(data, var)

    %function sample a consecutive pair of samples from each cell array
    %of time series in data. Returns all appropriate training data ensuring
    %the binary variable, var is balanced
    
    patlen=length(data);
    datlen = [];
    for i = 1:patlen
        [datn datlen(i)] = size(data{i});
    end
    %allindices = [1:(datlen-1)];
    
    %get the training indices where var2(t+1) = 1 - sampling with replacement
    %for 20 times on average from each patient
    i=1;
    while i < patlen*10*0.01
        trainIDpat(i) = unidrnd(patlen);
        trainID(i) = unidrnd(datlen(trainIDpat(i))-1);
        data{trainIDpat(i)}(:,trainID(i)+1);
        if(cell2mat(data{trainIDpat(i)}(var,trainID(i)+1))==2)      
            display('return')
        else
            i=i+1;    
        end    
    end
    %get the training indices where var2(t+1) = 2 - sampling with replacement
    %for 10 times on average from each patient
    while i < patlen*10
        trainIDpat(i) = unidrnd(patlen);
        trainID(i) = unidrnd(datlen(trainIDpat(i))-1);
        data{trainIDpat(i)}(:,trainID(i)+1);
        if(cell2mat(data{trainIDpat(i)}(var,trainID(i)+1))==1)      
            display('return')
        else
            i=i+1;    
        end    
    end

    %get the test indices - those that are not sampled
    %testID = setdiff(allindices, trainID)

    %build the output cellarrays
    traindat = {};
    trainIDout = {};
    for i = 1:length(trainIDpat)
        patid=trainIDpat(i);
        posid=trainID(i);
        traindat{i} = [data{trainIDpat(i)}(:,trainID(i)) data{trainIDpat(i)}(:,trainID(i)+1)];
        trainIDpos{i} = [trainID(i) trainID(i)+1];
        
    end
    
%     testdat = {};
%     testIDout = {};
%     for i = 1:length(testID)
%         testdat{i} = [data(:,testID(i)) data(:,(testID(i)+1))]
%         testIDout{i} = [testID(i) testID(i)+1]
%     end
    
    
            