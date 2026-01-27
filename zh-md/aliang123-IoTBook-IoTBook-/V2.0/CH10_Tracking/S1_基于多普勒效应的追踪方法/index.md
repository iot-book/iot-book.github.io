# 基于多普勒效应的追踪方法

## 目标追踪技术

目标追踪技术能够利用目标运动过程中信号特征（如频率、相位）的变化等信息，感知目标空间位置的变化，追踪目标的运动轨迹。本章将以基于距离变化量的运动追踪为例介绍目标追踪技术。

不同于基于距离测量的定位方法，基于距离变化量的运动追踪方法不直接测量距离，进而得到距离变化，而是通过距离变化导致的信号频率、相位等信息的变化间接测量距离变化。

## 多普勒效应

多普勒效应是指信号源与接收者发生相对运动时，接收者接收的信号频率与信号源发出的信号频率不同的现象。

<center>
<img src=".\fig\doppler.png" width=600px>
<br>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图1. 多普勒效应</div>
</center>


如图，假设声源位置不变，接收者处于运动状态，速度为$v$，则接收者接收到的声音频率$f$为：

$$
f=\frac{c+v}{c}f_0
$$

其中$f_0$表示声源发出声音的频率，$c$表示声速，$v$表示接收者的速度，靠近声源运动速度为正，远离声源运动速度为负。

由于多普勒效应，若接收者远离声源，接收的声音信号频率将减小；若接收者靠近声源，接收的声音信号频率将增大。

## 多普勒追踪的原理

根据多普勒效应的公式，可以通过接收者和信号源的频率计算接收者的运动速度。接收者的运动速度v为：

$$
v=\frac{f-f_0}{f_0}c=\frac{\Delta f}{f_0}c
$$

其中$f_0$表示声源发出声音的频率，$\Delta f$表示多普勒效应产生的频率变化，$c$表示声速。

由于速度对时间的积分等于位移，即$d = \int_0^{T} v dt$，通过计算速度并对其进行积分，就可以得到接收者运动的距离变化情况。

若已知接收者的初始位置，可以计算得到目标的最终位置，从而实现对目标的定位追踪。

## 多普勒追踪的实现

基于多普勒效应的追踪的核心步骤在于计算频率偏移$\Delta f$。

为得到$\Delta f$，可以将接收到的声音信号做短时离散傅里叶变换（STFT）。STFT是一种基于滑动窗口的傅里叶变换方法，它的原理是利用在原信号上移动的滑动窗口，对每个窗口内的信号做傅里叶变换，这样就可以得到该时间窗口内信号的频域信息，通过频域信息可以得到信号在这段时间窗口内的频率$f$。我们在傅里叶变换这一章就进行过介绍，大家可以回到那一章进行回顾。

如果原始信号的频率$f_0$是固定的，那么通过计算原始信号频率和接收到的信号频率之差$f-f_0$，就能得到频率偏移$\Delta f$。

假设窗口的长度是$L_w$，采样率为$f_s$, 那么基于多普勒效应追踪的频率精度$D_f$就可以用如下公式计算:

$$
D_f =  \frac{f_s}{L_w}
$$

如果我们知道了原始信号的频率$f_0$和声速$c$，就可以计算出速度精度。

$$
D_v  =  \frac{D_f}{f_0}c
$$

一般来说，越短的窗口在时域上效果越好，即能够获得更短的时间间隔的频率信息，但在频域上效果较差，即频率分辨率较差。长窗口在频域上效果好，但是在时域上效果差（时延较高）。

该方法的具体实现代码如下（res\doppler.m）

```matlab
% 读入音频文件
[data,fs] = audioread('record.wav');
% 提取第一个声道
data=data(:,1);
% 将数据转化为行向量
data=data.';

% 使用带通滤波器滤波去噪
bp_filter = design(fdesign.bandpass('N,F3dB1,F3dB2',6,20800,21200,fs),'butter');
data = filter(bp_filter,data);

%% 使用STFT计算频率偏移
% 窗口大小1024个采样点
slice_len = 1024;
slice_num = floor(length(data)/slice_len);
delta_t = slice_len/fs;

% 每个时间窗口的信号频率
slice_f=zeros(1,slice_num);
% 在fft时补256倍的0，提高fft分辨率
fft_len = 1024*256;
for i = 0:1:slice_num-1
    %对每个窗口进行fft，取频率谱的峰值频率作为改时间窗口的信号频率
    fft_out = abs(fft(data(i*slice_len+1:i*slice_len+slice_len),fft_len));
    [~, idx] = max(abs(fft_out(1:round(fft_len/2))));
    slice_f(i+1) = (idx/fft_len)*fs;
end

%% 计算距离变化
f0=21000;
c=340;

%起始位置坐标为0
position=0;
distance=zeros(0,slice_num);
v = (slice_f-f0)/f0*c;
for i = 1:slice_num
    %把一段时间窗口内的移动当作匀速运动
    %由于速度方向取靠近声源为正，计算距离时应使用减法
    position = position - v(i)*delta_t;
    distance(i) = position;
end

time = 1:slice_num;
time = time*delta_t;
plot(time,distance);
title('基于多普勒效应的追踪');
xlabel('时间(s)');
ylabel('距离(m)');
```

对实际采集的音频record.wav进行分析，录制该音频的过程中设备先远离声源移动10cm，然后远离声源移动20cm，最后移动回到初始位置。

分析结果如下图

<center>
    <img src=".\fig\result_doppler.png" width=600px>
</center>

可以看出分析结果与实际运动过程相符，使用该方法可以做到较精确的运动追踪。
