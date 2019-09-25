%% Set Parameter
sampleFreq = 48000;     %sampling rate
dF = 350;               %frequency interval between two adjacent frequencies
pathN = 10;             %the number of signals of different frequencies
baseF = 17000;          %the lowest frequency of signal
durSec = 300;           %duration time of signal (s)
A = 1;                  %Amplitude

%% Generate Signal
freq = baseF : dF : baseF + (pathN - 1) * dF;
t = linspace(0, durSec, sampleFreq * durSec + 1);
t = t(1 : end - 1);

signal = sum(A * cos(2 * pi * freq' * t), 1) / pathN;

%% FFT Analysis
fL = linspace(0, sampleFreq / 2, length(t) / 2);
fftRes = fft(signal);
fftRes = fftRes(1 : length(fftRes) / 2);
plot(fL, real(fftRes));

%% Save as wav file
audiowrite('sample.wav', signal, sampleFreq, 'BitsPerSample', 16);
