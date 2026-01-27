clc;
clear;
close all;

% LoRa modulation & sampling parameters
Fs = param_configs(3);         % sample rate        
BW = param_configs(2);         % LoRa bandwidth
SF = param_configs(1);         % LoRa spreading factor
nsamp = Fs * 2^SF / BW;

symb1 = Utils.gen_symbol(2^SF/2);
symb1(513:end) = symb1(513:end)*exp(1i*pi);
figure;
    plot((0:length(symb1)-1)/Fs,real(symb1),'b','LineWidth',1.2);
    ylim([-1.5 1.5]);
    xlim([0 1023]/Fs);
    xlabel('Time');
    ylabel('Amplitude');
    set(gca,'FontSize',17);
    grid on;
    set(gca, 'XMinorGrid','on');
    set(gca, 'YMinorGrid','on');