# FMCW测距

## FMCW概念

FMCW（Frequency Modulated Continuous Wave，调频连续波）是一种在高精度雷达测距中使用的技术。FMCW技术有很长的使用历史，使用范围非常广泛。近些年来，FMCW在物联网的定位和感知的场景里面使用很多。很多前沿的研究工作，利用基于无线或者声波的FMCW信号，来进行定位和感知的应用。

FMCW基本原理为发射频率连续波，最直接的一个应用是利用反射信号与发射信号混频得到的频率偏移来进行ToF的测量。
如下图所示，FMCW雷达将信号调制为一种特制的chirp信号（回顾一下在LoRa一章我们学过的技术），其频率周期性地随时间递增（从$f_{min}$到$f_{max}$）或递减（从$f_{max}$到$f_{min}$）。一个频率变换周期为$T$的递增FMCW信号$R(t)$可以表示为：
$$
R(t) = \cos\left(2\pi\left(f_{min} + \frac{B}{2T}t\right)t\right)
$$
其中$B=f_{max}– f_{min}$表示频率变化的带宽。 

[TODO] 这个图好像有问题？

<center>
<img src="./fig/fmcw.png" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. FMCW信号</div>
</center>



FMCW雷达在扫频周期内发射频率变化的连续波，发射出去的信号被物体反射后的回波与发射信号叠加在一起被接收到。实际收到的信号会呈现上图的特点，反射信号与发射信号存在着时间差。这个时间差在实际系统中不太好直接精确的测量出来（虽然也有一些研究工作试图这么来做）。为了解决这一问题，这个时间差可以转化为对应的频率差，通过测量频率差可以获得目标与雷达之间的距离信息，这也是为什么FMCW好用的主要原因。
差频信号频率较低，一般为KHz，因此硬件处理相对简单、适合数据采集并进行数字信号处理。FMCW雷达具有容易实现、结构相对简单、尺寸小、重量轻以及成本低等优点，有广泛的应用前景。

## FMCW测距原理

由于反射回来的信号和原始信号的频率差值$\Delta f$，和信号的传输时间$\Delta t$有线性变化关系，因此可以将对TOF的测量转换为对信号频率变化的测量。假设接收端和发送端之间的距离为$d$，因为传输时间$\Delta t$是往返的总时间，那么可以得到：

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

## 声波FMCW应用
因此，可以利用接收信号和发送信号的频率差值实现测距。我们基于声波生成FMCW信号，介绍如何提取接收信号与发送信号的频率差。

假定声源S静止不动，可录音设备D相对声源S静止，声源发出信号为：
$$
S(t) = cos\bigg(2\pi\big(f_{min} + \frac{B}{2T}\big)t\bigg)
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
此时的$V(t)$是个单频信号。对其进行傅里叶变换，在频率 $𝑓=𝐵𝑅/𝑐𝑇$ 处可观察到一个峰值，根据波峰的下标即可最终确定接收信号与发送信号的频率差。

## 实现案例

直接使用FMCW信号测距时，需要发送设备与接收设备之间进行精准的时钟同步，这样才能保证可以在接收端通过信号相乘提取发送信号与接收信号之间的频率差。在实际系统中，我们可以通过使用同一设备收、发信号以实现上述时钟同步需求。因此，当需要测量设备到某个目标物体的距离时，我们令设备发送FMCW信号，信号达到目标物体并被目标反射后回到测距设备，测距设备收集反射信号并将其与发出信号进行比对以实现测距。测距设备在接收反射信号时，需要通过特制的双工电路，消除发送信号对反射信号的干扰 ??[TODO]。

FMCW测距实现案例：
- 目标：使用FMCW声波信号测量设备与目标物体之间的距离。
- 发送信号：88个chirp信号，每两个chirp信号之间有与chirp信号等长的空白间隔。
- 具体步骤：
  - 1. 生成pseudo-transmitted信号。
  - 2. 将pseudo-transmitted信号与接收信号相乘，并做傅里叶变换，得到频率偏移。
  - 3. 得到每个接收到的chirp信号相对起始位置的频率偏移，进而得到每一时刻的距离。

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
 
%% 接收信号读取，并滤波
[mydata,fs] = audioread('fmcw_receive.wav');
mydata = mydata(:,1);
 
hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,17000,23000,fs),'butter');
mydata=filter(hd,mydata);
% figure;
% plot(mydata);
 
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
 
%% 画出距离
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
