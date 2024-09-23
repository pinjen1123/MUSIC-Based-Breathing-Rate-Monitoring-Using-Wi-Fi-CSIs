clear all
clc;
warning off;
csi_trace = read_bf_file('sample_data/abc_breath24bpm.dat');
data_size=length(csi_trace);  %看封包數量
M=data_size
k=[-28:2:-2,-1,1:2:27,28];%30

for i=1:M
    csi_entry = csi_trace{i};
    csi = get_scaled_csi(csi_entry);
    csi=csi(1,:,:);
    csi1=squeeze(csi).';    %30*3  A.'是一般轉置，A’是共軛轉置
    csiabs=db(abs(squeeze(csi).'));%%判斷該矩陣?數size(),中最小值是否為1，不是得話要選擇一?作為有效值
    csiabs=csiabs(:,1);
    csi1=csi1(:,1); 
   
  
    phrad_measure=angle(csi1);%rad
    phrad_true=unwrap(phrad_measure);
    
    for t=1:30
        afterTransph(t)=phrad_true(t)-(phrad_true(30)-phrad_true(1))/56*k(t)-1/30*sum(phrad_true);%linear transformation
        subabs(t,i)=csiabs(t);
        subphd(t,i)=afterTransph(t);
        subcsi(t,i)=csi1(t);
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

Signal=subphd.'
%subabs(isnan(subabs))=0
%subabs(isinf(subabs))=0
%Signal=subabs.'

%%MUSIC算法(Multiple Signal classification)
%%仿真均??天??


%%%%%%%%%%%%%%%%%%% 基本?? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M=30;%%信???
%L=50;%%信?快拍
%N=data_size;%%?元??
N=data_size
lamda=0.056;%%信?波?
%theta=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];%%?定?波方向

%%%%%%%%%%%%%%%%%%%% 生成信? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Amp=100;%%信?幅度
Signal_single=zeros(1,L); %產生1*L的零矩陣
for i=1:L
    Signal_single(1,i)=Amp*exp(-1i*2*pi/L*i);
end
%disp(Signal_single)
Signal=repmat(Signal_single,M,1); %重複數祖複本，變成4* ? 的矩陣
%disp(Signal)
%}

%%%%%%%%%%%%%%%% 生成噪? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Noise=normrnd(0,1,N,L);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=lamda/3;%%?元?距
%{
d=lamda/3;%%?元?距
A=zeros(N,M); %產生一n*m(100*4)的零矩陣
for i=1:N
    for j=1:M
        A(i,j)=exp(-1i*2*pi*(i-1)*d*sind(theta(j))/lamda);
    end
end
%}
%%%%%%%%%%%%%%%%%%%% 信?矩? %%%%%%%%%%%%%%%%%%%%%%%%
%X=A*Signal+Noise;
X=Signal;
%%%%%%%%%%%%%%%%%%%%% ?算?方差矩? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R=X*X';  % (100*50矩陣)*(50*100的矩陣)  協方差矩? X'為共軛轉置
%%特征值分解
[V,D]=eig(R);   %[V,D] = eig2(R)返回D特徵值和矩陣的對角矩陣(D)，V其列是對應的右特徵向量，R*V = V*D , R=V*D*V-1
EVA=diag(D)';                      %?特征值矩??角?提取并??一行
[EVA,I]=sort(EVA);                 %?特征值排序 ?小到大
V=fliplr(V(:,I));                % ??特征矢量排序 由大排到小
En=V(:,M+1:N);  %N-M 陣元個數-信號個數

thetaT=-90:0.5:90 %使 thetaT 產生變化
Pmusic=zeros(1, length(thetaT)); %產生1*361的矩陣
for i=1:length(thetaT)
    S=zeros(1,length(N));   % 1~100 信號個數
    for j=1:N   % 1~100 信號個數
         S(j)=exp(1i*2*pi*(j-1)*d*sind(thetaT(i))/lamda);  %(2*pi*d/lamda)*sin(theta)
    end
P=S*En*En'*S';

%disp("PPPPPPPPPPPPPPPPPPPPPP")
%disp(P)
PP(i) = P;
Pmusic(i)=abs(1/P);
%plot(thetaT,Pmusic)
end
minPP=min(PP);
[PPvalue,PPi]=find(PP==minPP);

figure(2)
Pmusic=10*log10(Pmusic/max(Pmusic)); %最大的看成信號子空間;剩餘的為噪聲子空間
%disp(Pmusic);
plot(thetaT,Pmusic)
xlabel('theta/度')
ylabel('log10(Pmusic)/分貝')
title('MUSIC算法的DOA估計')
grid on
