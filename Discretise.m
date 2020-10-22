function [disdata] = Discretise(data,k)

[n dlen] = size(data)
disdata=zeros(n, dlen);
for i = 1:n
    temp=sort(data(i,:));
    policy=-1*ones(1,k);
    for j = 1:(k)
        policy(j)=temp(floor(j*dlen/(k)));
    end
    %policy
    for l =1:dlen
        for j =1:(k)
            if (data(i,l)>policy(j)) 
                disdata(i,l)=j;
            end
        end
    end
end