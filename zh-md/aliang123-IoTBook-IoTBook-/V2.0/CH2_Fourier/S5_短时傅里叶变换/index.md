# 短时傅里叶变换

将信号做傅里叶变换后得到的结果，并不能给予关于信号频率随时间改变的任何信息。因此一种傅里叶变换的一种变形——短时傅里叶变换被提出（Short-time Fourier transform, STFT），用于决定随时间变化的信号局部部分的频率和相位。实际上，计算STFT的过程是将长时间信号分成数个较短的等长信号，然后再分别计算每个较短段的傅里叶变换。STFT通常拿来描绘频域与时域上的变化，是时频分析中一个重要的工具。

以下的例子作为说明：

$$
x(t)=\left\{
\begin{aligned}
\cos (440\pi t), &\quad t < 0.5 \\
\cos(660\pi t), &\quad 0.5 \leq t < 1 \\
\cos(524\pi t), &\quad t \geq 1.
\end{aligned}
\right.
$$

傅里叶变换后的频谱和短时傅里叶变换后的结果如下：

<center>
<img src="./fig/ft.jpg" width="600px">
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 傅里叶变换, 横轴为频率(Hz)</div>
</center>

<center>
<img src="./fig/stft.jpg" width="600px">
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 短时傅里叶变换, 横轴为时间(s)，纵轴为频率(Hz)</div>
</center>

在STFT过程中：

- 窗的长度决定频谱图的时间分辨率和频率分辨率。
- 窗长越长，截取的信号越长。
- 信号越长，傅里叶变换后的频率分辨率越高，时间分辨率越差。
- 相反，窗长越短，截取的信号就越短，频率分辨率越差，时间分辨率越好。

STFT中时间分辨率和频率分辨率之间不能兼得，应该根据具体需求进行取舍。

简单来说，短时傅里叶变换就是先把一个函数和窗函数进行相乘，然后再进行一维的傅里叶变换。并通过窗函数的滑动得到一系列的傅里叶变换结果，将这些结果竖着排开得到一个二维的表象。

短时傅里叶变换（Short Time Fourier Transform，STFT）公式为

$$
X(t, f) = \int_{-\infty}^{\infty}w(t-\tau)x(\tau)e^{-j2\pi f\tau}d\tau.
$$

我们以MATLAB举例STFT的使用。首先利用压控振荡函数`vco`生成两个频率随时间正弦振荡的信号，然后计算该信号的STFT。STFT的参数中，我们使用形状参数$\beta = 5$且长度为256的Kaiser窗，重叠长度设为220个采样点，DFT的长度设为512。

```matlab
fs = 10e3;
t = 0:1/fs:2;
x = vco(sin(2*pi*t),[0.1 0.4]*fs,fs);
stft(x,fs,'Window',kaiser(256,5),'OverlapLength',220,'FFTLength',512);
```

我们还可以从三维角度看一下变换结果。
```matlab
view(-45,65)
colormap jet
```

<center>
<img src="./fig/matlab_stft_img1.png" width="600px">
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 短时傅里叶变换结果</div>
</center>

<center>
<img src="./fig/matlab_stft_img2.png" width="600px">
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 三维视角的短时傅里叶变换结果</div>
</center>
