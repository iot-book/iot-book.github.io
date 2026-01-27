# 基于FMCW的追踪方法

## FMCW简介

调频连续波（Frequency Modulated Continuous Wave，FMCW）是一种在高精度雷达测距中使用的经典技术。FMCW技术有很长的使用历史，使用范围非常广泛，在很多传统的场景中已经用得很多了，例如在雷达领域里面。在学习过程中建议大家多参考以前领域的工作。近些年来，FMCW在物联网的定位和感知的场景里面使用得很多,很多前沿的研究工作利用FMCW信号实现定位和感知。

调频连续波定位的基本原理为发射频率连续变化的电磁波，其频率随时间变化的情况如下图所示，频率周期性地随时间递增（从$f_{min}$到$f_{max}$）或递减（从$f_{max}$到$f_{min}$）。一个频率变换周期为$T$的FMCW信号$R(t)$可以表示为：

$$
R(t) = \cos\left(2\pi\left(f_{min} + \frac{B}{2T}t\right)t\right)
$$

其中$B=f_{max}– f_{min}$表示频率变化的带宽。 

<center>
<img src="./fig/fmcw.png" width=600px>
</center>


<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. FMCW信号</div>
</center>

## FMCW追踪

### 利用信号反射

FMCW最直接的一个应用是利用反射信号与发射信号混频得到的频率偏移来进行ToF的测量，进而测出信号源和反射物体之间的距离。

FMCW雷达在扫频周期内发射频率变化的连续波，发射出去的信号被物体反射后的回波与发射信号叠加在一起被接收到。实际收到的信号会呈现上图的特点，反射信号与发射信号存在着时间差。这个时间差在实际系统中不太好直接精确的测量出来（虽然也有一些研究工作试图这么来做）。为了解决这一问题，这个时间差可以转化为对应的频率差，通过测量频率差可以获得目标与雷达之间的距离信息，这也是为什么FMCW好用的主要原因。
差频信号频率与反射的距离相关，一般都比较低，例如数千Hz，因此硬件处理相对简单、适合数据采集并进行数字信号处理。FMCW雷达具有容易实现、结构相对简单、尺寸小、重量轻以及成本低等优点，有广泛的应用前景。

由于反射回来的信号和原始信号的频率差值$\Delta f$，和信号的传输时间$\Delta t$有线性关系，因此可以将对TOF的测量转换为对信号频率变化的测量。假设接收端和发送端之间的距离为$d$，因为传输时间$\Delta t$是往返的总时间，那么可以得到：

$$
d = \frac{c\Delta t}{2}
$$

同时，根据图中的三角函数关系，可以得到：

$$
\Delta t = \frac{T}{B}\Delta f
$$

结合上面的两个式子，可以计算出距离$d$为：

$$
d = \frac{cT}{2B}\Delta f
$$

基于到多个基站的距离变化，我们就能够实现基于FMCW的定位追踪。

### 利用接收信号和发送信号的频率差

使用FMCW可以利用接收信号和发送信号的频率差值测量距离变化。我们基于声波生成FMCW信号，介绍如何提取接收信号与发送信号的频率差。

假定声源S静止不动，可录音设备D相对声源S静止，声源发出信号为：

$$
S(t) = cos\bigg(2\pi\big(f_{min} + \frac{B}{2T}t\big)t\bigg)
$$

其中，$S$为发射信号，$f_{min}$为FMCW频率的最小值，$B = f_{max} - f_{min}$为 FMCW频率的带宽，$T$为周期，$t$为一个周期内的时间，即$0 < t < T$。因此，接收端接收到的信号为：

$$
L(t) = Acos\bigg( 2\pi \big(f_{min} + \frac{B}{2T}(t-t_d) \big) \big(t-t_d \big) \bigg)
$$

其中，A为衰减因子，$t_d$为信号从发射端到接收端所需要的时间延迟。根据积化和差公式（$cosAcosB = \big(cos(A+B) + cos(A-B)\big)/2$），我们将$S(t)$与$L(t)$相乘，再过滤去高频部分（即只留下$cos(A-B)$的项），得到：

$$
V(t)=\frac{A}{2} \cos \left(2 \pi f_{\min } t_{d}+\frac{\pi B\left(2 t t_{d}-t_{d}^{2}\right)}{T}\right)
$$

