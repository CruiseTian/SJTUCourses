%基因识别算法——实数映射时基于固定长度滑动窗口上的频谱曲线基因识别算法 
function fix_wp = fixwinpbinary(ATCG,M)

[a ATCG]=fastaread('NC_012920_1.fasta') %人体线粒体基因
N = length(ATCG);
stan = zeros(1,N);
stan(3307:4262) = ones(1,4262-3307+1)*0.1;
stan(4470:5511) = ones(1,5511-4470+1)*0.1;
stan(5904:7445) = ones(1,7445-5904+1)*0.1;
stan(7586:8269) = ones(1,8269-7586+1)*0.1;

M = 513;
N = length(ATCG);

UA = zeros(1,N);
UB = zeros(1,N);
[UA,UB] = binary(ATCG);%经过binary映射

P = zeros(1,N);
for i = (M-1)/2+1:N-(M-1)/2
    k = i-(M-1)/2:i+(M-1)/2;
    tvectorA = zeros(1,M);%窗口长度为M的序列
    tvectorB = zeros(1,M);
    tvectorA = UA(k);
    tvectorB = UB(k);
    PA = sum(exp(-j*2*pi*k/3).*tvectorA);
    PB = sum(exp(-j*2*pi*k/3).*tvectorB);
% fftA = fft(tvectorA,M);
% fftG = fft(tvectorG,M);
% fftC = fft(tvectorC,M);
% fftT = fft(tvectorT,M);
% PA = fftA(M/3);
% PG = fftG(M/3);
% PC = fftC(M/3);
% PT = fftT(M/3);
    P(i) = abs(PA)^2 + abs(PB)^2;
end 
plot((M-1)/2:N-(M-1)/2-1,P((M-1)/2:N-(M-1)/2-1)/max(P),(M-1)/2:N-(M-1)/2-1,stan((M-1)/2:N-(M-1)/2-1),'r*');
hold on;
axis([3000 7000 0 1]);
