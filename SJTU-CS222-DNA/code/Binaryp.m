clear all; 
ge = fastaread('NC_012920_1_cds.txt');
gene = ge(4,1).Sequence; 
n=length(gene); 
for i=1:n 
    if strcmp('A',gene(i))        
        a(i)=0; 
        b(i)=0;
    elseif strcmp('T',gene(i))  
        a(i)=0; 
        b(i)=1;
    elseif strcmp('C',gene(i))  
        a(i)=1; 
        b(i)=0;
    elseif strcmp('G',gene(i))  
        a(i)=1; 
        b(i)=1;
    end
end
fa=fft(a,n);
fb=fft(b,n);
for k=1:n 
    p(k)=abs(fa(k))^2 + abs(fb(k))^2; 
end 
plot(p(floor(n/100):n)) 
e=sum(p)/n 
p1=[p(round(n/3)-2),p(round(n/3)-1),p(round(n/3)),p(round(n/3)+1),p(round(n/3)+2)]; 
pn3=max(p1); 
r=pn3/e