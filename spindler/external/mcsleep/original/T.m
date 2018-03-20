function [ y ] = T( x )
%applies the teager operator, and returns the output
%y = T(x)

for i = 2:length(x)-1
    y(i) = x(i)^2 - x(i-1)*x(i+1);
end

end

