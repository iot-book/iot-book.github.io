# 低功耗广域网编码和通信实验

## 1.LPWAN

LPWAN (Low Power Wide Area Network)指的是低功耗广域网，其特点在于极低功耗，长距离以及海量连接，适用于物联网万物互联的场景。LPWAN不只是一种技术，而是代表了一族有着各种形式的低功耗广域网技术，如下图所示。其中LoRa使用的是一种扩频技术，而NB-IoT使用的是窄带技术，这两种LPWAN技术在世界和中国都是很受欢迎的两种技术。

<div align="center">
<div style="width:360px; height:auto; float:left; display:inline; margin-right:5px">
<center><img src="..\images\LoRa\LPWAN.png" alt="LPWAN技术" height="100%" width="100%"/></center>
<center>[LPWAN技术一览][1]</center>
</div>

<div>
<center><img src="..\images\LoRa\Wireless_Tech.PNG" alt="无线技术" height="50%" width="48%"/></center>
<center>Wireless Technology[2]</center>
</div>
</div>

无线通信技术从数据率和通信范围两个维度的比较如上图，不难看出，LPWAN填补了我们常见通信技术(比如WIFI，Bluetooth，4G/5G等)的一片空白，即通信距离长，通讯速率不高。虽然LPWAN通信速率不高，但是依然能够满大部分物联网通信的需求，同时其超低功耗也是它收到青睐的原因。

## 2. LoRa及其编码技术

### 2.1 LoRa

LoRa 是 Long Range Communication的简称，是 Semtech 公司定义的一种基于扩频技术的物理层调制方式。
LoRa 使用 CSS （Chirp Spread Spectrum）线性扩频，频率充满整个带宽，因此抗干扰极强，对多径和多普勒效应的抵抗也更强。
LoRa接收灵敏度高达 -148 dBm。以偏小的数据速率（0.3-50kbps）换取更高的通讯距离（市内3km，郊区15km）和低功耗（长达10年）。

Chirp是指频率随时间改变(增加或者减少)的信号，具体到LoRa通信，采用的是线性Chirp，即频率随时间线性增加或者减少的信号，如下两图，分别从时域和频域两部分展示了一段频率随着时间线性增加的Chirp信号。

<div align="center">
<div style="width:310px; height:auto; float:left; display:inline; margin-right:5px">
<center><img src="..\images\LoRa\Chirp_time.png" alt="Chirp时域图" height="100%" width="100%"/></center>
<center>Chirp时域图。横坐标为时间，纵坐标为信号幅度</center>
</div>

<div>
<center><img src="..\images\LoRa\Chirp_freq.png" alt="Chirp频域图" height="36%" width="43%"/></center>
<center>Chirp频域图。横坐标为时间，纵坐标为频率</center>
</div>
</div>

我们将频率随着时间线性增加的Chirp信号叫做upChirp，将频率随着时间线性减小的Chirp信号叫做downChirp。LoRa信号就由这样一个个Chirp组成，具体格式如下图。前面10个upChirp作为LoRa信号的前导码(注意第9和第10个upChirp其实做了一些编码)，之后跟着2.25个downChirp，叫做SFD，标识数据段的开始，后面就是LoRa信号编码的数据区了。
![LoRa包](..\images\LoRa\pkt.PNG)

### 2.2 LoRa编码

LoRa通过循环平移upChirp进行数据的编码，比如将BW等分成4分，分别编码00，01，10，11，如下所示。
![LoRa循环频移编码](..\images\LoRa\LoRa循环频移编码.PNG)
LoRa解码过程，实质就是求出chirp偏移量的多少，其做法通常是这样的：首先将收到的chirp信号与downChirp点乘，这一过程叫做Dechirp，这个操作能够将收到的chirp信号能量进行集中，是LoRa的抗噪及传输远距离的原因之一。

Dechirp之后，对得到的信号进一步使用FFT(傅里叶变换)，即可在某一个位置获得一个峰值，这个峰值落入的FFT bin对应的就是这个chirp编码的数据。对于非0编码，如果采样率高于带宽的话，会得到两个峰，我们可以将这两个峰进行叠加来增强峰的高度，并且求出对应的位置。下面两图分别对应编码0和非0数据的解码过程。
<div align="center">
<div style="width:310px; height:auto; float:left; display:inline; margin-right:5px">
<center><img src="..\images\LoRa\decode_0.PNG" alt="解码0偏移" height="100%" width="100%"/></center>
<center>解码0</center>
</div>

<div>
<center><img src="..\images\LoRa\decode_1.PNG" alt="解码非0偏移" height="100%" width="50%"/></center>
<center>解码非0偏移</center>
</div>
</div>

