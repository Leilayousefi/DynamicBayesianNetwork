function [dags confdag] = PATReveal(ns, traincell)

patlen =length(traincell);
[datn temp] = size(traincell{1});
confdag=zeros(datn);

for i = 1:patlen
    dags{i} = learn_struct_dbn_reveal(traincell(i), ns, 2, 0.5);
    confdag=confdag+dags{i};
end

confdag=confdag/patlen;