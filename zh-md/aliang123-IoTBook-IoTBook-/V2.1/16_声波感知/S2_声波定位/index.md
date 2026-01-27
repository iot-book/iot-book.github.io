# 声波定位

有了前面测距的基础，我们很自然就可以利用声音进行定位了，只需要结合我们前面介绍过的三边定位的算法就可以了，在这一部分我们就不展开介绍了，感兴趣的同学可以自行基于测距的结果去实验一下定位的效果。

在这一部分，我们主要介绍基于AoA的声波定位算法。

## AOA定位：基于麦克风阵列的声源定位

本节将以线性排列麦克风阵列为例，介绍基于麦克风阵列的声音定位方法。利用麦克风阵列及AoA定位的原理可以实现室内声源的定位。首先，我们来看一下什么是麦克风阵列。

### 麦克风阵列

麦克风阵列是实现AoA定位算法的基础，其作用等效于我们在前面原理部分说过的天线阵列。麦克风阵列由若干个麦克风按一定布局排列构成。常见的麦克风阵列中麦克风的排列方式有线性排列、矩形排列、六边形排列等。麦克风阵列在声源定位、声音去噪、语音提取等领域有着广泛的应用。

<center>
    <img src=".\fig\microphone_array.jpg" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图16-2-1. 线性麦克风阵列</div>
</center>

上图为一个有4个麦克风的线性麦克风阵列板，4个麦克风（图中金黄色的元件）按等间距线性排列。假设声源距离麦克风阵列较远，将声波看作平行波。声音传播的模型如下图所示

<center>
    <img src=".\fig\array_model.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图16-2-2. 声音传播模型</div>
</center>

如图，两个麦克风间距为$d$，声波到达的角度（AOA）为$\theta$，则声源到两个麦克风的距离差为$d\cos\theta$，因此声波到达两个麦克风的到达时间差（TDOA）为$d\cos\theta/c$，其中$c$为声速。若已知两个得到两个麦克风的间距$d$，以及声音到达两麦克风的时间差$\Delta t$，即可计算到达角度$\theta$。

### 声音到达时间差及到达角的计算

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

实际应用中，直接计算$\phi_{xy}(t)$的复杂度较高，利用公式$\mathcal{F}(x(t)\ast y(-t))=X(\omega)Y^{\ast}(\omega)$，其中$X(\omega)$为$x(t)$的傅里叶变换，$Y(\omega)$为$y(t)$的傅里叶变换。

计算$X(\omega)Y^{\ast}(\omega)$，再求傅里叶逆变换即可得到$\phi_{xy}(t)$，即
$$
\phi_{xy}(t)=\int_{0}^{\pi}{X\left(\omega\right)Y^\ast\left(\omega\right)e^{-j\omega t}d\omega}
$$
将信号时域卷积变为频域相乘能降低计算开销。另外，为消除混响和噪声的影响，可以在频域进行加权，比较常见的加权函数为PHAT加权
$$
\phi_{PHAT}\left(\omega\right)=\frac{1}{|X\left(\omega\right)Y^\ast\left(\omega\right)|}
$$
互相关函数变为
$$
\phi_{xy}(t)=\int_{0}^{\pi}{\phi_{PHAT}\left(\omega\right)X\left(\omega\right)Y^\ast\left(\omega\right)e^{-j\omega t}d\omega}
$$
利用互相关函数的峰值计算得到TDOA，即可用基于TDOA的方法计算出信源的AOA。

综上所述，计算互相关函数的最大值即可得到声音到达两麦克风的到达时间差，从而得到声音的到达角度。

下面利用实际录音得到的数据进行分析，使用4麦克风的线性阵列，播放的声音与麦克风阵列成45°。计算到达到达时间差和角度的具体实现代码如下（res\correlation.m）？？？

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

基于AoA测量角度，利用声音的到达角度，现在的智能设备就可以完成很多事情，例如可以利用麦克风阵列进行定向拾音，智能音箱判断说话的人在房间里面的方向和角度，加强某一角度的声音信号，声音去噪等。

### 声源定位

使用两个或以上的麦克风阵列，若已知各阵列的位置，结合声音的到达角度，即可基于到达角度进行定位。

