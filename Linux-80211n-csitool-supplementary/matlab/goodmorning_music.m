clear all
clc;
warning off;
csi_trace = read_bf_file('sample_data/abc_breath24bpm.dat');
data_size=length(csi_trace);  %看封包數量
M=data_size;

k=[-28:2:-2,-1,1:2:27,28];%30


for i=1:M
    csi_entry = csi_trace{i};
    csi = get_scaled_csi(csi_entry);
    %csi=csi(1,:,:);
    csi=(csi(1,:,:)+csi(2,:,:)+csi(3,:,:))./3;
    csi1=squeeze(csi).';    %30*3  A.'是一般轉置，A’是共軛轉置
    csiabs=db(abs(squeeze(csi).'));%%判斷該矩陣?數size(),中最小值是否為1，不是得話要選擇一?作為有效值
    %csiabs=csiabs(:,1);
    csiabs=(csiabs(:,1)+csiabs(:,2)+csiabs(:,3))./3;
    %csi1=csi1(:,1); 
    csi1=(csi1(:,1)+csi1(:,2)+csi1(:,3)); 
    %{
    if(min(size(csiabs))>1)      %選RX天線
        maxValue=max(max(csiabs));
        [line,colunm]=find(csiabs==maxValue);
        csiabs=csiabs(:,colunm);
        csi1=csi1(:,colunm);
        %csiabs=csiabs(:,1);
        %csi1=csi1(:,1);     %csi1 ( 30*1)
    else
        csiabs=csiabs';
        csi1=csi1';
    end
    %}
    
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
%%%%%%%%%%%%%%%% 最佳子載波選擇 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t=1:30
    subVar(t)=1/(M-1)*(sum(subabs(t,:).^2)-mean(subabs(t,:))).^2;
end
maxVar=max(subVar);
[value,best_sub]=find(subVar==maxVar);
subphd=subphd(best_sub,:);

%%%%%%%%%%%%%%%% 去除 DC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subphd_noDC=subphd-mean(subphd)

subphd_noDC_hampel = hampel(subphd_noDC,10,5);

figure(4)
subplot(2,1,1)
plot(subphd_noDC);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('before hampel ');
legend(['subcarrier =',num2str(best_sub)])
subplot(2,1,2)
plot(subphd_noDC_hampel);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('after hampel');
legend(['subcarrier =',num2str(best_sub)])
%%%%%%%%%%%%%%%% 帶通濾波器 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs=10;
Ts=1/Fs;
t=Ts*(0:data_size-1);
passBand=[0.1,0.6];
filterOrder=4;
[b,a]=butter(filterOrder, passBand/(Fs/2));
subphd_noDC_filter = filter(b,a,subphd_noDC);


%%%%%%%%%%%%%%%%%%%%%% csi 時域圖 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(5)
plot(t,subphd_noDC_filter);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('CSI time domain ');
legend(['subcarrier =',num2str(best_sub)])


%%%%%%%%%%%%%%%% Music algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%N = [64 128 256]; % Number of samples used for each case. 採樣點
N=[64 128 256];

NumOfRuns = 10;    % (overlay) Number of frequency estimation functions to be calculated for every different data record.

% Open a new figure:
%h1 = figure('NumberTitle', 'off','Name', ... 
%              'Figure 8.37 Frequency Estimation for a Process Consisting of 4 Complex Exponentials in WGN', ...
%              'Visible','off','Position', [100 0 800 950]);

%sigmaw = sqrt(0.5);  %根號0.5 = 0.7071  和假設moise相關而已
% Create frequency axis:
L = data_size;
%w = 0:2*pi/L:2*pi*(1-1/L);  % 0 ~ (2*pi(L-1))/L  間隔 2*pi/L 共 L 個點
Fs=10;
Ts=1/Fs;
L=M;
t=Ts*(0:L-1);
w = Fs*(0:L-1)/L;

Pmusic = zeros(L);  %10*1024

for m=1:length(N)  % 採樣點個數 (length=4)
    %Estimate the Power Spectrum using the MUSIC algorithm:
    %p = 4;   % Number of complex exponentials present assumed known.
    %M = N(m); % Size of autocorrelation matrix to be used in the following methods:  M採樣點個數
    p = 1;
    M = N(m);
    datasize=data_size;
    Pmusic = music(subphd_noDC_filter,p,M,datasize).';   % Pmusic 長度 overlay*N採樣點
  
    maxPmusic=max(Pmusic);
    [value,frequency]=find(Pmusic==maxPmusic);
    frequency = frequency*Fs/datasize;
    disp(['Frequency =',num2str(frequency)])
    
    figure(1)
    subplot(3,1,m)
    plot(w,Pmusic,'k','LineWidth',0.1)
    hold on;
    title([' MUSIC Spectra Using ',num2str(N(m)),' samples'])
    grid on;
    axis tight;
    %ylim([-45 10])  % y-axis limits
    xlim([0 1]) 
    
    maxPmusic=max(Pmusic);
[value,frequency]=find(Pmusic==maxPmusic);
frequency = (frequency(1)-1)*Fs/datasize;
breath_rate=frequency*60;
disp(['Frequency = ',num2str(frequency)])
disp(['Breath rate = ',num2str(breath_rate),'bpm'])
end
maxPmusic=max(Pmusic);
[value,frequency]=find(Pmusic==maxPmusic);
frequency = (frequency(1)-1)*Fs/datasize;
breath_rate=frequency*60;
disp(['Frequency = ',num2str(frequency)])
disp(['Breath rate = ',num2str(breath_rate),'bpm'])
xlabel('Frequency');

