function [maxTx,maxRx]=find_antenna(csi_trace,data_size)
    csi_tx1_rx1_abs = ones(30,data_size)*nan;
    csi_tx1_rx2_abs = ones(30,data_size)*nan;
    csi_tx1_rx3_abs = ones(30,data_size)*nan;
    csi_tx2_rx1_abs = ones(30,data_size)*nan;
    csi_tx2_rx2_abs = ones(30,data_size)*nan;
    csi_tx2_rx3_abs = ones(30,data_size)*nan;
    csi_tx3_rx1_abs = ones(30,data_size)*nan;
    csi_tx3_rx2_abs = ones(30,data_size)*nan;
    csi_tx3_rx3_abs = ones(30,data_size)*nan;
    
    for i=1:data_size
        csi_entry = csi_trace{i};
        perm = csi_entry.perm;
        Ntx = csi_entry.Ntx;
        Nrx = csi_entry.Nrx;
        csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);

        csi = get_scaled_csi(csi_entry);%CSI data : 3*3*30
        csi_tx1_rx1 = csi(1,1,:); csi_tx1_rx1_abs(:,i)=abs(squeeze(csi_tx1_rx1).');
        %% Tx=1 
        if Nrx>1
            csi_tx1_rx2 = csi(1,2,:); csi_tx1_rx2_abs(:,i)=abs(squeeze(csi_tx1_rx2).');
        end
        if Nrx>2
            csi_tx1_rx3 = csi(1,3,:); csi_tx1_rx3_abs(:,i)=abs(squeeze(csi_tx1_rx3).');
        end 
        %% Tx=2
        if Ntx>1 
            csi_tx2_rx1 = csi(2,1,:); csi_tx2_rx1_abs(:,i)=abs(squeeze(csi_tx2_rx1).');
            if Nrx>1
                csi_tx2_rx2 = csi(2,2,:); csi_tx2_rx2_abs(:,i)=abs(squeeze(csi_tx2_rx2).');
            end
            if Nrx>2
                csi_tx2_rx3 = csi(2,3,:); csi_tx2_rx3_abs(:,i)=abs(squeeze(csi_tx2_rx3).');
            end
        end
      %% Tx=3
        if Ntx>2
            csi_tx3_rx1 = csi(3,1,:); csi_tx3_rx1_abs(:,i)=abs(squeeze(csi_tx3_rx1).');
            if Nrx>1
                csi_tx3_rx2 = csi(3,2,:); csi_tx3_rx2_abs(:,i)=abs(squeeze(csi_tx3_rx2).');
            end
            if Nrx>2
                csi_tx3_rx3 = csi(3,3,:); csi_tx3_rx3_abs(:,i)=abs(squeeze(csi_tx3_rx3).');
            end
        end
        csi_entry = [];
    end
    
    csi_tx1_rx1_power=sum(sum(power(csi_tx1_rx1_abs.',2)))-sum(power(mean(csi_tx1_rx1_abs.'),2));
    csi_tx2_rx1_power=sum(sum(power(csi_tx2_rx1_abs.',2)))-sum(power(mean(csi_tx2_rx1_abs.'),2));
    csi_tx3_rx1_power=sum(sum(power(csi_tx3_rx1_abs.',2)))-sum(power(mean(csi_tx3_rx1_abs.'),2));
    csi_tx1_rx2_power=sum(sum(power(csi_tx1_rx2_abs.',2)))-sum(power(mean(csi_tx1_rx2_abs.'),2));
    csi_tx2_rx2_power=sum(sum(power(csi_tx2_rx2_abs.',2)))-sum(power(mean(csi_tx2_rx2_abs.'),2));
    csi_tx3_rx2_power=sum(sum(power(csi_tx3_rx2_abs.',2)))-sum(power(mean(csi_tx3_rx2_abs.'),2));
    csi_tx1_rx3_power=sum(sum(power(csi_tx1_rx3_abs.',2)))-sum(power(mean(csi_tx1_rx3_abs.'),2));
    csi_tx2_rx3_power=sum(sum(power(csi_tx2_rx3_abs.',2)))-sum(power(mean(csi_tx2_rx3_abs.'),2));
    csi_tx3_rx3_power=sum(sum(power(csi_tx3_rx3_abs.',2)))-sum(power(mean(csi_tx3_rx3_abs.'),2));
    
    antenna = [csi_tx1_rx1_power csi_tx1_rx2_power csi_tx1_rx3_power ; csi_tx2_rx1_power csi_tx2_rx2_power csi_tx2_rx3_power ; csi_tx3_rx1_power csi_tx3_rx2_power csi_tx3_rx3_power];
    [maxTx_Power,maxTX] = max(antenna); 
    [Power,maxRx] = max(maxTx_Power); 
    maxTx = maxTX(1);
    
end
    
   








    