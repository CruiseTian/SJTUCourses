%ÊµÊýÓ³Éä
function U = real(ATCG)
%ATCG =['ATCGTACTG'];
N = length(ATCG);
U = zeros(1,N);
for i = 1:N
    switch ATCG(i)
        case{'A'} 
            U(i) = 0;      
        case{'G'}
            U(i) = 1;               
        case{'C'}
            U(i) = 2;
        otherwise
             U(i) = 3;
                
    end
end