假设可录音设备与音响之间距离为R，则有$t_d = \frac{R}{c}$，代入$V(t)$可以得到：

$$
V(t)=\frac{A}{2} \cos \left(2 \pi f_{\min } \frac{R}{c}+\left(\frac{2 \pi B R t}{c T}-\frac{\pi B R^{2}}{c^{2} T}\right)\right)
$$

此时的$V(t)$是个单频信号。对其进行傅里叶变换，在频率 $𝑓=𝐵𝑅/𝑐𝑇$ 处可观察到一个峰值，根据波峰的频率即可最终确定接收信号与发送信号的频率差，进而测得声源和麦克风间的距离$R$。

如果使用FMCW信号的反射进行距离测量，设备需要在接收反射信号时消除强度较大发射信号，避免其对反射信号的干扰。而利用FMCW信号的接收信号和反射信号的频率差进行距离测量，需要在发射设备与接收设备之间进行精确的时钟同步。这两种方法在实际场景下都较难以实现，我们可以避免精确的时间同步，利用接收设备接收到FMCW信号和虚拟的发送信号分析距离的变化，进行运动的追踪。

## FMCW追踪案例

本节使用接受设备接收到的FMCW信号，创建虚拟的发送信号进行设备间距离变化的追踪。

发送的信号中含有88段FMCW信号，每两个FMCW信号之间有与FMCW信号等长的空白间隔。

```matlab
%% 发送信号生成
fs = 48000;
T = 0.04;
f0 = 18000; % start freq
f1 = 20500;  % end freq
t = 0:1/fs:T ;
data = chirp(t, f0, T, f1, 'linear');
output = [];
for i = 1:88
    output = [output,data,zeros(1,1921)];
end
```

然后读取接收信号并进行滤波，消除噪音的影响。

```matlab
%% 接收信号读取，并滤波
[mydata,fs] = audioread('fmcw_receive.wav');
mydata = mydata(:,1);
 
hd = design(fdesign.bandpass('N, F3dB1, F3dB2', 6, 17000, 23000, fs), 'butter');
mydata=filter(hd,mydata);
% figure;
% plot(mydata);
```
> 思考滤波器是如何使用的。

为分析距离变化，生成一个pseudo-transmitted信号，该信号是虚拟的发送信号。使用该信号，计算接收信号和该信号的频率变化，实现距离变化的追踪。

系统的具体步骤为：

- 1. 生成pseudo-transmitted信号。
- 2. 将pseudo-transmitted信号与接收信号相乘，并做傅里叶变换，得到频率偏移。
- 3. 得到每个接收到的FMCW信号相对起始位置的频率偏移，进而得到每一时刻的距离。

```matlab
%% 生成pseudo-transmitted信号
pseudo_T = [];
for i = 1:88
    pseudo_T = [pseudo_T,data,zeros(1,T*fs+1)];
end
 
[n,~]=size(mydata);
 
% fmcw信号的起始位置在start处
start = 38750; 
pseudo_T = [zeros(1,start),pseudo_T];
[~,m]=size(pseudo_T);
pseudo_T = [pseudo_T,zeros(1,n-m)];
s=pseudo_T.*mydata';
 
len = (T*fs+1)*2; % chirp信号及其后空白的长度之和
fftlen = 1024*64; %做快速傅里叶变换时补零的长度。在数据后补零可以使的采样点增多，频率分辨率提高。可以自行尝试不同的补零长度对于计算结果的影响。
f = fs*(0:fftlen -1)/(fftlen); %% 快速傅里叶变换补零之后得到的频率采样点

%% 计算每个chirp信号所对应的频率偏移 
for i = start:len:start+len*87
   FFT_out = abs(fft(s(i:i+len/2),fftlen));
   [~, idx] = max(abs(FFT_out(1:round(fftlen/10))));
   idxs(round((i-start)/len)+1) = idx;
end

%% 根据频率偏移delta f计算出距离
start_idx = 0;
delta_distance = (idxs - start_idx) * fs / fftlen * 340 * T / (f1-f0);
```

最后，绘制出距离随时间变化的图像。

```matlab
%% 画出距离随时间变化的图像
figure;
plot(delta_distance);
xlabel('time(s)', 'FontSize', 18);
ylabel('distance (m)', 'FontSize', 18);
```



<center>
<img src="./fig/fmcw_track.png" width=600px>
</center>


<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. FMCW测距</div>
</center>
