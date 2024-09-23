clear all
clc;
warning off;
csi_trace = read_bf_file('sample_data/abc_breath24bpm.dat');
data_size=length(csi_trace);  %�ݫʥ]�ƶq
M=data_size
k=[-28:2:-2,-1,1:2:27,28];%30

for i=1:M
    csi_entry = csi_trace{i};
    csi = get_scaled_csi(csi_entry);
    csi=csi(1,:,:);
    csi1=squeeze(csi).';    %30*3  A.'�O�@����m�AA���O�@�m��m
    csiabs=db(abs(squeeze(csi).'));%%�P�_�ӯx�}?��size(),���̤p�ȬO�_��1�A���O�o�ܭn��ܤ@?�@�����ĭ�
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

Signal=subphd.'
%subabs(isnan(subabs))=0
%subabs(isinf(subabs))=0
%Signal=subabs.'

%%MUSIC��k(Multiple Signal classification)
%%��u��??��??


%%%%%%%%%%%%%%%%%%% ��?? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M=30;%%�H???
%L=50;%%�H?�֩�
%N=data_size;%%?��??
N=data_size
lamda=0.056;%%�H?�i?
%theta=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];%%?�w?�i��V

%%%%%%%%%%%%%%%%%%%% �ͦ��H? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Amp=100;%%�H?�T��
Signal_single=zeros(1,L); %����1*L���s�x�}
for i=1:L
    Signal_single(1,i)=Amp*exp(-1i*2*pi/L*i);
end
%disp(Signal_single)
Signal=repmat(Signal_single,M,1); %���ƼƯ��ƥ��A�ܦ�4* ? ���x�}
%disp(Signal)
%}

%%%%%%%%%%%%%%%% �ͦ���? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Noise=normrnd(0,1,N,L);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=lamda/3;%%?��?�Z
%{
d=lamda/3;%%?��?�Z
A=zeros(N,M); %���ͤ@n*m(100*4)���s�x�}
for i=1:N
    for j=1:M
        A(i,j)=exp(-1i*2*pi*(i-1)*d*sind(theta(j))/lamda);
    end
end
%}
%%%%%%%%%%%%%%%%%%%% �H?�x? %%%%%%%%%%%%%%%%%%%%%%%%
%X=A*Signal+Noise;
X=Signal;
%%%%%%%%%%%%%%%%%%%%% ?��?��t�x? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R=X*X';  % (100*50�x�})*(50*100���x�})  ���t�x? X'���@�m��m
%%�S���Ȥ���
[V,D]=eig(R);   %[V,D] = eig2(R)��^D�S�x�ȩM�x�}���﨤�x�}(D)�AV��C�O�������k�S�x�V�q�AR*V = V*D , R=V*D*V-1
EVA=diag(D)';                      %?�S���ȯx??��?�����}??�@��
[EVA,I]=sort(EVA);                 %?�S���ȱƧ� ?�p��j
V=fliplr(V(:,I));                % ??�S���ڶq�Ƨ� �Ѥj�ƨ�p
En=V(:,M+1:N);  %N-M �}���Ӽ�-�H���Ӽ�

thetaT=-90:0.5:90 %�� thetaT �����ܤ�
Pmusic=zeros(1, length(thetaT)); %����1*361���x�}
for i=1:length(thetaT)
    S=zeros(1,length(N));   % 1~100 �H���Ӽ�
    for j=1:N   % 1~100 �H���Ӽ�
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
Pmusic=10*log10(Pmusic/max(Pmusic)); %�̤j���ݦ��H���l�Ŷ�;�Ѿl�������n�l�Ŷ�
%disp(Pmusic);
plot(thetaT,Pmusic)
xlabel('theta/��')
ylabel('log10(Pmusic)/����')
title('MUSIC��k��DOA���p')
grid on
