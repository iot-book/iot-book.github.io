# 基于信号相位的追踪方法
相位定位追踪是物联网定位追踪中的常用方法，尤其近些年出现了一系列基于相位的定位和追踪方法，在研究领域里面层出不穷，将基于相位的追踪方法不断变化，大家如果有经常看物联网相关论文应该会比较熟悉。大家如果要深入的学习，应该去先思考信号的本身基本特点，就很容易理解基于相位的追踪方法，相关的方法也是很早以前就出现了，在物联网中的应用让我们更加有直观的感受。

## 相位追踪的原理

相位定位的基本原理就是测量信号的相位变化，在数据调制那一章我们已经介绍过了相位，大家可以回去再看一下。
在定位过程中，相位追踪可以从几个不同的方面来进行理解。
假设信号源发送的固定频率信号为$R(t)=Acos(2\pi ft)$，信号经过路径$p$传播，传播路径长度随时间的变化为$d_p(t)$。接收到的经路径$p$的声音信号可以表示为：

$$
R_p(t)=A_p(t)cos(2\pi ft-\frac{2\pi fd_p(t)}{c}-\theta_p)
$$

其中$A_p(t)$为接收信号的幅度，$2\pi fd_p(t)/c$为传播引起的相位偏移，$c$为声速，$\theta_p$是由于硬件的延迟、反射带来的半波损失等造成的相位偏移，这部分可以认为是常量，不随时间变化。若能从接收信号$R_p(t)$中获取相位信息。根据相位，可以得到传播路径长度$d_p(t)$的变化情况，实现接收者运动路径的追踪。

若利用位于不同位置，发送不同频率声波的多个声源，在已知起始位置的情况下，根据设备在一段时间内的与不同声源距离的变化，可以计算得到设备空间位置的变化情况，实现高精度的定位与追踪。

## 相位追踪的实现

相位这个词咱们如果是从这个材料的开始看到这里，一定不会陌生。如果没有看的话，建议先看信号数字调制和解调这一部分，这一部分已经把相位讲的比较清楚了。看完那部分，大家不用看这部分就能理解如何利用相位做追踪了，这也是为什么在我们这个材料里面先要花很多时间介绍傅里叶、数据调制解调等。

为了在接收的信号中提取路径长度$d_p(t)$，采用I/Q调制解调的方式消去含有频率$f$的项。

由于

$$
R_p(t)\cos(2\pi f t)=\frac{A_p(t)}{2}\cos(-2\pi f \frac{d_p(t)}{c}-\theta_p)+\frac{A_p(t)}{2}\cos(4\pi ft-2\pi f \frac{d_p(t)}{c}-\theta_p)
$$

对接收的信号$R_p(t)$乘$\cos(2\pi ft)$，可以得到一个低频分量和高频分量相加的信号，将该信号通过低通滤波器可以获得低频分量，称为$I$路信号：$I_p(t)=\frac{A_p(t)}{2}\cos(2\pi f \frac{d_p(t)}{c}+\theta_p)$。同理

$$
R_p(t)\sin(2\pi f t)=-\frac{A_p(t)}{2}\sin(-2\pi f \frac{d_p(t)}{c}-\theta_p)+\frac{A_p(t)}{2}\sin(4\pi ft-2\pi f \frac{d_p(t)}{c}-\theta_p)
$$

对接收的信号$R_p(t)$乘$\sin(2\pi ft)$，通过低通滤波器可以获得$Q$路信号：$Q_p(t)=\frac{A_p(t)}{2}\sin(2\pi f \frac{d_p(t)}{c}+\theta_p)$。

根据$I_p(t)$和$Q_p(t)$，可以求得$2\pi f\frac{d_p(t)}{c}+\phi_p=\arctan(\frac{Q_p(t)}{I_p(t)})$，从而得到传播路径长度$d_p(t)$。

该方法的具体实现代码如下

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

%% 计算相位变化
f0=21000;
c=340;
time = length(data) /fs;
t=0:1/fs:time-1/fs;
% 将正弦和余弦信号分别和原信号相乘
cos_wave = cos(2*pi*f0*t);
sin_wave = sin(2*pi*f0*t);
r1=data.*cos_wave;
r2=data.*sin_wave;

% 将所得信号通过低通滤波器，得到I路和Q路信号
lp_filter = design(fdesign.lowpass('N,F3dB',6,200,fs),'butter');
I = filter(lp_filter,r1);
Q = filter(lp_filter,r2);

% 计算反正切得到相位
phase=atan(Q./I);

%% 利用相位变化计算距离变化
% 消除反正切引起的相位跳变
phase = phase / pi;
p_difference = phase(2:length(phase))-phase(1:length(phase)-1);

bias =0;
for i = 1:length(p_difference)
    if p_difference(i)>0.2
        bias=bias-1;
    end
    if p_difference(i)<-0.2
        bias=bias+1;
    end
    phase(i+1)=phase(i+1)+bias;
end
phase = phase * pi;
distance = phase /(2*pi*f0) *c;

plot(t,distance);
title('基于相位的追踪(LLAP)');
xlabel('时间(s)');
ylabel('距离(m)');
```

使用前面的数据，设备先远离声源移动10cm，然后远离声源移动20cm，最后移动回到初始位置。追踪结果如下。
从结果可以看出该方法追踪结果较为准确。

<center>
    <img src=".\fig\result_LLAP.png" width=600px>
</center>

