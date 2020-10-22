function [bnet2 LLtrace] = TrainHMM(train, order, class, k, intra1, inter1)
%takes in a test set as a cell of cells train{i}{x,t}

    seqnum=length(train);
    [n temp] = size(train{1});

    hs = k; % num of hidden states or 1 if LDS


    strain=train;    
    for i = 1:seqnum
        [n trainlen] = size(train{i});  

        %standardise
        straini=(strain{i});
%        for j = 1:n
%            straini(j,:)=((straini(j,:))- mean(straini(j,:)))/std(straini(j,:));
%        end
        
        %if hidden class
        traindata{i}=[cell(1,trainlen); (straini)];
        %if observed class
        %traindata{i}=[class{i}; (straini)];
    end

    

    
    nnodes = n+1;% vars + 1 hidden

    intra = zeros(nnodes,nnodes);
    inter = zeros(nnodes,nnodes);

    %discretise to learn inter using reveal & then add hidden node
%    disdata=strain;
%    for i = 1:n
%        disdata(i,:)=(strain(i,:)>mean(strain(i,:)))+1;
%    end

%    disdata={num2cell(disdata)}

    %use k2 to find HMM links
    %intra = learn_struct_K2(cell2num(disdata{1}), ones(1,n)*2, [1:nnodes], 'max_fan_in', 1)
%     intra(2:nnodes, 2:nnodes)=zeros(1:(nnodes-1), 1:(nnodes-1))
    %NBC structure
%     for i = 2:nnodes
%         intra(1,i)=1;
%     end
    %add BMI links to other Vars
    for i = 3:nnodes
    %    intra(2,i)=1;
    end
    
    %add links to complication 4 
    %inter(2,5)=1;
    %inter(3,5)=1;
    %inter(4,5)=1;
    


    %AR links - trans matrices
    for i = 2:nnodes
%         inter(i,i)=1;
    end
%     inter(1,1)=1;
 %   inter(2,2)=1; 
    
%     inter(2,3)=1;
%     inter(4,3)=1;
%    inter(5,4)=1;
    
    ns = ones(1,nnodes*2)*3;
    ns(1)=hs; 
    ns(nnodes+1)=hs;
    ns(3)=2;
    ns(4)=2;
    ns(5)=2;
    ns(6)=2;
    ns(7)=2;
    ns(8)=2;
    ns(9)=2;
    ns(10)=2;
    ns(11)=2;
    ns(12)=2;
    ns(13)=2;
    ns(14)=2;
    ns(nnodes+3)=2;
    ns(nnodes+4)=2;
    ns(nnodes+5)=2;
   ns(nnodes+6)=2;
   ns(nnodes+7)=2;
   ns(nnodes+8)=2;
   ns(nnodes+9)=2;
   ns(nnodes+10)=2;
ns(nnodes+11)=2;
ns(nnodes+12)=2;
ns(nnodes+13)=2;
ns(nnodes+14)=2;
% ns=[3 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3];
% ns=[3 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3];
    %use reveal to find any dynamics
    %inter = learn_struct_dbn_reveal(traindata, ns, 2, 0.5);

%     intra
%     inter
   
    %with hidden class
    obs = [2:nnodes];
    %with observed class
    %obs = [1:nnodes];
    
    ds = [1:nnodes];%if HMM
    %ds = [];%if LDS
% intra = [ones(1,nnodes); intra]
% intra(2:nnodes, 2:nnodes)=intra1;
% inter(2:nnodes, 2:nnodes)=inter1;
% intra (1,:) = ones(nnodes-1);
% intra (:,1) = zeros(nnodes-1);
% inter (1,:) = ones(nnodes-1);
% inter (:,1) = zeros(nnodes-1);
    inter=[zeros(1,nnodes-1); inter1];
    inter=[zeros(nnodes,1) inter];
    intra=[zeros(1,nnodes-1); intra1];
    intra=[zeros(nnodes,1) intra];
    for i = 2:nnodes
        intra(1,i)=1;
    end
    inter(1,1) =1;
    bnet = mk_dbn(intra, inter, ns, 'discrete', ds, 'observed', obs);%'eclass1', eclass1, 'eclass2', eclass2, 

    bnet.equiv_class = [[(1:nnodes)]',[(nnodes+1):(nnodes*2)]'];
    for i=2:nnodes
        bnet.CPD{i} = tabular_CPD(bnet, i);
    end
    for i=nnodes+2:nnodes*2
        bnet.CPD{i} = tabular_CPD(bnet, i);
    end

    bnet.CPD{1} = tabular_CPD(bnet, 1); %if HMM
    bnet.CPD{nnodes+1} = tabular_CPD(bnet, nnodes+1);%if HMM
    %bnet.CPD{1} = gaussian_CPD(bnet, 1); %if LDS
    %bnet.CPD{nnodes+1} = gaussian_CPD(bnet, nnodes+1);%if LDS
% draw_graph(bnet.dag)
    %engine = smoother_engine(hmm_2TBN_inf_engine(bnet)); %rigid hmm structure
    
    engine = smoother_engine(jtree_2TBN_inf_engine(bnet)); %no hidden variables?
    
    %engine = jtree_unrolled_dbn_inf_engine(bnet, length(traindata{1})); %slow
    
    [bnet2, LLtrace] = learn_params_dbn_em(engine, traindata, 'max_iter', 30);%, 'init_temp', 10, 'thresh', 1e-10);%, 'anneal', 0.8);

    %if there are dynamic links
%     if(sum(sum(inter))>0)
%         display('inter links')
%         temp = get_field(bnet2.CPD{nnodes+1},'cpt');
%         bnet2.CPD{1}=tabular_CPD(bnet2, 1, sum(temp)/sum(sum(temp)), 'adjustable',0);
%     else %if no dynamic links
%         display('no inter links')
%         bnet2.CPD{1+nnodes}=tabular_CPD(bnet2, 1, get_field(bnet2.CPD{1}, 'cpt'), 'adjustable',0);
%     end

    %to set the engine based on bnet2
    %engine = smoother_engine(hmm_2TBN_inf_engine(bnet2));
    %engine = jtree_unrolled_dbn_inf_engine(bnet2, order);
    %engine = smoother_engine(jtree_2TBN_inf_engine(bnet2));

    
    
    
return