<center>
    <img src=".\fig\sound_positioning.png" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">图16-3-3. 声源定位模型</div>
</center>

如上图，两个阵列$A_1$，$A_2$的位置已知，通过计算得到声源S发出的声音的到达角度$\theta_1$和$\theta_2$，即可定位声源$S$的二维坐标。具体的定位方法参见前面AoA定位方法介绍章节。


## 指纹定位：基于声音信号强度分布的声源定位

在原理部分我们介绍了利用信号在空间内分布的指纹特征可以实现对无线设备的定位。借助信号分布特征定位的思想，在声音系统中也可以利用声音信号的强度分布特征来定位。本节主要介绍了如何里利用声音信号强度分布实现声源定位。

首先，我们思考是否可以利用声音信号实现基于指纹的定位方法呢？我们观察扬声器播放的单频率声音信号，可以发现：不同频率声音信号在传播过程中，其发散的程度是不同的，高频声音信号传播的方向性更强，低频声音信号在传播中更容易发散。因此，可以利用不同频率声音信号的传播特点实现定位。

现有的声音定位方法通常可以利用单个音箱和手机实现一维测距。考虑与音箱某个距离L的圆周，如果对手机进行一维测距的结果为L，则可以确定手机处于该圆周上。如果结合上文所述的声音信号在声场中的分布规律，即在圆周上与音箱夹角不同角度处接收的信号强度不同这一性质，即可根据手机接收到的信号的强度信息，确定手机与音箱的夹角，即确定了手机在圆周上的位置。这是利用声音信号强度分布实现手机定位的基本思路。

我们可以将问题从确定手机的具体位置简化为如下，在距离音箱30厘米处设定一个边长为15cm的3×3的网格，每个网格是边长是5cm。我们可以利用声音信号，对手机处于网格的位置进行的分类。这样就将定位问题简化为一个对手机所在位置的9分类问题。

对于声音信号，如前文所述，我们在商用扬声器和麦克风常见的20Hz到20kHz工作频段中选择10个频率的正弦声音信号进行混合，作为使用的声音信号。同时，这里实现了现有的一维测距工作来测量扬声器到手机的距离。手机接收到声音信号后，按前文所述进行带通滤波以分离10个不同频率的声音信号，并分别求出信号的强度$s_1\ldots s_{10}$。我们以频率最低的信号强度作为基准，其他频率的信号强度均除以该信号的强度，求得9个强度比$i_1\ldots i_9$。此时我们得到了9个强度比和扬声器到手机的距离这10个参数。

训练过程中，我们将上述10个参数作为输入，手机所处的网格位置作为结果，训练一个具有单层隐藏层的人工神经网络。神经网络的结构示意图如图2-8，其中d代表扬声器到手机的距离，$i_1\ldots i_m$代表m个信号强度比（实验中m=9），$p_1\ldots p_n$代表输出的n类结果的概率（实验中n=9，表示3×3方格的9分类）。测试过程与训练过程类似，首先采集每个测量点的声音信号数据，求出9个强度比和距离。随后利用该神经网络模型对这10个参数进行分析，对手机采样时所处的网格位置进行分类和预测。训练集数据和测试集数据的采样位置如图2-9所示。其中训练集采样位置是均匀分布在每个网格内的4个点，测试集采样位置是每个网格内随机生成坐标的3个点。该神经网络模型的输出结果是一个长度为9的向量，向量的每个元素介于0和1之间，表示手机处于该网格内的概率。我们最终将采用概率最高的结果作为对手机位置分类的结果。

## 参考论文
1. Linsong Cheng, Zhao Wang, Yunting Zhang, Weiyi Wang, Weimin Xu, Jiliang Wang. "Towards Single Source based Acoustic Localization", IEEE INFOCOM 2020. [PDF]
2. Yunting Zhang, Jiliang Wang, Weiyi Wang, Zhao Wang, Yunhao Liu. "Vernier: Accurate and Fast Acoustic Motion Tracking Using Mobile Devices", IEEE INFOCOM 2018. 
3. Pengjing Xie, Jingchao Feng, Zhichao Cao, Jiliang Wang. "GeneWave: Fast Authentication and Key Agreement on Commodity Mobile Devices", IEEE ICNP 2017
