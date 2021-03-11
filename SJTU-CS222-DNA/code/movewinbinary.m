%基因识别算法——实数映射的"移动序列"信噪比曲线基因识别算法

function R = movewinbinary(ATCG,n0)
%--------------------------------------------------------------------------------------------------
[A ATCG] = fastaread('NC_012920_1.fasta');
%-------------------------------------------------genes6.mat所给数据------------------------------------------------------
% ATCG = ['CCTTAAAGAAGATAGCATGCCTTGAACAGTTGTACAGATGCTTTTTCAGCTGTGATCTGGGACAGGCTCCTGAAACAGTCCAAGCCTCCTCTATTTAATGGGCTATTGGTGATGCCAATCTCATGAGT'...
%     'TCCCGACCCTAGAGTCCCGTCACGACCCCTGACCCTTACACCACAACTCTCCCGAAGTCCCTCTGCACTACCCTTCTACCCCTTCGGAGACATCCACCTGTCTCGGTCCACCACACCTGTCCCCGACA'...
%     'TATATCACACATATACAACCACACTAGCAGGATAAAGTCTGATAACCAGTAGTAGAATAAAATTAAGCAACGAATTAGTACTAGTTTTAGGTCACAACAGTGACAACAACAGTTACACAGTTAATCAG'...
%     'CACCGTTCAGCCGCAGCCTCGCTCTCTCCGTACCTTCGTTGCTTTCGCGGAGCCTCTCTCCACCCTAAAAAAGGACCCAACAATCAGCAGTGGCCGCTCCACCCACTGCCCGTCTCCGCTCCGAACCC' ...
%     'CCACAGGTGTAACATTGTGTTTTCCTTGTCTGTGCCAGGGACACCTTGGCATCAGATGCCTGAAGGTAGCAGCTTGTCCCTCTTTGCCTTCTCTAATTAGATATTTCTCTCTCTCTCTCCCTCTCTCC'...
%     'ATGCCCATGATACTGGGGTACTGGGACATCCGCGGGGTGAGTGAGGGTCCGCTGCACTGTGGGACCGGGCGCGTGGGCGGGAAGTGCCGAGCGGCTGGGGACCGGCTCTAGGGACGGTACCCTCCTTA']
%------------------------------------------------------------------------------------------------------------
n0 = 3;
N = length(ATCG);
stan = zeros(1,N);
stan(3307:4262) = ones(1,4262-3307+1)*1;
stan(4470:5511) = ones(1,5511-4470+1)*1;
stan(5904:7445) = ones(1,7445-5904+1)*1;
stan(7586:8269) = ones(1,8269-7586+1)*1;

R = zeros(1,ceil((N-n0)/3));

UA = zeros(1,N);
UB = zeros(1,N);
[UA,UB] = binary(ATCG);%经过binary映射

for i = n0:3:N
    k = 1:i;
    tvectorA = zeros(1,i);%窗口长度为M的序列
    tvectorB = zeros(1,i);
    tvectorA = UA(k);
    tvectorB = UB(k);
    PA = fft(tvectorA,i);
    PB = fft(tvectorB,i);
    averEn = (sum(abs(PA).^2+abs(PB).^2))/i;
    PN3 = abs(PA(i/3+1)).^2+abs(PB(i/3+1)).^2;
%     PA = sum(exp(-j*2*pi*(k-1)/3).*tvectorA);
%     PB = sum(exp(-j*2*pi*(k-1)/3).*tvectorB);
%     averEn = i;
%     PN3 = abs(PA)^2 + abs(PB)^2;
    R(i/3) = PN3/averEn;
end
n =linspace(n0,N,length(R));
plot(n,2*R,round(n),stan(1:3:end),'r*');
axis([3000 7000 0 15]);

