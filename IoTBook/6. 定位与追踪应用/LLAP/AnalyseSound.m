clear; close all; clc;
soundFile = '?.wav';

Algorithm();

%% Algorithm
function Algorithm()

global sample;

defineParameter();
[XR, XI] = GetBaseBand(sample);
D = RemoveDCandCalculateDistance(XR, XI);
dist = linearRegression(D);
plot(dist);

end

function defineParameter()

global dataSeg dF sample pathN baseF fs freq t dataLen...
    CIC_DEC CIC_DELAY SECTION_N POWER_THR PEAK_THR DC_TREND;

dataSeg = 32;           %data segment size
dF = 350;               %frequency interval between two adjacent frequencies
pathN = 10;             %the number of signals of different frequencies
baseF = 17000;          %the lowest frequency of signal
freq = baseF : dF : baseF + (pathN - 1) * dF;

%CIC Filter Coefficients
CIC_DEC = 16;
CIC_DELAY = 17;
SECTION_N = 4;

%LEVD Coefficients
POWER_THR = 5.5e5;
PEAK_THR = 220;
DC_TREND = 0.25;

[sample, fs] = audioread(soundFile);
cut0 = fs + 1;          %cut the beginning part of original signal
sample = sample(cut0 : end, 1)';
dataLen = floor(length(sample) / (CIC_DEC * dataSeg));
sample = sample(1 : dataLen * CIC_DEC * dataSeg);

t = 0 : 1 / fs : length(sample) / fs;
t = t(1 : end - 1);

end

%% Funtion region
function Y = CIC_Filter(X) %X: 1 by n vector, n is a multiple of CIC_DEC 

global CIC_DEC CIC_DELAY SECTION_N;

Y = sum(reshape(X, CIC_DEC, length(X) / CIC_DEC), 1);

for i = 1 : SECTION_N
    Y = conv(Y, ones(1, CIC_DELAY), 'valid');
end

end

function [YR, YI] = GetBaseBand(X) %X: 1 by n vector

global pathN freq t dataLen dataSeg CIC_DEC CIC_DELAY SECTION_N;

remainL = length(X) / CIC_DEC - SECTION_N * (CIC_DELAY - 1);

YR = zeros(pathN, remainL);
YI = zeros(pathN, remainL);

for i = 1 : pathN
    xR = X .* cos(2 * pi * freq(i) * t);
    YR(i, :) = CIC_Filter(xR);
    xI = X .* -sin(2 * pi * freq(i) * t);
    YI(i, :) = CIC_Filter(xI); 
end

dataLen = floor(length(YR) / dataSeg);
YR = YR(:, 1 : dataLen * dataSeg);
YI = YI(:, 1 : dataLen * dataSeg);

end

function phi = myPhase(X)

phi = angle(X);
for j = 2 : size(X, 2)
    k = phi(j - 1) / (2 * pi);
    cur = floor(k) * 2 * pi + phi(j);
    while cur > phi(j - 1) + pi
        cur = cur - 2 * pi;
    end
    while cur < phi(j - 1) - pi
        cur = cur + 2 * pi;
    end
    phi(j) = cur;
end

end

function D = RemoveDCandCalculateDistance(XR, XI)

global dataSeg pathN freq POWER_THR PEAK_THR DC_TREND dataLen;

%% Debug variant
YR = zeros(size(XR));
YI = zeros(size(XI));
SigP = zeros(pathN, dataLen);
Phi = zeros(pathN, length(XR));

%%
D = zeros(pathN, length(XR));

