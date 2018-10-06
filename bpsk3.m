close all
clear all
clc
L=input('enter length length of your  binary string ');
f=input('enter the frequency pf your modulated signal  ');
%n=f*L; %total no. of cycles in pulse train

A=randi([0 1],1,L);
B=2*A-1; %%convert to bipolar NRZ
t=0:0.001:L;
%T=1/f

AA=zeros(1,length(t));
%%
%convert to pulse
%tp=0:0.001*L:length(DD)/L;
for i=1:L
AA=AA+(0.5*(B(i)*(sign(t-(i-0.5)+0.5)-sign(t-(i-0.5)-0.5))));
end
BB=cos(2*pi*f*t);
CC=AA.*BB;
sound(CC)
%subplot(2,4,1),
figure
plot(t,AA)
grid on;
axis([0 L -1.5 1.5]);
%BB=cos(2*pi*f*t);
figure
%subplot(2,4,2),
plot(t,BB)
grid on;
axis([0 L -1.5 1.5]);
figure
%subplot(2,4,3),
plot(t,CC)
grid on;
axis([0 L -1.5 1.5]);

%%
%demodulation
 DD=CC.*BB;
 figure
 plot(DD)
 %%
 %decoding
 tp=0:(length(DD))/L;
 k=1;
 RCV=[];
 for (ii=1:L)
     SM=0;
     for(j=1:length(tp)-1)
    SM=SM+DD(k);
     k=k+1;
     
 end
     if (SM>0)
         RCV=[RCV 1];
     else
         RCV=[RCV 0];
     end
 end
 A
 RCV
%data_seg=data(37500*28.5:37500*31.5);
 