### 2.3 LoRa编解码原理解析

我们知道，chirp信号可以分为upChirp和downChirp，如下图所示。up-chirp从最低频率开始，随时间增加逐渐上升至最高频率。而down-chirp则与之相反，从最高频率逐渐下降至最低频率。LoRa定义最高频率和最低频率之间的差值为LoRa带宽，记作$BW$。
![upChirp和downChirp](..\images\LoRa\Chirp.png)
基准upChirp的最低频率为$f_0=-\frac{BW}{2}$，最高频率为$f_1=\frac{BW}{2}$，信号长度为$T$。因此其频率可以表示为$f(t)=f_0+kt$，其中$k=\frac{BW}{T}$表示扫频梯度。由此，基准up-chirp可以表示为：
$$
C(t)=e^{j2\pi(f_0+kt)\times t}
$$

当编码数据时，LoRa首先令基准upChirp乘上一个固定频率的偏移分量，偏移后的信号可以表示为$C(t)e^{j2\pi ft}$。随后，LoRa将所有频率高于$f_1$的信号段循环频移至$f_0$频率处，频移后的信号如下图(e)所示。如果定义了N种不同的偏移频率，最多可以编码$SF=log_2N$比特的数据。

LoRa数据解码由频率解扩频(Dechirp)和傅里叶变换(FFT)两个步骤组成。对于一个收到的数据包，LoRa首先令数据包中每个编码的chirp信号与基准downChirp相乘。与upChirp类似，基准downChirp可以表示为：

$$
C^*(t)=e^{j2\pi(f_1-kt)\times t}
$$

当$f_0 = -f_1$时，$C^*(t)$是$C(t)$的共轭，因此这个相乘的结果是一个单频信号，其频率等于编码chirp的频率偏移量：

$$
C^*(t)\times C(t)e^{j2\pi ft}=e^{j2\pi ft}
$$

随后，LoRa对得到的单频信号进行傅里叶变换(之后的章节会详细说明)，将时域信号转化为频域波峰，波峰的下标即对应信号编码的数据。

整个LoRa解码流程如下图所示，对应两种信号的解码，左为基准upChirp，右为编码后的upChirp。第一行为信号的时间-频率图，第二行为信号的时间-幅度图，第三行为信号乘downChirp后的时间-幅度图，第四行为傅里叶变换结果，注意左边在0的位置有峰。

![](..\images\LoRa\loraDecoder.png)

## 3. 用声音实现LoRa通信

### 3.1 LoRa信号通信过程

首先我们需要了解LoRa通信的过程，这同时也是大多数射频信号通信的过程。注意这里是一个很简化的版本，想要详细了解，可以自己进一步学习。

在发射端，原始数据首先进行调制，比如这里将数据调制到Chirp，得到一个基带信号，基带信号是频率很低的信号，传输距离受限，要达到预期的通信距离，对天线要求就很苛刻了。所以通常的做法是将这个基带信号调制到高频信号上，这一过程叫做上变频。之后，就是将信号传输出去，通过一个信道(比如空气，水等介质)，被接收者接收。

接收端的操作基本与发射端“相反”。首先是下变频得到低频率的基带信号，之后进行对应的解调得到原始数据。

射频信号通常需要对应的收发机进行发射和接收，这里我们通过声音去模拟这一通信的过程。之所以选择用声音去模拟实现，是因为声音可以用手机播放和录取，易于实践。

![通信流程](..\images\LoRa\通信流程.PNG)

### 3.2 声音实现
我们采用Matlab去生成声音，然后通过手机去播放(发射)，使用另一台手机去录音(接收)。最后再将这段信号传到电脑端进行最后的解调。

**发射端**

由于手机采样率限制，信号频率带宽不能很高，这里设置信号带宽bw=2*e3，采样率fs=48e3，编码sf=7个比特，也就是可编码数据为0-2^sf，这样可以计算出一个chirp的采样点数

```matlab
bw = 2e3;  % 带宽
fs = 48e3; % 采样率
sf = 7;
Nchirp = 2^sf/bw*fs; %一个Chirp的采样点数
```

接下来生成Chirp和基带LoRa信号，这里编码了3个6，之前加了一段0信号，是为了使信号长一点，编码录音的时候错过有效信号。对于编码数据，在实现上可以不同。

```matlab
data = [2^sf - 6, 2^sf - 6, 2^sf - 6]; % 编码3个6
pkt = u.genPacket(data);
zos = zeros(1, Nchirp*5);
chirp_sound = cat(2, zos, pkt);      %基带信号
```

