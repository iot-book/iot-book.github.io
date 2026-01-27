# 实践案例——声音滤波

借助滤波器，我们可以保留或抑制信号中特定频率的内容。这是物联网信号处理中的常用也必不可少的操作。很多同学们对这一部分基本概念有所了解，但是具体操作起来仍然比较陌生，尤其是之前很多同学并没有实际使用的经验。
在理解了基本原理之后，我们展示使用滤波来处理真实信号的案例。本部分将以录音降噪程序为例，向大家展示如何设计并实现具有特定功能的数字滤波器。我们处理一段混有高频噪声的录音信号，通过低通滤波抑制噪声信号，从而达到给录音降噪的目的。完整的实现代码及录音文件请访问XXX获取。

## 基于滑动平均的低通滤波器实现

滑动平均是最简单的低通滤波的实现形式，但对于过滤信号中的高频噪声却有非常明显的效果。从时域看，通过滑动平均可以将高频噪声带来的毛刺波动尽可能的平滑，并保留低频信号的波形特征；从频域看，滑动平均过程等价于在原始信号的频域输出结果上乘一个Sa函数。

滑动平均的主要可调整参数为窗口大小，下面我们将实现基于滑动平均的低通滤波，用于抑制录音信号中的高频噪声分量。
```matlab
clc; clear; close all; clear sound

% 载入录音信号
[xr,fs] = audioread('Music.mp3');
xr=xr(:,1)'; 
noise = 0.01 * rand(1, numel(xr));
noise = highpass(noise, 500, fs);
xr = xr + noise;
figure; subplot(3,1,1); plot(xr); title('原始时域信号');
box on; grid on;

nfft = 1e4;
t = (0:numel(xr)-1)/fs;
fidx = (0:nfft-1)/nfft * fs;

% 原始含噪信号频谱
z = fft(xr(1:nfft));
subplot(3,1,2); plot(fidx, abs(z));
grid on; box on;
title('原始含噪信号频谱');

% 滑动平均过滤高频噪声
mwin = 100;
xr = movmean(xr, mwin);

% 滤波后信号频谱
z = fft(xr(1:nfft));
subplot(3,1,3); plot(fidx, abs(z));
grid on; box on;
title('滤波后信号频谱');

sound(xr, fs);
```

<center>
<img src="./fig/low_pass.png" width=600px>
</center>

<!-- ![不同窗口长度下，滑动平均滤波器的脉冲响应](./fig/脉冲响应.png) -->
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 滑动平均低通滤波效果示意</div>
</center>

可以看到通过滑动平均，原始声波信号中的高频分量被明显抑制；但同时，有用声音所在频率（0~1kHz）的信号能量也产生了衰减。这是由于滑动平均滤波器在频域对通带内的信号也有所抑制。

接下来，我们调整滑动窗口长度(窗口长度等于 10，30，50，70),绘制不同窗口长度下滤波结果的频谱图,分析滑动窗口长度对滤波效果的影响。
```matlab
for mwin = [10,30,50,70]
    % 滑动平均过滤高频噪声
    xr = movmean(xr, mwin);

    % 滤波后信号频谱
    z = fft(xr(1:nfft));
    subplot(2,2,ceil(mwin/10/2)); plot(fidx, abs(z));
    grid on; box on;
    title(['滑动平均窗口大小=', num2str(mwin)]);
end
```
<center>
<img src="./fig/wins.png" width=600px>
</center>

<!-- ![不同窗口长度下，滑动平均滤波器的脉冲响应](./fig/脉冲响应.png) -->
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 不同滑动窗口长度下低通滤波效果对比</div>
</center>

可以发现，滑动平均窗口越长，通带带宽越窄，对高频噪声的抑制效果越好；但同时，滑动窗口越长，也意味着通带内有用信号被抑制得越严重，失真越明显。

## 带通滤波器实现

在有些情况下，噪声的频率同时分布在高频区间和低频区间。因此只通过简单的低通或者高通都无法达到令人满意的降噪效果。因此我们希望能够实现对特定频带内的信号滤波，即带通滤波。带通滤波器能通过指定频率范围内的频率分量,同时尽量降低其他范围的频率分量。

下面我们将编写程序实现带通滤波,提取录音文件中频率范围分别在17kHz~18kHz 与 20kHz~21kHz 两个频带的信号。

最直观的想法，是通过信号下变频，先将目标频带的信号搬移到0 Hz附近，然后使用低通滤波对目标频段外的信号进行抑制。

```matlab
% parameters
filename = 'res2.wav';

% read data
[y, Fs] = audioread(filename);

fft_plot(y, Fs, length(y), 'without filter');

t = (0:numel(y)-1) / Fs;
y = y .* cos(2*pi*-17e3*t); % 下变频的方法
y = lowpass(y, 1e3, Fs);
```

<center>
<img src="./fig/bandpass.png" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 带通滤波效果</div>
</center>

> 思考：下变频的原理以及效果？

MATLAB提供了bandpass函数供用户提取制定频带内的信号，其实现逻辑与上述代码类似：

```matlab
% parameters
filename = 'res2.wav';

% read data
[y, Fs] = audioread(filename);
fft_plot(y, Fs, length(y), 'without filter');

% bandpass
figure;
bandpass(y, [17000, 18000], Fs);
figure;
bandpass(y, [20000, 21000], Fs);

function fft_plot(y, Fs, NFFT, plot_title)
    fx = (0:NFFT-1)*Fs/NFFT;
    ffty = fft(y, NFFT);
    m = abs(ffty);
    figure;
    plot(fx, m);
    title(plot_title);
    xlabel('f');
    ylabel('amplitude');
end
```

[TODO] 解释得不够透彻，没有写这个滤波器特点，也没写跟前面介绍的几种滤波器类型的关系。大家在实验时应该采用哪种滤波器。