for i = 1 : pathN
    
    avR = 0;
    ivR = 0;
    avI = 0;
    ivI = 0;
    DCR = 0;
    DCI = 0;
    
    for j = 1 : dataLen
        xR = XR(i, (j - 1) * dataSeg + 1 : j * dataSeg);
        xI = XI(i, (j - 1) * dataSeg + 1 : j * dataSeg);
        
        maxvR = max(xR);
        minvR = min(xR);
        xR = xR - xR(1);
        maxvI = max(xI);
        minvI = min(xI);
        xI = xI - xI(1);

        dsum = abs(mean(xR)) + abs(mean(xI));
        vsum = mean(xR .^ 2) + mean(xI .^ 2);

        P = dsum .^ 2 + vsum;
        SigP(i, j) = P;

        if P > POWER_THR
            if maxvR > avR || ...
                    (maxvR > ivR + PEAK_THR && ...
                    avR - ivR > 4 * PEAK_THR)
                avR = maxvR;
            end
            if minvR < ivR || ...
                    (minvR < avR - PEAK_THR && ...
                    avR - ivR > 4 * PEAK_THR)
                ivR = minvR;
            end
            if maxvI > avI || ...
                    (maxvI > ivI + PEAK_THR && ...
                    avI - ivI > 4 * PEAK_THR)
                avI = maxvI;
            end
            if minvI < ivI || ...
                    (minvI < avI - PEAK_THR && ...
                    avI - ivI > 4 * PEAK_THR)
                ivI = minvI;
            end
            
            if avR - ivR > PEAK_THR && ...
                    avI - ivI > PEAK_THR
                DCR = (1 - DC_TREND) * DCR + (avR + ivR) / 2 * DC_TREND;
                DCI = (1 - DC_TREND) * DCI + (avI + ivI) / 2 * DC_TREND;
            end
        end
        
        xR = XR(i, (j - 1) * dataSeg + 1 : j * dataSeg) - DCR;
        xI = XI(i, (j - 1) * dataSeg + 1 : j * dataSeg) - DCI;
        
        YR(i, (j - 1) * dataSeg + 1 : j * dataSeg) = xR;
        YI(i, (j - 1) * dataSeg + 1 : j * dataSeg) = xI;
        
        x = xR + xI * 1i;
        
        P = sum(abs(x) .^ 2);
        if P / dataSeg > POWER_THR
            phi = myPhase(x);
            Phi(i, (j - 1) * dataSeg + 1 : j * dataSeg) = phi - phi(1);
            if abs(phi(end) - phi(1)) > pi / 4
                DCR = (1 - 2 * DC_TREND) * DCR + (avR + ivR) * DC_TREND;
                DCI = (1 - 2 * DC_TREND) * DCI + (avI + ivI) * DC_TREND;
            end
            D(i, (j - 1) * dataSeg + 1 : j * dataSeg) = ...
                (phi - phi(1)) / (-2 * pi) * 343 / freq(i);
        end
    end
end 

% plot(SigP(1, :));
% hold on;
% plot(POWER_THR * ones(1, dataLen));

end

function dist = linearRegression(D)

global dataSeg pathN dataLen;

dist = zeros(1, dataLen);

for j = 1 : dataLen
    
    %% Filter frequency with large error
    numUse = 0;
    sumxy = 0;
    sumy = 0;
    
    for i = 1 : pathN
        d = D(i, (j - 1) * dataSeg + 1 : j * dataSeg);
        if any(d)
            numUse = numUse + 1;
            sumxy = sumxy + (0 : dataSeg - 1) * d';
            sumy = sumy + sum(d);
        end
    end
    
    if numUse == 0
        continue;
    end
    
    dx = (dataSeg - 1) * dataSeg * (2 * dataSeg - 1) / 6 - ...
        (dataSeg - 1) .^ 2 * dataSeg / 4;
    dd = (sumxy - sumy * (dataSeg - 1) / 2) / dx / numUse;
    
    varsum = 0;
    varval = zeros(1, pathN);
    for i = 1 : pathN
        d = D(i, (j - 1) * dataSeg + 1 : j * dataSeg);
        if any(d)
            varval(i) = sum((d - dd * (0 : dataSeg - 1)) .^ 2);
            varsum = varsum + varval(i);
        end
    end
    varsum = varsum / numUse;
    
    for i = 1 : pathN
        d = D(i, (j - 1) * dataSeg + 1 : j * dataSeg);
        if any(d) && varval(i) > varsum
            D(i, (j - 1) * dataSeg + 1 : j * dataSeg) = zeros(1, dataSeg);
        end
    end
    
    %% Get distance
    numUse = 0;
    sumxy = 0;
    sumy = 0;
    
    for i = 1 : pathN
        d = D(i, (j - 1) * dataSeg + 1 : j * dataSeg);
        if any(d)
            numUse = numUse + 1;
            sumxy = sumxy + (0 : dataSeg - 1) * d';
            sumy = sumy + sum(d);
        end
    end
    
    if numUse == 0
        continue;
    end
    
    dd = (sumxy - sumy * (dataSeg - 1) / 2) / dx / numUse;
    
    dist(j) = dd * dataSeg / 2;
end

dist = cumsum(dist);

end