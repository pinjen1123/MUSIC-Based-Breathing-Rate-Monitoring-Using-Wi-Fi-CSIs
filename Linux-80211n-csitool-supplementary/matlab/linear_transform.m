function [mcsi_matrix, mcsiphase] = linear_transform(csi_matrix)
% PADS: Passive Detection of Moving Targets with Dynamic Speed using PHY Layer Information
    R = abs(csi_matrix);
    csiphase = angle(csi_matrix);
    unwrap_csi = unwrap(csiphase, pi, 2).';
    k =[-28:2:-2,-1,1,2:2:28];
    ant1 = unwrap_csi.';
    %ant1 = unwrap_csi(1, :);
    %ant2 = unwrap_csi(2, :);
    %ant3 = unwrap_csi(3, :);
    a1 = (ant1(30) - ant1(1)) / (28*2);
    b1 = mean(ant1);
    %a2 = (ant2(30) - ant2(1)) / (28*2);
    %b2 = mean(ant2);
    %a3 = (ant3(30) - ant3(1)) / (28*2);
    %b3 = mean(ant3);
    mant1 = ant1 - a1*k - b1;
    %mant2 = ant2 - a2*k - b2;
    %mant3 = ant3 - a3*k - b3;
    %mcsiphase = [mant1; mant2; mant3];
    mcsiphase = [mant1];
    mcsi_matrix = R.*exp(1i*mcsiphase);
end