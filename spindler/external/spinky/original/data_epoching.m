function [seg]=data_epoching(data,epoch_length)
n=1;m=epoch_length;i=1;

while m<=length(data)
    seg{i}=data(:,n:m);
    n=n+epoch_length;
    m=m+epoch_length;
    i=i+1;
end
end

