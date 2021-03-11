clear all; 
ge = fastaread('NC_012920_1_cds.txt');
gene = ge(4,1).Sequence; 
n=length(gene);
for i=1:n 
    if strcmp('A',gene(i))         
        ua(i)=1;     
    else
        ua(i)=0;
    end
end
for i=1:n 
    if strcmp('G',gene(i))         
        ug(i)=1;     
    else
        ug(i)=0;
    end
end
for i=1:n 
    if strcmp('C',gene(i))         
        uc(i)=1;     
    else
        uc(i)=0;     
    end
end
for i=1:n 
    if strcmp('T',gene(i))         
        ut(i)=1;     
    else
        ut(i)=0;     
    end
end
a=[1,-1,1,-1;1,1,-1,-1;1,-1,-1,1]; 
dxyz=a*[ua;uc;ug;ut]; 
fdx=fft(dxyz(1,:),n); 
fdy=fft(dxyz(2,:),n); 
fdz=fft(dxyz(3,:),n); 
for k=1:n 
    p(k)=abs(fdx(k))^2+abs(fdy(k))^2+abs(fdz(k))^2; 
end 
plot(p(floor(n/100):n)) 
e=sum(p)/n;
p1=[p(round(n/3)-2),p(round(n/3)-1),p(round(n/3)),p(round(n/3)+1),p(round(n/3)+2)]; 
pn3=max(p1); 
r=pn3/e