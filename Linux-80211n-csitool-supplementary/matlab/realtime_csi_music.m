%   READ_BF_SOCKET Reads in a file of beamforming feedback logs.
%   This version uses the *C* version of read_bfee, compiled with
%   MATLAB's MEX utility.
%
% (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
%
%   Modified by Renjie Zhang, Bingxian Lu.
%   Email: bingxian.lu@gmail.com

function realtime_csi_music()

while 1
%% Build a TCP Server and wait for connection
    port = 8090;
    t = tcpip('0.0.0.0', port, 'NetworkRole', 'server');
    t.InputBufferSize = 1024;
    t.Timeout = 15;
    fprintf('Waiting for connection on port %d\n',port);
    fopen(t);
    fprintf('Accept connection from %s\n',t.RemoteHost);

%% Set plot parameters
    clf;
    axis([1,30,-10,30]);
    t1=0;
    m1=zeros(30,1);

%%  Starting in R2014b, the EraseMode property has been removed from all graphics objects. 
%%  https://mathworks.com/help/matlab/graphics_transition/how-do-i-replace-the-erasemode-property.html
    [VER DATESTR] = version();
    if datenum(DATESTR) > datenum('February 11, 2014')
        p = plot(t1,m1,'MarkerSize',5);
    else
        p = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);
    end

    xlabel('Subcarrier index');
    ylabel('SNR (dB)');

%% Initialize variables
    csi_entry = [];
    index = -1;                     % The index of the plots which need shadowing
    i_packet = -1;
    broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
    triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas

%% Process all entries in socket
    % Need 3 bytes -- 2 byte size field and 1 byte code
    while 1
        % Read size and code from the received packets
        s = warning('error', 'instrument:fread:unsuccessfulRead');
        try
            field_len = fread(t, 1, 'uint16');
        catch
            warning(s);
            disp('Timeout, please restart the client and connect again.');
            break;
        end

        code = fread(t,1);    
        % If unhandled code, skip (seek over) the record and continue
        if (code == 187) % get beamforming or phy data
            bytes = fread(t, field_len-1, 'uint8');
            bytes = uint8(bytes);
            if (length(bytes) ~= field_len-1)
                fclose(t);
                return;
            end
        else if field_len <= t.InputBufferSize  % skip all other info
            fread(t, field_len-1, 'uint8');
            continue;
            else
                continue;
            end
        end

        if (code == 187) % (tips: 187 = hex2dec('bb')) Beamforming matrix -- output a record
            csi_entry = read_bfee(bytes);
        
            perm = csi_entry.perm;
            Nrx = csi_entry.Nrx;
            if Nrx > 1 % No permuting needed for only 1 antenna
                if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                    if broken_perm == 0
                        broken_perm = 1;
                        fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                    end
                else
                    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
                end
            end
        end
    
        index = mod(index+1, 10);
        
        csi = get_scaled_csi(csi_entry);%CSI data
	%You can use the CSI data here.

	%This plot will show graphics about recent 10 csi packets
        set(p(index*3 + 1),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,1,:)).')), 'color', 'b', 'linestyle', '-');
        if Nrx > 1
            set(p(index*3 + 2),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,2,:)).')), 'color', 'g', 'linestyle', '-');
        end
        if Nrx > 2
            set(p(index*3 + 3),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,3,:)).')), 'color', 'r', 'linestyle', '-');
        end
        axis([1,30,-10,40]);
        drawnow;
        
        data_size=600
        i_packet = mod(i_packet+1,data_size);
        csi = csi(1,1,:);
        subcarrier_csi_abs(:,i+1)=abs(squeeze(csi).'); 
        csi_complex = squeeze(csi).';
        [csilt, ~] = linear_transform(csi_complex);
        csiph = angle(csilt.');
        subcarrier_csi_ph(:,i+1)=csiph; 
        
        if i_packet == data_size
            Fs=10;
            Ts=1/Fs;
            t=Ts*(0:599);
            subabs = subcarrier_csi_abs;
            subphd = subcarrier_csi_ph;
            
            for t=1:30
                subVar(t)=1/(data_size-1)*(sum(subabs(t,:).^2)-mean(subabs(t,:))).^2;
            end
            maxVar=max(subVar);
            [value,best_sub]=find(subVar==maxVar);
            subphd=subphd(best_sub,:)
            subphd_noDC=removeDC(subphd)
            
            figure(4)
            plot(t,subphd_noDC);
            hold on
            xlabel('time');
            ylabel('Phase (rad)');
            legend(['subcarrier =',num2str(best_sub)])
            title('origin CSI phase');
            subplot(2,1,2)
            plot(t,subphd_noDC_filter)
            xlabel('time');
            ylabel('Phase (rad)');
            legend(['subcarrier =',num2str(best_sub)])
            title('CSI phase after Butterworth Filter');
            hold on
  
            passBand=[0.1 0.6];
            filterOrder=4
            [b,a]=butter(filterOrder, passBand/(Fs/2));  %截止頻率:為了避免走樣，此頻率必須低於 取樣頻率/2 
            subphd_noDC_filter = filter(b,a,subphd_noDC);
            
            %N = [128]; % Number of samples used for each case. 採樣點
            Pmusic = zeros(data_size);  %10*1024
          
            p = 3;   % Number of complex exponentials present assumed known.
            nfft = 2^nextpow2(data_size)
            Pmusic = music(subphd_noDC_filter,p,128,nfft).';   % Pmusic 長度 overlay*N採樣點
            [value,frequency]=max(Pmusic(1:nfft));
            frequencyy = (frequency-1)*Fs/nfft
            breath_rate=frequencyy*60
            disp(['Frequency = ',num2str(frequencyy)])
            disp(['Breath rate = ',num2str(breath_rate),'bpm'])

            w = Fs*(0:nfft-1)/nfft;
            figure(6)
            plot(w,Pmusic,'k','LineWidth',0.1)
            legend(['Breath rate = ',num2str(breath_rate),'bpm'])
            hold on;
            xlabel('Frequency');
            title([' MUSIC Spectra Using ',num2str(N(m)),' samples'])
            grid on;
            axis tight;
            xlim([0 1]) 
        
            datatoxml(breath_rate)
        end
        i_packet = i_packet+1;
        csi_entry = [];
        
        
        
    end
    
    
%% Close file
    fclose(t);
    delete(t);
end

end