之后上变频：将基带信号的实部乘上一个余弦高频信号，基带信号的虚部乘上一个正弦高频信号（有负号），最后将它们加起来作为真实发送的信号。
这里设置的高频信号为 $f_c = 16e3$ Hz。

```matlab
car_chirp_sound = real(chirp_sound).*cos(2*pi*fc*t)+imag(chirp_sound).*sin(-2*pi*fc*t);
```

注意，这里模拟射频信号，故使用了I/Q两路信号，并将其转成了复数形式，但是实际信道传输的信号使是信号，故最终只能取实部发送。具体的做法，感兴趣的可以自行深入学习。

最后即将生成的信号存成声音文件，这里是.wav格式，接下来进行播放即可。

```matlab
audiowrite('chirpSound.wav', car_chirp_sound, fs, 'BitsPerSample', 16);
```

**接收端**

使用手机收到数据(也是.wav格式)之后，需要对这个数据进行解码。读入数据，获取得到数据和采样率，通常只需要取一半即可。

```matlab
[recv_sound, fs] = audioread(soundFile); % [sample_points, fs]
recv_sound = recv_sound(:,1);
```

第一步是滤波去噪，去除不是想要频段的噪声。

```matlab
recv_sound_bf = BPassFilter(recv_sound, 18e3, 4e3, fs)
```

第二步即下变频，并通过低通滤波，提取基带信号。

```matlab
%% 下变频  从高频信息提取低频信号(基带信号)
real_chirp_sound = recv_sound_bf.*cos(2*pi*fc*t);
imag_chirp_sound = recv_sound_bf.*sin(-2*pi*fc*t));
%% 低通滤波
real_cs = BPassFilter(real_chirp_sound, 3e3, 2e3, fs);
imag_cs = BPassFilter(imag_chirp_sound, 3e3, 2e3, fs);
rec_chirp_sound = real_cs + 1j*imag_cs;
```

其中，BPassFilter 函数代码如下：

```matlab
% 本函数利用窗函数法设计带通滤波器，主要用来滤出单一频率，即中心频率
% data是输入的数据, centerFre是带通的中心频率, offsetFre是频偏,最终带通为centerFre +- offsetFre/2
% ,sampFre是采样率
function y = BPassFilter(data, centerFre, offsetFre, sampFre)
    % 设计I型带通滤波器
    M = 0 ;    % 滤波器阶数（必须是偶数）
    Ap = 0.82; % 通带衰减
    As = 45;   % 阻带衰减
    Wp1 = 2*pi*(centerFre - offsetFre)/sampFre;  % 算出下边频
    Wp2 = 2*pi*(centerFre + offsetFre)/sampFre;  % 算出上边频

    % 矩形窗
    N = ceil(3.6*sampFre/offsetFre); % 计算滤波器阶数,采用矩形窗，3dB截频在中心频率到上下边频的中点
    M = N - 1;
    M = mod(M,2) + M ; % 使滤波器为I型(偶数)

    % 单位脉冲响应的下脚标
    h = zeros(1,M+1);  % 单位冲击响应变量赋初值
    for k = 1:(M+1)
        if (( k -1 - 0.5*M)==0)
            h(k) = Wp2/pi - Wp1/pi;
        else
            h(k) = Wp2*sin(Wp2.*(k - 1 - 0.5*M))/(pi*(Wp2*(k -1 - 0.5*M))) - Wp1*sin(Wp1*(k - 1 - 0.5*M))/(pi*(Wp1*(k -1 - 0.5*M)));
        end
    end
    y = filter(h,1,data);
end
```

第三步是解码，这一步首先要对齐信号，我们根据信号能量，大致信号所在的区间。通过滑动窗口平均，可以过滤部分能量突变的情况。

```matlab
A = movmean(abs(rec_chirp_sound),mwin);
thresh = (max(A) - min(A))/3 + min(A);
inds = find(A > thresh);  % 找信号高于thresh的下标位置
cut_rec_cs = rec_chirp_sound(inds(1):(inds(end)+Nchirp));  % 截取信号
```

接下来我们介绍CFO(Carrier Frequency Offset)和TO(Time Offset)的影响。
假设我们发送的chirp信号扫频范围在2k(Hz)-4k(Hz)，到了接受端，收到的信号扫频范围可能会变成2k+100(Hz)-4k+100(Hz)，这个频偏是由于硬件处理，发射及接收信号造成的，我们称之为CFO。
当我们解码的时候，截取信号的窗口可能和信号没有完全对齐，这样也会带来一个频率偏移，我们称之为TO。
消除CFO可以通过发送单频前导码进行信道估计，消除TO可以参考ZigZag实验章节，利用相关性找到信号的准确起点。
<!-- 下面图分别示例了没有CFO窗口对齐和没对齐，有CFO窗口对齐和没对齐的四种解码结果。
![通信流程](..\images\LoRa\CFO_TO.PNG) -->

