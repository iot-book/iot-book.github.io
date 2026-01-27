close all
clear
clc

% % Inputs and parameters
Code_array = [0, 1, 1, 0, 1];		     % 输入的二进制串
fileName = 'test';
SNR = 10;
Modulator(Code_array,fileName,SNR);

function Modulator(Code_array, fileName, SNR) 
    Sample_frequency = 48e3;                            % 采样频率
    Symbol_duration = 0.025;                            % 调制符号持续时间
    Base_frequency = 20e3;                              % 调制信号频率

    N =  Sample_frequency  *  Symbol_duration;          % 调制符号的采样点数
    t = (0:N-1) / Sample_frequency;                     % 每一采样点对应的时刻
    Base_signal = sin(2 * pi * Base_frequency * t); 
    
    Modulated_signal = zeros(1, N * length(Code_array));
    for i = 1:length(Code_array)
        pa = 1 - 2 * Code_array(i);	      % 根据Code判断是否相位翻转
        Modulated_signal((i - 1) * N + (1 : N)) = pa * Base_signal;
    end
    
    figure;
        plot((0:length(Modulated_signal)-1)/Sample_frequency, Modulated_signal*0.7,'b');
        ylim([-1 1]);
        xlim([0 (length(Modulated_signal)-1)/Sample_frequency]);
        xlabel('Time');
        ylabel('Amplitude');
        set(gca,'FontSize',17);
        grid on;
        set(gca, 'XMinorGrid','on');
        set(gca, 'YMinorGrid','on');

    Noise_signal = awgn(Modulated_signal, SNR, 'measured');
    Noise_signal  =  Noise_signal  / max(abs(Noise_signal));
    
    figure;
        plot((0:length(Modulated_signal)-1)/Sample_frequency, Noise_signal,'b');
        xlim([0 (length(Modulated_signal)-1)/Sample_frequency]);
        xlabel('Time');
        ylabel('Amplitude');
        set(gca,'FontSize',17);
        grid on;
        set(gca, 'XMinorGrid','on');
        set(gca, 'YMinorGrid','on');
    audiowrite([fileName, '.wav'],  Noise_signal, Sample_frequency);

end



% function Modulator(codes, fileName, sigSNR)
% 
% fs = 48000;
% T = 0.025;
% f = 20e3;
% cLen = length(codes);
% if mod(cLen, 2) == 1
%     codes = [codes, 0];
%     cLen = cLen + 1;
% end
% 
% N = fs * T;
% t = (0:N-1) / fs;
% sigI = sin(2 * pi * f * t);
% sigQ = cos(2 * pi * f * t);
% sigL = length(sigI);
% 
% sig = zeros(1, sigL * cLen / 2);
% for i = 1 : cLen / 2
%     fI = (1 - 2 * codes(i * 2 - 1)) * sqrt(2) / 2;
%     fQ = (1 - 2 * codes(i * 2)) * sqrt(2) / 2;
%     sig((i - 1) * sigL + 1 : i * sigL) = fI * sigI + fQ * sigQ;
% end
% 
% sig = awgn(sig, sigSNR, 'measured');
% sig = sig / max(abs(sig));
% audiowrite([fileName, '.wav'], sig, fs);
% 
% end
