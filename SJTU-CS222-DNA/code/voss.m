% voss ӳ��
function [UA,UG,UC,UT]= voss(S)
%S =['ATCG'...
 %   'TACTG'];
N = length(S);
UA = zeros(1,N);
UG = zeros(1,N);
UC = zeros(1,N);
UT = zeros(1,N);
for i = 1:N
    switch S(i)
        case{'A'} 
            UA(i) = 1;      
        case{'G'}
            UG(i) = 1;               
        case{'C'}
            UC(i) = 1;
        otherwise
            UT(i) = 1;
                
    end
end



