clear;clc; close all;
warning off;
csi_trace = read_bf_file('sample_data/abc_breath24bpm.dat');
data_size=length(csi_trace);  %看封包數量
M=200;

k=[-28:2:-2,-1,1:2:27,28];%30
%sub_phase=zeros(M,1);
%all=zeros(1,M);
%selsub=zeros(9,M);
m=15;

for i=1:M
    csi_entry = csi_trace{i};%依次讀各?數據包，為了平均
    %  rssi(i)=get_total_rss(csi_entry);
    csi = get_scaled_csi(csi_entry);
    csi=csi(1,:,:);
    csi1=squeeze(csi).';    %30*3  A.'是一般轉置，A’是共軛轉置
    csiabs=db(abs(squeeze(csi).'));%%判斷該矩陣?數size(),中最小值是否為1，不是得話要選擇一?作為有效值

    if(min(size(csiabs))>1)      %選RX天線
        maxValue=max(max(csiabs));
        [line,colunm]=find(csiabs==maxValue);
        csiabs=csiabs(:,colunm);
        csi1=csi1(:,colunm);
    else
        csiabs=csiabs';
        csi1=csi1';
    end
    
    phrad_measure=angle(csi1);%rad

    phrad_true=unwrap(phrad_measure);
    
    for t=1:30
        afterTransph(t)=phrad_true(t)-(phrad_true(30)-phrad_true(1))/56*k(t)-1/30*sum(phrad_true);%linear transformation
        subabs(t,i)=csiabs(t);
        subphd(t,i)=afterTransph(t);
    end
    %figure(1)
    subplot(1,3,1)
    plot(phrad_measure)
    xlabel('subcarriers');
    ylabel('Phase (rad)');
    title('未解卷繞原始相位');
    %legend(['RX=',num2str(colunm)])
    hold on 
    %figure(2)
    subplot(1,3,2)
    plot(phrad_true)
    xlabel('subcarriers');
    ylabel('Phase (rad)');
    title('解卷繞原始相位');
    hold on
    %figure(3)
    subplot(1,3,3)
    plot(afterTransph);
    hold on
    xlabel('subcarrier');
    ylabel('Phase (rad)');
    title('linear transformation');
    
end

for t=1:30
    subVar(t)=1/(M-1)*(sum(subabs(t,:).^2)-M*(1/M*sum(subabs(t,:))).^2);
end
maxVar=max(subVar);
[value,best_sub]=find(subVar==maxVar);
subphd=subphd(best_sub,:);

figure(4)
plot(subphd);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('linear transformation');
legend(['subcarrier =',num2str(best_sub)])

Fs=0.2;
T=1/Fs;
L=M;
Y=fft(subphd);

figure(5)
P2=abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:L/2)/L;
plot(f,P1);
title('FFT')
xlabel('f (Hz)')
ylabel('|P1(f)|')




%{
x=subphd;
[y,i,xmedian,xsigma] = hampel(x,10,4);
subphd=y;

figure(4)
subplot(2,1,1)
plot(x);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('linear transformation');
legend(['subcarrier =',num2str(b)])

subplot(2,1,2)
plot(subphd);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('linear transformation after hampel');
legend(['subcarrier =',num2str(b)])
%}
%{
figure(5);
selsub(3,i)=afterTransph(7);
lz=wden(selsub(3,:),'heursure','s','one',3,'sym3');
%selsub(3,:)=lz;
plot(lz);
xlabel('time(ms)');
ylabel('Phase (rad)');
title('CSI phase after filter');
%}
%{
figure(5);
di=wden(diff(subphd),'heursure','s','one',4,'db5');
plot(di);
hold on;
dii=wden(diff(subphd),'heursure','s','one',4,'db5');
plot(dii);
hold on;
xlabel('time(ms)');
ylabel('Phase (rad)');
title('phase (diff) afterfilter');
legend('vi','di');

[c,l]=wavedec(subphd,6,'db5'); 
a1=appcoef(c,l,'db5',1);
a2=appcoef(c,l,'db5',2); 
a3=appcoef(c,l,'db5',3); 
a4=appcoef(c,l,'db5',4); 
a5=appcoef(c,l,'db5',5); 
a6=appcoef(c,l,'db5',6); 

cA4=appcoef(c,l,'db5',1);
A4=wrcoef('a',c,l,'db5',1);

figure(6);
plot(A4);
hold on 
title('CSI after DWT (重構法) ');
xlabel('time(ms)');

%Butterworth
hfc = 300; 
lfc = 0;
fs = 1000;
order = 10;

[b,a] = butter(order, hfc/(fs/2));
figure(5)
freqz(b,a)
%noisy_sig = D{7};
dataIn = randn(1000,1);
dataOut = filter(b,a,subphd);
figure(6)
subplot(2,1,1)
plot(subphd)
hold on
title('original');
subplot(2,1,2)
plot(dataOut);
hold on
title('afterbutterworth');
Y=dataOut;

%FFT
F=fft(Y,1024);
figure(9)
plot(abs(F));

%STFT
fs = 1000;%
window = 512;
noverlap = window/2;
nfft=1024;

f_len = window/2 + 1;
f = linspace(0, 150e3, f_len);
% s= spectrogram(Y, window, noverlap);
% figure(1);
% imagesc(20*log10((abs(s))));xlabel('Samples'); ylabel('Freqency');
% colorbar;
%{
[s,f,t,p] = spectrogram(Y, window,nfft,f,fs);
figure(8);
imagesc(t, f, p);xlabel('Samples'); ylabel('Freqency');
colorbar;
%}

%{
[s,f,t] = spectrogram(Y,512,256,f,fs);
figure;
imagesc(t, f, 20*log10((abs(s))));xlabel('Samples'); ylabel('Freqency');
colorbar;
%}

figure(16)
s=spectrogram(Y,61,60,61,fs,'yaxis'); 
plot(s)
title('STFT');
hold on
%{
[s,f,t,ps]=spectrogram(Y,61,60,61,fs,'yaxis');
m=4:33
n=1:927
pmax=max(ps(m,n),[],1);
subplot(2,1,2)
% % figure(17)
plot(pmax,'linewidth',3,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10);
hold on
title('power curve');
%}


%{
for j=1:9
    %{
    figure(j+9)
    plot(selsub(j,:));
    hold on
    xlabel('sub(j)');
    ylabel('Phase (rad)');
    title('chosed_subcarrier(j)');
    %}
    all=all+selsub(j,:);
end

figure(31)
plot(all);
xlabel('time');
ylabel('Phase (rad)');
title('sum-chosedsub');
%}
%}
