# 基于信号相位的追踪方法

## 相位追踪的原理
相位定位追踪是物联网定位追踪中的常用方法，尤其近些年出现了一系列基于相位的定位和追踪方法，使用了电磁波、声波信号等。大家如果有经常看物联网相关论文应该会比较熟悉。

相位定位的基本原理就是测量信号的相位变化，在数据调制那一章我们已经介绍过了相位，大家可以回去再看一下。
在定位过程中，相位追踪可以从几个不同的方面来进行理解。
假设信号源发送的固定频率信号为$R(t)=Acos(2\pi ft)$，信号经过路径$p$传播，传播路径长度随时间的变化为$d_p(t)$。接收到的经路径$p$的声音信号可以表示为：

$$
R_p(t)=A_p(t)cos(2\pi ft-\frac{2\pi fd_p(t)}{c}-\theta_p)
$$

其中$A_p(t)$为接收信号的幅度，$2\pi fd_p(t)/c$为传播引起的相位偏移，$c$为声速，$\theta_p$是由于硬件的延迟、反射带来的半波损失等造成的相位偏移，这部分可以认为是常量，不随时间变化。若从接收信号$R_p(t)$中获取相位信息。根据相位，可以得到传播路径长度$d_p(t)$的变化情况，实现接收者运动路径的追踪。

若利用位于不同位置，发送不同频率声波的多个声源，在已知起始位置的情况下，根据设备在一段时间内的与不同声源距离的变化，可以计算得到设备空间位置的变化情况，实现高精度的定位与追踪。

## 相位追踪的实现

### 相位计算基本方法

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

使用10.1节的数据，设备先远离声源移动10cm，然后远离声源移动20cm，最后移动回到初始位置。追踪结果如下(res\phase_LLAP.m)

<center>
    <img src=".\fig\result_LLAP.png" width=600px>
</center>

从结果可以看出该方法追踪结果较为准确。

### Vernier

基于信号相位变化的追踪方法，关键在于计算接收信号的相位变化。经典的测定相位变化的方法对相位的计算精度受限于信号的采样率。而声音信号的采样率又受到硬件和软件的双重限制。因此，通常很难通过提高信号采样率来提高追踪的精度。

我们在Vernier[1] 提出了一种在信号采样率固定不变的前提下，提高基于相位变化的追踪方法精度的方法。

**游标卡尺的原理**

首先，我们考虑一个类似的间接提高分辨率的例子：游标卡尺。游标卡尺是一种用于精确测量长度的工具。一般而言，游标卡尺由两部分构成，一部分是主尺，另一部分是可滑动的游标，可以在主尺上自由滑动。主尺和游标上都有刻度，但是二者的刻度间距稍有不同。主尺的刻度一般都是整毫米的，而游标上的刻度一般与主尺上的刻度往往有微小的差距。

<center>
    <img src=".\fig\Vernier01.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图1. 游标卡尺示意图</div>
</center>

对于常见的游标卡尺，其主尺刻度间隔为1mm，游标上的刻度间隔为0.9mm。如果我们要测量的距离为$r$，那么我们可以得到：

$$
r-r'+0.9x=1.0x
$$

其中，$r’$表示对$r$进行向下取整的结果，$x$表示游标的第多少个刻度，能够与主尺上的刻度互相对齐。经整理，得到：

$$
r-r'=0.1x
$$

由于游标每向右移动了一个刻度，其与主尺上的刻度上的差距就增加了0.1 mm。因此，利用这个原理就可以对长度进行更精确地测量。值得指出的是，游标卡尺的测量精度本质上并不是由游标和主尺上的刻度差值决定的，而是由二者的最大公约数决定的。

**信号相位变化的测定**

接下来，我们介绍一种类似游标卡尺原理的信号相位变化的测定方法。

首先定义以下两个变量：

LMP（Local Max Prefix）：在一个信号采样窗口中，我们规定第一个采样点的LMP为0。从第二个采样点开始，如果某一个点的值（就是该采样点的信号强度），既大于它的前一个值，又大于它的后一个值，那么这个点的LMP值为它的前一个点的LMP值加1，否则该点的LMP值等于其前一个点的LMP值。

