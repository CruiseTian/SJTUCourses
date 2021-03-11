clc;
clear;
filename = 'actual.wav';

dpin=[697,770,852,941];
gpin=[1209,1336,1477,1633];
hm=['1','2','3','+';'4','5','6','-';'7','8','9','*';'#','0','.','/'];

[x_original,Fs] = audioread(filename);
sound(x_original,Fs);

T = 0.2;                     %采样时间
dt = 1/Fs;                %采样时间间隔
N = T*Fs;                    %采样点数
t = linspace(0,T,N);       %采样时间序列
N1 = 1024*2;              %快速傅里叶变换采样点数

wp=3400*pi/Fs;
ws=3600*pi/Fs;
wd=abs(wp-ws);
N=ceil(4*pi/wd);
wc=(wp+ws)/2;
b=fir1(N,wc/pi,hamming(N+1));
x_filt=filter(b,1,x_original);
y = fft(x_filt,N1);             %快速傅里叶变换，第一个参数为时域函数，第二个参数为FFT的点数。N1的值应为2的n次幂
y = abs(y)/(N1/2);              %取实数并进行幅值修正
f = linspace(0,Fs,N1);          %频率序列
plot(f,y);

%寻找端点
len=length(x_filt);
yk=fft(x_filt,len);
fp=floor(1000*len/Fs);
% nk=[0:len-1];
% fk=Fs*nk/len;
% plot(fk,abs(yk))
% grid on

%找低频最大能量对应频率
p=abs(yk(1:fp));
a1=find(p==max(p));
n1=floor(a1*Fs/len);
nd=find(abs(dpin-n1)<15); %对应低频群中的位置

%找高频最大能量对应频率
p=abs(yk(fp:2*fp));
a2=find(p==max(p));
n2=1000+floor(a2*Fs/len);
ng=find(abs(gpin-n2)<15); %对应高频群中的位置

num=hm(nd,ng);

fprintf('这个按键为：')
num