clear all
clc;
warning off;
csi_trace = read_bf_file('sample_data/luo_breath.dat');
data_size=length(csi_trace);  %�ݫʥ]�ƶq
M=data_size


k=[-28:2:-2,-1,1:2:27,28];%30
%sub_phase=zeros(M,1);
%all=zeros(1,M);
%selsub=zeros(9,M);
%m=15;

for i=1:M
    csi_entry = csi_trace{i};
    csi = get_scaled_csi(csi_entry);
    %csi=csi(1,:,:);
    csi=(csi(1,:,:)+csi(2,:,:)+csi(3,:,:))./3;
    csi1=squeeze(csi).';    %30*3  A.'�O�@����m�AA���O�@�m��m
    csiabs=db(abs(squeeze(csi).'));%%�P�_�ӯx�}?��size(),���̤p�ȬO�_��1�A���O�o�ܭn��ܤ@?�@�����ĭ�
    %csiabs=csiabs(:,1);
    csiabs=(csiabs(:,1)+csiabs(:,2)+csiabs(:,3))./3;
    %csi1=csi1(:,1); 
    csi1=(csi1(:,1)+csi1(:,2)+csi1(:,3));
    %{
    if(min(size(csiabs))>1)      %��RX�ѽu
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
        subphd(t,i)=afterTransph(t)
    end
    
    figure(1)
    plot(csiabs)
    xlabel('subcarriers');
    ylabel('Amplititude');
    title('CSI���T');
    hold on 
    
    figure(2)
    subplot(1,3,1)
    plot(phrad_measure)
    xlabel('subcarriers');
    ylabel('Phase (rad)');
    title('���Ѩ�¶��l�ۦ�');
    %legend(['RX=',num2str(colunm)])
    hold on 
    %figure(2)
    subplot(1,3,2)
    plot(phrad_true)
    xlabel('subcarriers');
    ylabel('Phase (rad)');
    title('�Ѩ�¶��l�ۦ�');
    hold on
    %figure(3)
    subplot(1,3,3)
    plot(afterTransph);
    hold on
    xlabel('subcarrier');
    ylabel('Phase (rad)');
    title('linear transformation');
    
end
%%%%%%%%%%%%%%%% �̨Τl���i��� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t=1:30
    subVar(t)=1/(M-1)*(sum(subabs(t,:).^2)-mean(subabs(t,:))).^2;
end
maxVar=max(subVar);
[value,best_sub]=find(subVar==maxVar);
subphd=subphd(best_sub,:)

%%%%%%%%%%%%%%% �h�Ӥl���i %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subphd_multi=(subphd(13,:)+subphd(14,:)+subphd(15,:)+subphd(16,:))./4

%%%%%%%%%%%%%%%% �h�� DC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subphd_noDC=subphd-mean(subphd)
%subphd_multi_noDC=subphd_multi-mean(subphd_multi)

%%%%%%%%%%%% �h�����`�� Hampel & �����p�i %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%x=subphd_noDC;
%[y,i,xmedian,xsigma] = hampel(x,10,4); %hampel
%yd=wden(y,'heursure','s','one',2,'sym3');


figure(4)
%subplot(2,1,1)
plot(subphd_noDC);
hold on
xlabel('time');
ylabel('Phase (rad)');
title('linear transformation ');
legend(['subcarrier =',num2str(best_sub)])
%{
subplot(2,1,2)
plot(yd)
hold on
xlabel('time');
ylabel('Phase (rad)');
title('linear transformation after denoise');
%}

Fs=10
Ts=1/Fs
L=M
t=Ts*(0:L-1)
%[peak,locs]=findpeaks(x,'MinPeakProminence')
%findpeaks(select,Fs,'MinPeakProminence',1)



%[pks,locs] = findpeaks(x,Fs,'MinPeakDistance',60/37)
%{
figure(10)
plot(t,x)
hold on
plot(locs,pks,'r*')
xlabel('time');
ylabel('Phase (rad)');
title('find peak (linear transformation after denoise) ');
%}



%{
yd=subphd_1;
yd_0=yd(1:199)
%yd_1=yd(101:200)
yd_2=yd(201:399)
%yd_3=yd(301:400)
yd_4=yd(401:599)
%yd_5=yd(501:600)
yd_6=yd(601:799)
%}

Fs=10;
T=1/Fs;
L=M;
passBand=[0.16,0.6];
filterOrder=8
[b,a]=butter(filterOrder, passBand/(Fs/2));
%yd1=filter(b,a,yd);
subphd_noDC_filter=filter(b,a,subphd_noDC);
%Y=fft(yd)  %�S�o�i��
%Y1=fft(yd1)  %���o�i��
%Ymulti=fft(subphd_multi_noDC_filter)
Y=fft(subphd_noDC_filter)


figure(5)
P2=abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:L/2)/L;
plot(f,P1);
title('FFT after DWT')
xlabel('f (Hz)')
ylabel('|P1(f)|')
%{
figure(6)
P2=abs(Y1/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:L/2)/L;
plot(f,P1);
title('FFT after DWT with filter')
xlabel('f (Hz)')
ylabel('|P1(f)|')
%}
%{
figure(7)
P2=abs(Ymulti/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:L/2)/L;
plot(f,P1);
title('Multiple subcarrier FFT with filter')
xlabel('f (Hz)')
ylabel('|P1(f)|')
%}

%{
%%%%% �|�[ �M�o�i�� %%%%%%
ydd_0=filter(b,a,yd_0);
ydd_2=filter(b,a,yd_2);
ydd_4=filter(b,a,yd_4);
ydd_6=filter(b,a,yd_6);


Yd_0=fft(yd_0)
%Yd_1=fft(yd_1)
Yd_2=fft(yd_2)
%Yd_3=fft(yd_3)
Yd_4=fft(yd_4)
%Yd_5=fft(yd_5)
Yd_6=fft(yd_6)

%%%% Ydd ���M�o�i�����|�[ %%%%%%
Ydd_0=fft(ydd_0)
%Yd_1=fft(yd_1)
Ydd_2=fft(ydd_2)
%Yd_3=fft(yd_3)
Ydd_4=fft(ydd_4)
%Yd_5=fft(yd_5)
Ydd_6=fft(ydd_6)




L1=199

figure(10)
P2_0=abs(Yd_0/L1);
P1_0 = P2_0(1:L1/2+1);
P1_0(2:end-1) = 2*P1_0(2:end-1);
f = Fs*(0:L1/2)/L1;
%{
P2_1=abs(Yd_1/L1);
P1_1 = P2_1(1:L1/2+1);
P1_1(2:end-1) = 2*P1_1(2:end-1);
%}
P2_2=abs(Yd_2/L1);
P1_2 = P2_2(1:L1/2+1);
P1_2(2:end-1) = 2*P1_2(2:end-1);
%{
P2_3=abs(Yd_3/L1);
P1_3 = P2_3(1:L1/2+1);
P1_3(2:end-1) = 2*P1_3(2:end-1);
%}
P2_4=abs(Yd_4/L1);
P1_4 = P2_4(1:L1/2+1);
P1_4(2:end-1) = 2*P1_4(2:end-1);
%{
P2_5=abs(Yd_5/L1);
P1_5 = P2_5(1:L1/2+1);
P1_5(2:end-1) = 2*P1_5(2:end-1);
%}
P2_6=abs(Yd_6/L1);
P1_6 = P2_6(1:L1/2+1);
P1_6(2:end-1) = 2*P1_6(2:end-1);

PP=(P1_0+P1_2+P1_4+P1_6)./4

plot(f,PP);
title('FFT')
xlabel('f (Hz)')
ylabel('|P1(f)|')
title('sum of FFT (no hampel&DWT)')


%%%%% �|�[ �M�o�i�� �e�� %%%%%%%
figure(11)
P2_0=abs(Ydd_0/L1);
P1_0 = P2_0(1:L1/2+1);
P1_0(2:end-1) = 2*P1_0(2:end-1);
f = Fs*(0:L1/2)/L1;
%{
P2_1=abs(Yd_1/L1);
P1_1 = P2_1(1:L1/2+1);
P1_1(2:end-1) = 2*P1_1(2:end-1);
%}
P2_2=abs(Ydd_2/L1);
P1_2 = P2_2(1:L1/2+1);
P1_2(2:end-1) = 2*P1_2(2:end-1);
%{
P2_3=abs(Yd_3/L1);
P1_3 = P2_3(1:L1/2+1);
P1_3(2:end-1) = 2*P1_3(2:end-1);
%}
P2_4=abs(Ydd_4/L1);
P1_4 = P2_4(1:L1/2+1);
P1_4(2:end-1) = 2*P1_4(2:end-1);
%{
P2_5=abs(Yd_5/L1);
P1_5 = P2_5(1:L1/2+1);
P1_5(2:end-1) = 2*P1_5(2:end-1);
%}
P2_6=abs(Ydd_6/L1);
P1_6 = P2_6(1:L1/2+1);
P1_6(2:end-1) = 2*P1_6(2:end-1);

PP=(P1_0+P1_2+P1_4+P1_6)./4

plot(f,PP);
title('FFT')
xlabel('f (Hz)')
ylabel('|P1(f)|')
title('sum of FFT with filter (no hampel&DWT)')






%{
figure(9); 
YY = fft(yd,L); %��FFT�ܴ� 
Ayy = (abs(YY)); %���� 
plot(Ayy(1:L)); %��ܭ�l��FFT�ҭȵ��G 
title('FFT �ҭ�'); 
  
figure(10); 
Ayy=Ayy/(L/2);   %���⦨��ڪ��T�� 
Ayy(1)=Ayy(1)/2; 
F=([1:L]-1)*Fs/L; %���⦨��ڪ��W�v�� 
plot(F(1:L/2),Ayy(1:L/2));   %��ܴ���᪺FFT�ҭȵ��G 
title('�T��-�W�v���u��'); 
%}

%{
fs = 10;            % �ļ��W�v                    
T = 1/fs;             % �ļ˶g��       
L = M;             % �I�����H������
t = (0:L-1)*T;        % �ɶ��ڶq
% ���ͰT��
%fs = 1000;  % �����W�v1KHz
%t = 0:1/fs:1-1/fs;
%N=size(t,2);


% �u�ɳť߸��ܴ�
wlen=64;%�]�w�������סC�����V���ɶ��ѪR�׶V�t�A�W�v�ѪR�׶V�n�C
hop=1;%�C���������B���A�̤p��1�C�V�p�v�H�ɶ���׶V�n�A���p��q�j�C
%x=wkeep1(x,N+1*wlen);%�����I�_
h=hamming(wlen);%�]�w������������
noverlap=wlen-hop
%window=100
%noverlap=0.5*window
[S, F, T, P] = spectrogram(yd1,h,noverlap,L,fs);   % S�OF��T�C���W�v�p�ȡAP�O��������q�бK��
figure(7);
surf(T,F,abs(S));
%axis([0,T,0,0.6]) 
colorbar;
shading flat;
%set(gca,'YDir','normal')
xlabel('�ɶ� t/s');
ylabel('�W�v f/Hz');
title('�u�ɳť߸����W��');

figure(8);
contour(T,F,abs(S));
%axis([0,T,0,1]) 
colorbar;
set(gca,'YDir','normal')
xlabel('�ɶ� t/s');
ylabel('�W�v f/Hz');
title('�u�ɳť߸����W��');
%}
%}