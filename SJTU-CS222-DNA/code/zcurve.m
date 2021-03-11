function  deltaxyz = zcurve(S)
%S =['A' 'C' 'G' 'T' 'T' 'A' 'G'];
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
P = [1 -1 1 -1;1 1 -1 -1;1 -1 -1 1];
deltaxyz  = P*[UA;UG;UC;UT]



            