最后一步即利用FFT bin的结果解出最后的数据。代码中的操作是解出编码0和非0数据的FFT bin结果(id0和id)以及编码数据的间隔```delta_f```，利用```(id-id0)/delta_f```接出最后的数据。

## 4. LoRa编码和通信实验

<!-- 接下来就是激动人心的动手体验环节了。一共设计了三个实验，目的在于理解和体验LoRa的编解码方法以及射频通信过程。当然你还可以学会一定的信号处理方法。 -->
本实验的目标是使同学们理解LoRa编解码方法和射频通信过程，实验过程中需要用到一些信号处理方法。

<!-- ### 4.1 预热实验

**实验内容：** 

本部分实验，请同学们运行提供的代码和程序体验LoRa编解码和通信。

**实验步骤：**

- 解压缩课程资料。可以看到下面的目录

![课程资料](..\images\LoRa\课程资料.PNG)
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 课程资料</div>
</center>

其中code里面含有生成和解析声音的代码(genSound.m和anaSound.m)，接收app里面含有我们用Android写的app--music.apk，可以发送和接收声音。接收的数据存放了两个我们之前用手机接收的声音数据(m.wav和o.wav)。PPT是本次讲解用的，可以课后查看。Readme也提供了简单的课程资料介绍。

- 生成声音信号。用Matlab打开code文件夹，运行genSound.m，不出意外的话，在同级目录下会出现chirpSound.wav文件，.wav是一种声音存储格式，这就是用LoRa chirp生成的声音文件。

- 安装music.apk并开始录音。这里是基于Android平台的，只有ios的同学可以询问助教借用实验的Android机。下面是music.apk界面。

![app](..\images\LoRa\music_apk.jpg)
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 应用程序界面</div>
</center>

点击开始录音即会录，点击停止录音即停止当前的录音，并将生成的文件存到对应的位置，按钮下面标明了存储的路径。

- 发射声音。用手机或者电脑等可以播放声音的设备播放chirpSound.wav文件，提供的music.apk点击选择音频也可以进行播放，但是通常用自带的播放器就行了。

chirp信号中文翻译名为啁啾，因为它像鸟的叫声，大家实验一下，看是否是这样。

- 解码声音。找到录取的声音，将其传到电脑上面，然后再次使用Matlab运行anaSound.m，就可以对声音进行解析，并且输出最后的数据。不出意外的话，就可以看到编码的数据666了。

![解码结果](..\images\LoRa\res.PNG)
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 解码结果</div>
</center>

注意更改声音文件的路径，之前提供了两个声音文件，即使你没有发射接收操作，你也可以直接运行进行解码，当然最好是体验一整套通信流程。 -->

### 4.1 LoRa编码实验

**实验内容：**

<!-- 体验了通信流程，当然里面也包含了chirp的编码操作。大家就可以开始自力更生，自己试着生成chirp信号并编码啦！ -->
使用MATLAB，模拟LoRa编解码过程。

**实验步骤：**

- (1) 尝试使用MATLAB编码chirp信号，并绘制时域和频域图像，分析构造信号的正确性。

提示：可以使用MATLAB自带的Chirp函数或者直接用Chirp的数学表达式2*pi*f*t+k*pi*t^2。
<!-- 至于画时域图和频域图，可以自己学习参考课程资料给的代码。 -->

- (2) 尝试使用生成的chirp信号编码数据，设计对应的解码器并验证其功能。

提示：编码策略可以参考LoRa循环偏移的编码策略，也设计自己的编码方法。
<!-- 解码的代码也可以参考提供的课程资料里的代码。 -->

### 4.2 传输性能分析

<!-- - 大家都生成了自己的chirp，那么就可以探索一下chirp编码到底能不能更加抗噪，并且传输距离更远呢？ -->

**实验步骤：**

- 比较发射正弦波和LoRa chirp两种声音信号通信距离，能量强度等等。
<!-- - 既然会生成了chirp，那么生成正弦波也不在话下喽...... -->

- 如何让LoRa chirp信号传得更远？有哪些优化方法？可以自己动手试试。

## 参考文献

- [1] 《信息通信技术》 2017年01期 低功耗广域网络技术综述
- [2] [Sigcomm 2018: PLoRa: A Passive Long-Range Data Network from Ambient LoRa Transmissions](https://conferences.sigcomm.org/events/apnet2018/slides/plora.pptx)
- [3] https://revspace.nl/DecodingLora
- [4] http://wiki.thulpwan.top/index.php/LoRa
