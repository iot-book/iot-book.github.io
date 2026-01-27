close all
clear
clc
Demodulator('test')


function codes = Demodulator(fileName)

    [sig, sample_frequency] = audioread([fileName, '.wav']);
    sig = sig';
    T = 0.025;
    Base_frequency = 20e3;
    N = sample_frequency  *  T;          % 调制符号的采样点数
    
    num_symb = floor(length(sig) / N);

    N = sample_frequency * T;
    t = (0:N-1) / sample_frequency;
    Base_signal = sin(2 * pi * Base_frequency * t);
    Base_signal = repmat(Base_signal, 1, num_symb);

    % sigMat = sqrt(2) / 2 * (...
    %     [1; 1; -1; -1] .* repmat(sigI, 4, 1) + ...
    %     [1; -1; 1; -1] .* repmat(sigQ, 4, 1));
    % 
    % cLen = 2 * length(sig) / sigL;
    % 
    % codes = zeros(1, cLen);

    figure;
        plot((0:length(sig)-1)/sample_frequency, sig, 'b');
        xlim([0 (length(sig)-1)/sample_frequency]);
        xlabel('Time');
        ylabel('Amplitude');
        set(gca,'FontSize',17);
        grid on;
        set(gca, 'XMinorGrid','on');
        set(gca, 'YMinorGrid','on');
        
    
    y = sig(1:N*num_symb) .* Base_signal;
    figure;
        plot((0:length(y)-1)/sample_frequency, y, 'b');
        xlim([0 (length(y)-1)/sample_frequency]);
        xlabel('Time');
        ylabel('Amplitude');
        set(gca,'FontSize',17);
        grid on;
        set(gca, 'XMinorGrid','on');
        set(gca, 'YMinorGrid','on');
        
    y = lowpass(y,100,sample_frequency);
    figure;
        plot((0:length(y)-1)/sample_frequency, y, 'b');
        xlim([0 (length(y)-1)/sample_frequency]);
        xlabel('Time');
        ylabel('Amplitude');
        set(gca,'FontSize',17);
        grid on;
        set(gca, 'XMinorGrid','on');
        set(gca, 'YMinorGrid','on');
        hold on
        for i = 1:num_symb
            plot([(i-1)*N/sample_frequency (i-1)*N/sample_frequency], [-0.5 0.5],'r--');
        end
       
    
    a = [];
    b = [];
    codes = zeros(1, num_symb);
    for i = 1 : num_symb
        symb = y((i-1) * N + 1 : i * N);
        codes(i) = sum(symb) < 0;
        a = [a, (i-0.5)*N/sample_frequency];
        b = [b, sum(symb)];
    end
figure; stem(a,b,'b','LineWidth',2);xlabel('Time');
        ylabel('Amplitude');
        set(gca,'FontSize',17);
        grid on;
        set(gca, 'XMinorGrid','on');
        set(gca, 'YMinorGrid','on');
    disp(codes);
% for i = 1 : nsymb
%     seg = sig((i - 1) * N + 1 : i * N);
%     y = seg .* msig;
%     y = movmean(y, 100);
%     figure;
%         plot(y);
%     [~, maxI] = max(sigMat * seg');
%     codes(2 * i - 1) = maxI > 2;
%     codes(2 * i) = mod(maxI, 2) == 0;
% end

end
