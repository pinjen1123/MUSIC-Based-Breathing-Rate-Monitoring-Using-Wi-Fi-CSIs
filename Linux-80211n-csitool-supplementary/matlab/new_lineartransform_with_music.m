clear;clc; close all;
warning off;

csi_entry = [];
triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas

probability = 0;

csi_trace = read_bf_file('sample_data/abc_breath24bpm.dat');
data_size = length(csi_trace);
M=data_size;

first_ant_csi = ones(30,1)*nan;
second_ant_csi = ones(30,1)*nan;
third_ant_csi = ones(30,1)*nan;
first_ph_csi = ones(30,1)*nan;  
second_ph_csi = ones(30,1)*nan;
third_ph_csi = ones(30,1)*nan;

[maxTx,maxRx] = find_antenna(csi_trace,data_size);

%%
for i = 1:data_size
    csi_entry = csi_trace{i};
    perm = csi_entry.perm;
    Nrx = csi_entry.Nrx;
    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
    
    csi = get_scaled_csi(csi_entry);%CSI data : 3*3*30

    csi= csi(maxTx,maxRx,:);
    csiabs=abs(squeeze(csi).');
    subcarrier_csi_abs(:,i)=csiabs; 
    csis = squeeze(csi).';
    [csilt, ~] = linear_transform(csis);
    csip = angle(csilt.');
    subcarrier_csi_ph(:,i)=csip;

    csi_entry = [];
end
%% 選擇天線
figure(1)
%subplot(1,2,2)
plot(subcarrier_csi_abs);
hold on
xlabel('subcarrier');
ylabel('Phase (rad)');
title('CSI Phase');

subabs = subcarrier_csi_abs;
subphd = subcarrier_csi_ph;

%% 最佳子載波選擇 %%
for t=1:30
    subVar(t)=1/(data_size-1)*(sum(subabs(t,:).^2)-mean(subabs(t,:))).^2;
end
maxVar=max(subVar);
[value,best_sub]=find(subVar==maxVar);
subphd=subphd(best_sub,:);

%% 去除 DC %%
subphd_noDC=removeDC(subphd);

%% Fs 採樣頻率設定
Fs=10;
Ts=1/Fs;
t=Ts*(0:data_size-1);

%% 帶通濾波器 %%

passBand=[0.16 0.6];
filterOrder=4;
[b,a]=butter(filterOrder, passBand/(Fs/2));  %截止頻率:為了避免走樣，此頻率必須低於 取樣頻率/2 
%[b,a]=butter(filterOrder, 0.16/(Fs/2),'high');
subphd_noDC_filter = filter(b,a,subphd_noDC);


%subphd_noDC = subphd_noDC - nono

%% csi 時域圖 %%
figure(2)
subplot(2,1,1)
plot(t,subphd_noDC,'k','LineWidth',0.1);
hold on
xlabel('time');
ylabel('Phase (rad)');
legend(['subcarrier =',num2str(best_sub)])
title('origin CSI phase');
subplot(2,1,2)
plot(t,subphd_noDC_filter,'k','LineWidth',0.1)
xlabel('time');
ylabel('Phase (rad)');
legend(['subcarrier =',num2str(best_sub)])
title('CSI phase after Butterworth Filter');
hold on
%% 時域圖動畫
%{
figure(9)
h=plot(t,subphd_noDC_filter)
tic
for i = 1:data_size
    subphd_noDC_filter=subphd_noDC_filter(i+1)
	set(h, 'ydata', subphd_noDC_filter);		% 設定新的 y 座標
    axis([-Inf Inf -1 1]);	
	drawnow				% 立即作圖
end
toc
%}

%{
h=animatedline;
a=tic;
for k = 1:length(t)
    addpoints(h,t(k),subphd_noDC_filter(k));
    b = toc(a); % check timer
    if b > (1/5000)
        drawnow % update screen every 1/30 seconds
        a = tic; % reset timer after updating
    end
    
end
drawnow
%}

%% Music algorithm %%

M = 128; % Size of autocorrelation matrix to be used in the following methods:  M採樣點個數
L = data_size;

Pmusic = zeros(data_size);  %10*1024
index=0;

%Estimate the Power Spectrum using the MUSIC algorithm:
p = 3;   % Number of complex exponentials present assumed known.

nfft = 2^nextpow2(data_size);
Pmusic = music(subphd_noDC_filter,p,M,nfft).'; 
Pmusic = Pmusic(1:nfft/2);
[value,frequency]=max(Pmusic);

frequencyy = (frequency-1)*Fs/nfft;
breath_rate=frequencyy*60;
disp(['Frequency = ',num2str(frequencyy)])
disp(['Breath rate = ',num2str(breath_rate),'bpm'])

w = Fs*(0:nfft/2-1)/nfft;
figure(3)
plot(w,Pmusic,'k','LineWidth',0.1)
legend(['Breath rate = ',num2str(breath_rate),'bpm'])
hold on;
title(' MUSIC Spectra of CSI ')
grid on;
axis tight;
xlim([0 1]) 

xlabel('Frequency (Hz)');
ylabel('Power (dB)');
%% xml 檔
datatoxml(breath_rate);

%% Butterworth Filter draw
% fs=10;			% Sampling rate
% passBand=[0.16 0.6];		% Cutoff frequency
% allH=[];
% for filterOrder=1:6
% 	[b, a]=butter(filterOrder, passBand/(fs/2));
% 	% === Plot frequency response
% 	[h, w]=freqz(b, a);
% 	allH=[allH, h];
% end
% figure(100)
% plot(w/pi*fs/2, abs(allH)); title('Frequency response of a bandpass butterworth filter');
% legend('order=1', 'order=2', 'order=3', 'order=4', 'order=5', 'order=6', 'order=7', 'order=8');


