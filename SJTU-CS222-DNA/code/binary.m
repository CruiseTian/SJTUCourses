% binary映射
function [UA,UB]= binary(S)
%S =['ATCG'...
 %   'TACTG'];
N = length(S);
UA = zeros(1,N);
UB = zeros(1,N);
for i = 1:N
    switch S(i)
        case{'A'} 
            UA(i) = 0;
            UB(i) = 0;
        case{'G'}
            UA(i) = 0;
            UB(i) = 1;               
        case{'C'}
            UA(i) = 1;
            UB(i) = 0;
        otherwise
            UA(i) = 1;
            UB(i) = 1;
    end
end



