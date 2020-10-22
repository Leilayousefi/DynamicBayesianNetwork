function [outpred2] = TestHMM(bnet, test, class, k, order, step, var)
%function [pred LSS] = TestHMM(bnet, test, class, order, step)

%takes in a bnet and a testset as a cell of cells test{i}{x,t}
%     bnet
    outpred=[];
    seqnum=length(test);
    [n temp] = size(test{1});


    hs = k; % num of hidden states or 1 if LDS

    stest=test;
    
    for loop = 1:seqnum
        [n testlen] = size(test{loop});

        stesti=(stest{loop});
%         testdata{loop}=[cell(1,testlen); (stesti)]
        testdata{loop}=[stesti];
      
        testplotdat{loop}=stesti;
    end

    nnodes = n;% vars + 1 hidden


       
%     plotxy=[];
    %NEED TO BUILD A LOOP HERE FOR ALL TEST SET CELLS
    for loop=1:seqnum
        
        
    %to set the engine based on bnet2
%     engine = smoother_engine(hmm_2TBN_inf_engine(bnet));
    engine = jtree_unrolled_dbn_inf_engine(bnet, order);
    %engine = smoother_engine(jtree_2TBN_inf_engine(bnet2));

    
    %testlen=length(testplotdat{loop})
    
    %inc-step prediction on all data
    [n testlen] = size(test{loop});
    pred=zeros(n,testlen-(order-1));
    %confused=testdata{loop}
    
    for t = 1:(testlen-1)
        
    testinput = cell(nnodes,order);
  	for i = 1:nnodes
        testinput{i,1}=testdata{loop}{i,t};
        %testinput{i,2}=testdata{loop}{i,t+1};
    end
        testinput;
   
        [engine, ll] = enter_evidence(engine, testinput);

    %        marg = marginal_nodes(engine, 1, 1);        
    %        marg.T;
            marg = marginal_nodes(engine, 1, order);%order);
            % if HMM
%             besthx=1;
%             besthp=0;
%             for hx=1:hs
%                 if marg.T(hx)>besthp
%                     besthp=marg.T(hx);
%                     besthx=hx-1;
%                 end
%             end
%         pred(1,t)= marg.T(2);%besthx;%
        for i = 1:n
            marg = marginal_nodes(engine, i, order);
            bestx=1;
            bestp=0;
            for j=1:bnet.node_sizes(i)
                if marg.T(j)>bestp
                    bestp=marg.T(j);
                    bestx=j;
                end
            end
%             bestp
%             bestx
            pred(i,t)=bestx;%marg.mu;
            %TEMP
            if i==var %complication var 2)
                pred(i,t)=marg.T(2);
            end
        end
    
    % pred=pred';
    end%t
    
    %outpred=[outpred pred];
    outpred2{loop}= pred';
%    figure;
%    subplot(n+1,1,1)
    %hidden node
%    plot(pred(:,1), 'r');
%    hold on;    

    size(stesti);
    
   
%    for fig=2:n+1
  %      subplot(n+1,1,fig);
    %    figure  
    %    plot(pred(:,fig), 'r');
    %    hold on
%        plot(testplotdat{loop}(fig-1,order:testlen));
%        plotxy=[plotxy cell2num(testplotdat{loop}(fig-1,order:testlen))'];
        
 %       scatter(reshape(pred(:,fig),1,testlen-order+1), reshape(stest(fig,order:testlen)', 1, testlen-order+1), '.');
 %   end  
 %   plotxy
    %scatter(plotxy(1,:),plotxy(2,:));
    %line(plotxy(1,:),plotxy(2,:));

    pred=pred';

    
    LSSv=[];
    ACCv=[];
    outpred2{loop};
    [predlen temp]=size(outpred2{loop});
    
%     loop
    
%     [e cm] = confusion((outpred2{loop}(:,3)-1)',cell2num(test{loop}(2,2:predlen+1))-1)
%     %[e cm] = confusion((outpred{loop}(:,3)-1)',testdata{loop}{2,2:predlen}-1);
%     e2 = e2+(e*predlen);
%     cm2 = cm2+cm;
%     [e cm] = confusion((outpred2{loop}(:,4)-1)',cell2num(test{loop}(3,2:predlen+1))-1)
%     %[e cm] = confusion((outpred{loop}(:,3)-1)',testdata{loop}{2,2:predlen}-1);
%     e3 = e3+(e*predlen);
%     cm3 = cm3+cm;
%     [e cm] = confusion((outpred2{loop}(:,5)-1)',cell2num(test{loop}(4,2:predlen+1))-1)
%     %[e cm] = confusion((outpred{loop}(:,3)-1)',testdata{loop}{2,2:predlen}-1);
%     e4 = e4+(e*predlen);
%     cm4 = cm4+cm;
%         
%    
    
%     for i = 2:n+1
%         for j = 1:(predlen-order)
%             %if ((pred(j,i) - testdata{loop}{i-1,j+order-1}) ~= NaN)
%                 LSSv=[LSSv power((outpred2{loop}(j,i) - testdata{loop}{i-1,j+order-1}),2)];
%             %end 
%         end
%     end
% 
%     for j = 1:(predlen-order)
%        % if ((pred(j,1) - testdata{loop}{1,j+order-1}) ~=NaN)
%             res = 0;
%             if (outpred2{loop}(j,1) == class{loop}{1,j+order-1})%testdata{loop}{1,j+order-1})
%                 res = 1;
%             else
%                 res=0;
%             end
%             ACCv=[ACCv res];
%        % end 
%     end

%     ACC=[ACC nansum(ACCv)/(predlen-order)];
%     LSS=[LSS nansum(LSSv)];

    %END LOOP
end
% 
% e2 = e2/(sum(sum(cm2)));%length(outpred2);
% e3 = e3/(sum(sum(cm2)));%length(outpred2);
% e4 = e4/(sum(sum(cm2)));%length(outpred2);

end