LMPS（Local Max Prefix Sum）：LMPS是在一个窗口中，所有采样点的LMP的和。

假定在时间$t_1$和时间$t_2$两个时刻，录音设备取得两个等长时间窗口的音频数据$w_1$和$w_2$。每个窗口中有恰好有$p$个周期的声音信号，这$p$个周期的信号刚好对应着$q$个采样点。$w_1$和$w_2$两个时间窗口的数据的LMPS分别为$L_1$和$L_2$。则这两个窗口所经历的相位变化为 $\Delta \phi = (L_2 - L_1)2\pi /q$。距离变化为 $\Delta d = \lambda \Delta \phi-c(t_2-t1)/2\pi$。其中c是声音在空气中的传播速度。

<center>
    <img src=".\fig\Vernier03.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图2. LMP和LMPS示意图</div>
</center>

如图所示，在一个时间窗口内，p = 3，q = 13。则该窗口内信号各采样点的LMP如图所示，信号的LMPS为26。

<center>
    <img src=".\fig\Vernier03.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图3. Vernier测量相位变化示意图</div>
</center>

当信号相位前移 2π / q时，LMPS增加1。

因此，当p = 3，q = 13时，每当LMPS增加1，信号的相位变化了 2π / 13。距离变化（减小）了 λ / 13。

利用上述方法可以实现更高精度的基于相位变化的追踪。

该方法的具体实现代码如下(res\phase_Vernier.m)

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

%% 计算LMP和LMPS变化
% fs=48000
f0 = 21000;
c = 340;

% fs:f0=16:7
%以16个采样点为窗口，每个含有7个周期的信号
slice_len = 16;
p=7;

slice_num=floor(length(data)/slice_len);
lmps=zeros(1,slice_num);
for i = 0:1:slice_num-1
    lmp=0;
    sum=0;
    for j=2:1:slice_len-1
        if data(i*slice_len+j)>data(i*slice_len+j+1) && data(i*slice_len+j)>data(i*slice_len+j-1)
            lmp=lmp+1;
        end
        sum=sum+lmp;
    end
    sum=sum+lmp;
    lmps(i+1)=sum;
end

%% 修复异常数据
% LMPS的上界和下界分别为60和45
u_bound=60;
l_bound=45;

for i = 2:length(lmps)
    % 将超出界限的数据修复为前一个时间片的数据
    if lmps(i)<l_bound
        lmps(i)=lmps(i-1);
    elseif lmps(i)>u_bound
        lmps(i)=lmps(i-1); 
    end
end

%% 计算相位变化和距离变化
% 对相位跳变进行补偿
bias=0;
phase=lmps;
for i=2:length(phase)
    if lmps(i-1)>u_bound-4 && lmps(i)<l_bound+4
        bias=bias+1;
    elseif lmps(i-1)<l_bound+4 && lmps(i)>u_bound-4
        bias=bias-1;
    end
    phase(i)=lmps(i)+bias*slice_len;
end
phase = phase*2*pi/slice_len;

% 起始点为0
phase = phase-phase(1);

distance = - phase /(2*pi*f0) *c;

delta_t = slice_len/fs;
time = 1:slice_num;
time = time*delta_t;

plot(time,distance)
title('基于相位的追踪(Vernier)');
xlabel('时间(s)');
ylabel('距离(m)');
```

使用第一个相位追踪方法相同的声波数据，追踪的结果如下

<center>
    <img src=".\fig\result_vernier.png" width=600px>
</center>

从结果可以看出该方法能准确地追踪设备的运动。

## 参考文献

1.Yunting Zhang, Jiliang Wang, Weiyi Wang, Zhao Wang, and Yunhao Liu. 2018. Vernier: Accurate and Fast Acoustic Motion Tracking Using Mobile Devices. In IEEE INFOCOM 2018-IEEE Conference on Computer Communications. IEEE, 1709–1717.