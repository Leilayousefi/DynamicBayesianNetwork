function [dags confdag] = PATK2(ns, traincell)

patlen =length(traincell);
[datn temp] = size(traincell{1});
confdag=zeros(datn);

for i = 1:patlen
    dags{i} = learn_struct_K2(cell2mat(traincell{i}), ns, [1:datn]);
    confdag=confdag+dags{i};
end

confdag=confdag/patlen;