# AoA声波定位感知实现

## 麦克风阵列
使用声波实现AoA实现声波感知，我们需要使用麦克风阵列，麦克风阵列的作用就是前面我们说过的天线阵列。
麦克风阵列由若干个麦克风按一定布局排列构成。常见的麦克风阵列中麦克风的排列方式有线性排列、矩形排列、六边形排列等。麦克风阵列在声源定位、声音去噪、语音提取等领域有着广泛的应用。

<center>
    <img src=".\fig\microphone_array.jpg" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图1. 线性麦克风阵列</div>
</center>

上图为一个有4个麦克风的线性麦克风阵列板，4个麦克风（图中金黄色的元件）按等间距线性排列。

## 麦克风阵列定位

本节将以线性排列麦克风阵列为例介绍基于麦克风阵列的声音定位方法。

假设声源距离麦克风阵列较远，将声波看作平行波。声音传播的模型如下图所示

<center>
    <img src=".\fig\array_model.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图2. 声音传播模型</div>
</center>

如图，两个麦克风间距为$d$，声波到达的角度（AOA）为$\theta$，则声源到两个麦克风的距离差为$d\cos\theta$，因此声波到达两个麦克风的到达时间差（TDOA）为$d\cos\theta/c$，其中$c$为声速。

若已知两个得到两个麦克风的间距$d$，以及声音到达两麦克风的时间差$\Delta t$，即可计算到达角度$\theta$。

**声音到达时间差及到达角的计算**

利用互相关函数可以计算两个声音信号的到达时间差，假设麦克风$M_0$接收到的信号为$x(t)$，麦克风$M_1$接收到的信号为$y(t)=Ax(t-t_0)$，声波到达$M_0$与$M_1$的到达时间差为$t_0$。则$x(t)$与$y(t)$的互相关函数定义为

$$
\phi_{xy}(t)=\int^{+\infty}_{-\infty}x(\tau)y(t+\tau)d\tau=x(t)\ast y(-t)
$$

其中$\ast$表示卷积运算。

将$y(t)$的表达式代入，得到

$$
\phi_{xy}(t)=A\int^{+\infty}_{-\infty}x(\tau)x(t+\tau-t_0)d\tau
$$

当$t=t_0$时，$\phi_{xy}(t_0)=A\int^{+\infty}_{-\infty}x(\tau)^2d\tau$取得$\phi_{xy}(t)$的最大值。

实际应用中，直接计算$\phi_{xy}(t)$的复杂度较高，利用公式$\mathcal{F}(x(t)\ast y(-t))=X(\omega)Y^{\ast}(\omega)$，其中$X(\omega)$为$x(t)$的傅里叶变换，$Y(\omega)$为$y(t)$的傅里叶变换。计算$X(\omega)Y^{\ast}(\omega)$，再求傅里叶逆变换即可得到$\phi_{xy}(t)$。

综上所述，计算互相关函数的最大值即可得到声音到达两麦克风的到达时间差，从而得到声音的到达角度。

下面利用实际录音得到的数据进行分析，使用4麦克风的线性阵列，播放的声音与麦克风阵列成45°。计算到达到达时间差和角度的具体实现代码如下（res\correlation.m）

```matlab
% 读入音频文件
[data,fs] = audioread('array_record.wav');
% 将数据转化为每行一个声道
data=data.';
% 取阵列上的第一个和第四个麦克风的数据
x=data(1,:);
y=data(4,:);
% 两麦克风间距15cm
d=0.15;
c=340;

%matlab自带的互相关函数
%[corr,lags] = xcorr(x,y);

%自己实现互相关的计算TDOA
X=fft(x);
Y=fft(y);

corelation = ifft(X.*conj(Y));

l=length(corelation);

[m,index] = max(corelation);

if index > floor(length(corelation)/2)
    index = (index-1)-length(corelation);
else
    index = index-1;
end

delta_t = index/fs
%计算AOA
theta = acos(delta_t*c/d)/pi*180

```

得到结果

```matlab
delta_t = -3.1250e-04
theta = 135.0995
```

计算得到夹角约135度（与45度互补），与实际情况相符。

利用声音的到达角度，可以利用麦克风阵列进行定向拾音、声音去噪等应用。

**声源定位**

使用两个或以上的麦克风阵列，若已知各阵列的位置，结合声音的到达角度，即可使用9.3节的基于到达角度的定位方法进行定位。

<center>
    <img src=".\fig\sound_positioning.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图3. 声源定位模型</div>
</center>

如上图，两个阵列$A_1$，$A_2$的位置已知，通过计算得到声源S发出的声音的到达角度$\theta_1$和$\theta_2$，即可定位声源$S$的二维坐标。具体的定位方法参见前面AoA定位方法介绍章节。
