# 幅度调制

​		幅度调制，简称调幅，也就是Amplitude-shift keying (ASK)，是通过为信号设置不同的幅度来实现调制的调制方法。最简单的幅度调制是ON-OFF Keying (OOK)，这也是大家经常听到的一种数据调制形式，例如RFID的数据调制方法就是OOK。简单来说，OOK使用固定频率的信号代表“1”，没有信号代表“0”。这种用来表示一个二进制数的信号我们称为**码元**，每种调制方式都有自己设定的一组码元，其中的每个码元都是一段互不相同的信号，代表不同的二进制数。在OOK中，共有2种码元，每个码元代表1位二进制数。在其他的调制方式中，码元也可以代表多位二进制数。OOK的两种码元的长度相同。下面是使用OOK调制的示意图：

<center>
<img src = "./fig/5.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 幅度调制</div>
</center>

​		从图上可以看出来，发送数据“1”的时候是有信号的，发送数据“0”的时候是没有信号的，这样在接收端可以通过收到的信号来判断数据“0”和“1”。
> 思考：在接收端如何判断数据“0”和“1”。
>

​		如果要进一步提高幅度调制的效率，可以通过设置不同的振幅级别来实现，使得每个码元代表更多位数的二进制数，从而携带的信息更多：

<center>
<img src = "./fig/6.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 增加振幅级别可以提高编码效率</div>
</center>
​		例如图中信号有4个不同的幅度，那么每一种幅度就可以对应两位bit，因此同样的时间里面信号就可以表示更多的位数。

​		采用不同的幅度后，会带来其他的影响。在幅度调制中，需要考虑的问题是要使得不同码元的幅度有足够大的区分度，否则解码时无法区分不同的幅度，在有噪声的情况下，不同的信号幅度可能变得更加难以区分。因此理论上来说，针对不同的噪声，我们应该设置不同的信号幅度来保证无线信号传输的效果。
这也是为什么真实通信系统不同的信噪比下有不同的最优发送速率。另外一点需要考虑的就是信道的特性。信道是否稳定，如果信道状态发生变化，可能减弱本来幅度较高的信号，导致解码错误。

​		声音信道就是一种比较容易变化的信道，周围反射环境的变化会使得信道出现明显变化。这种情况下可以通过缩短数据包的长度来折中处理。当数据包的长度足够短的情况下，在这个数据包发送的过程中，声音信道的变化是比较小的。一般通信过程中，我们也假设一个数据包的传输过程中通信信道是基本保持不变的，这就是通常我们所说的假设信道是coherent的。

> 思考: 信号经过信道传输之后，会发生强度的衰减。当接收端接收到信号时，信号幅度的绝对值已经发生了很大的改变。如何才能保证正确解码出信号中的数据？

## 使用声波信号实现OOK

​	前面我们展示过了如何生成、发送和接收声波信号，现在我们来看一下如何利用声波信号来传输数据。在本书中，数据传输基本都以声波为基础，而不是无线电磁波信号，因为声波信号处理起来更加直观，而且利用大家自己的手头设备（例如手机等）就可以。

​		首先我们生成两个symbol，分别编码1和0。

~~~matlab
% symbol 1
fm=100;                         %信号频率
fs=fm*100;                      %采样频率
Am=1;
symbol_len=512;                 %一个symbol的长度
t=(0:1/fs:(symbol_len-1)/fs);
% symbol 1
smb1=Am*cos(2*pi*fm*t);         
% symbol 0
smb0 = zeros(1, symbol_len);
~~~

​		接下来我们根据OOK编码的方法生成基带信号，基带信号这个名词大家在看论文和看其他专业技术书籍的时候都经常会听到。一般来说基带信号是针对没有上变频的信号的，通俗一点来理解，目前为止大家看到的编码解码的方法都还是在基带上，还没有上到载波上。
​		在我们学习调制解调过程的时候，我们要先理解基带调制，我们看到的大部分论文也主要是在讲基带调制的过程，上载波的过程是后续的步骤。所以大家可能会听到基带芯片，那也就是在做这个事情，主要做在上载波之前数据需要编码调制的事情。
​		在真正发送的时候，信号会调制到载波上，这个时候信号就不在是在基带上的信号了。

~~~matlab
datas = [0, 1, 0, 0, 1, 0, 1, 1];
sig = [];
for data = datas
    if data == 0
        sig = [sig, smb0];
    else
        sig = [sig, smb1];
    end
end
~~~

​		将这个基带信号加到载波上得到我们要传输的真实信号，就可以发送出去了。这一步是上载波的过程。

> 思考：理论上来说，有了前面的基带调制，信号中就已经包含数据了，为什么还需要上载波？

~~~matlab
% 载波
fc=1000;                       %载波频率
t = 0:1/fs:(length(sig)-1)/fs;
carrier_wave = cos(2*pi*fc*t);
% 将基带信号加到载波上
sig_carrier=sig.*carrier_wave;
~~~

​		信号产生后再由发送端经过信道到达接收端，比如手机播放的声音，经过空气传输，墙面反射等等，最终到达接收端。一般来说，信号从发送端到达接收端经过的整个过程都被抽象为信道。这里我们使用Matlab来仿真信号通过信道的过程，通常给信号加上白噪声来模拟信道带来的影响（注意，真实场景中还需要添加多径等其他影响）。

~~~matlab
%% 信道传输 加入噪声
sig_carrier = awgn(sig_carrier, 5);
~~~

> 注： 可在Matlab下面命令行中输入```help awgn```查看```awgn```函数使用说明，其他函数同理。

​		接下来是接收端的代码实现。
​		为了解码这个数据，首先请注意，接收到的数据是上载波后的信号，通常这个信号的频率是非常高的（例如WiFi下是2.4GHz），我们一般不直接解调这么高频率的信号。
​		我们的第一步是先将信号下变频，即先将信号转移到基带上来。

> 思考：如何将载波上的信号转移到基带上来？

​		为了将载波上的信号转移下来，首先将整个信号乘上同频同相的参考信号，然后逐symbol的经过低通滤波，即可恢复出基带信号。

~~~matlab
sig_rec=sig_carrier.*carrier_wave;                %乘以载波
% 低通滤波
base_sig = [];
for i = 1:symbol_len:length(sig_rec)
    smb = sig_rec(i:i+symbol_len-1);
    %低通滤掉高频
    sig_baseband = BPassFilter(smb, 100, 10, fs);
    base_sig = [base_sig, sig_baseband];
end
~~~

​		最后通过设定一个阈值，根据幅值大小来解出symbol。

~~~matlab
decode_datas = [];
thresh = 1;
for i = 1:symbol_len:length(base_sig)
    smb = base_sig(i:i+symbol_len-1);
    A = sum(abs(smb));
    if A > thresh
        decode_datas = [decode_datas, 1];
    else
        decode_datas = [decode_datas, 0];
    end
end
~~~

## 脉冲间隔调制

​		脉冲间隔调制是利用相邻两个脉冲信号之间的时间间隔来调制数据。使用指定长度的间隔来代表特定的二进制串。最简单的脉冲调制是使用一长一短两种间隔，分别代表“0”和“1”。在解码时，只需要识别出每个脉冲信号的起始位置，就可以得到不同脉冲之间的间隔，从而可以根据每个间隔的长短将其解码为“0”或“1”。

<center>
<img src = "./fig/1.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 脉冲调制原理</div>
</center>

​		脉冲间隔调制由于使用简单的对应规则将“0”和“1”编码为不同长度的间隔，在解码时可以根据信号幅度得到每个脉冲的起始位置来获得间隔的长短，这种编解码方法的优点是计算开销非常小。

脉冲间隔调制的缺点是编码效率低，每个脉冲之间需要有足够的时间宽度。
> 思考为什么要留足够的时间宽度。

留足够多的时间宽度可以来防止多径效应造成的回声影响到下一个脉冲的判断。想要提高脉冲调制的数据速率，可以从两个方面来考虑。

​第一个方面是缩短编码的长度，既可以缩短脉冲之间的时间间隔，也可以缩短脉冲信号本身的持续时间。在保证解码正确率的条件下，相同的时间就可以传输更多的数据。

<center>
<img src = "./fig/2.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 缩短脉冲间隔和脉冲持续时间可以提高编码效率</div>
</center>

​		第二个方面，可以通过设置多种编码长度，使一个编码位携带更多的信息。如下图中所示，设置2种编码长度时，每个编码位携带1比特信息；设置4中编码长度时，每个编码位携带2比特信息；设置8种编码长度时，每个编码位携带3比特信息。

<center>
<img src = "./fig/3.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 设置多种编码长度</div>
</center>

当然，我们不能无限制地增加编码长度。当不同的编码长度之间的区分度越小，解码时将它们区分开的难度也越大。另外，如果不同的编码单位出现的概率不同，我们还可以使用霍夫曼编码（Huffman coding）的思想来进一步优化脉冲间隔编码的效率。比如说在一个待发送的文件中“0”的个数大于“1”的个数，使用较短的间隔代表“0”，长的间隔代表“1”，可以使总的发送时间更短。




​		本节以脉冲间隔调制为例，在代码层面实现一个简单的无线通信系统。具体来说，该系统包含一个发送方和一个接收方。发送方的输入是一段文本信息，输出一个音频文件，作为调制好的信号。我们通过手机或者电脑播放该音频文件，然后用另一台设备进行接收。接收方的输入是录制后的音频文件，即接收到的信号，输出是一段文本信息。


​		通过下面代码的实现，大家可以动手体验一下实际环境中的信号传输过程。体会
- 实际传输中的基本步骤
- 实际环境给无线通信带来各种各样的问题，在物联网通信的很多前沿研究工作和论文中，实际上很多时候都是处理各种实际场景里面的问题。
比如
  - 如何检测数据从什么时候开始
  - 如何滤除接收信号中的干扰噪声
  - 如何处理扬声器和麦克风的失真
  - 如何处理发送端设备和接收端设备的频移（这在物联网设备尤其是低成本物联网设备上更加普遍和严重）
  

## 编码
​		我们首先需要把输入的文本信息转换为二进制串，然后才能进行调制。可以按照$ASCII$的编码方式将文本中的每个字符对应到8 bit，按照顺序将它们连接起来。为此我们实现一个名为```string2bin```的函数：

```matlab
function [ binary ] = string2bin( str )
%把字符串转换成二进制串
ascii = abs(str);
L = length(ascii);
binary = zeros(L,8);
for i=1:L
    binary_str = dec2bin(ascii(i));
    binary_str_index = length(binary_str);
    for j = 8:-1:1
        if binary_str_index >0
            binary(i,j) = str2num(binary_str(binary_str_index));
        else
            binary(i,j) = 0;
        end
        binary_str_index = binary_str_index-1;
    end
end
binary = reshape(binary',[L*8,1]);
end
```

​		我们采用声波信号进行通信。采样频率为48 kHz​，由于大多数人听不到17 kHz频率以上的声音，也不会发出超过17 Hz的声音，因此在我们的方法中我们让设备发送18 kHz的声波，这样就可以在发送过程中不干扰其他人，也可以让信号避免被人说话声音干扰。选择脉冲长度为100个采样点，由于采样频率为48 kHz，脉冲的持续时间是$100/48000\approx 2.1ms$。脉冲之间的间隔采样点数与编码的对应规则见下表：

脉冲间隔（单位为采样点）|	编码
------ | ------
50 | 00
100	| 01
150	| 10
200	| 11

## 调制

​		有了编码规则，我们就可以根据输入文本生成信号了。

​		首先是要产生声波信号，在脉冲间隔调制中，我们需要生成固定频率（18 kHz）固定长度（100个采样点）的脉冲信号：

~~~matlab
%%
fs = 48000;                         %设置采样频率
f = 18000;                          %指定声音信号频率
time = 0.0025;                      %指定生成的信号持续时间
t = 0:1/fs:time;                    %设置每个采样点数据对应的时间
t = t(1:100);                       %截取出100个时间上的采样点
impulse = sin(2*pi*f*t);            %生成频率为f的正弦信号
~~~

​		接下来我们生成用于编码的空白部分：

~~~matlab
delta = 50;
pause0 = zeros(1,delta);      %编码00
pause1 = zeros(1,2*delta);    %编码01
pause2 = zeros(1,3*delta);    %编码10
pause3 = zeros(1,4*delta);    %编码11
~~~

​		设置待传输的字符串：

~~~matlab
str = 'Tsinghua University';
~~~

​		调用```string2bin```函数时传入之前设置的待传输字符串，就可以得到待传输的二进制串，将其存储在变量```message```中：

~~~matlab
message = string2bin( str )'; %调用函数把字符串转为二进制串
%因为我们设计的编码是每个码元代表2个bit，这里要把二进制串转为4进制串
[~,m_Length] = size(message);
message4 = [];
for i = 1:m_Length/2
    % 把二进制串中的每两位进行结合，得到四进制串
    message4 = [message4,message(i*2-1)*2+message(i*2)];
end
~~~

​		生成编码数据：

~~~matlab
output = [];
% 根据四进制串中的值，将impulse和对应的空白信号添加到输出信号中
for i = 1:m_Length/2
    if message4(i)==0
        output = [output,impulse,pause0];
    elseif message4(i)==1
        output = [output,impulse,pause1];
    elseif message4(i)==2
        output = [output,impulse,pause2];
    else
        output = [output,impulse,pause3];
    end
end
% 在输出信号前加一段空白，避免播放器在信号刚开始的位置出现失真的情况。
output = [pause3,output,impulse];
% 在figure中画出输出的时域信号
figure(1);
plot(output);
axis([-500 17500 -3 3]);
% 将输出信号写入到音频文件中，需要指明文件名、数据、和采样频率。
audiowrite('message.wav',output,fs);
~~~

​		这里涉及到一个有关扬声器播放声音的问题。有的扬声器在刚打开工作时，其中的电路会经历一个冷启动的过程，因此导致此时播放的声音出现失真的现象。我们可以在音频信号的前面加一段空白信号以跳过这一段冷启动过程。

​		最终生成的输出信号时域信号如图所示，横轴代表采样点的序号，纵轴代表幅度：

<center>
<img src = "./fig/4.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 编码生成的时域信号</div>
</center>

​		得到调制过信息的声音文件后，我们将文件存储在一个android 手机上，并使用一个声音播放器打开此文件进行播放。同时，我们使用另一个设备将声波信号录制下来存储到录音文件“r.wav”中。因为我们这里展示的是简单的调制方式，单个声道录到的数据就足够解码，因此录制声波时采用的单声道录制。

## 解调

​		以下的解调和解码部分写在```decoding.m```这个脚本中。用matlab读取录音文件“r.wav”,并将读出的数据在图中展示出来：

~~~matlab
%% 读取录音文件中的数据
[data, fs] = audioread('r.wav');
figure(1);
plot(data);
hold on;
~~~

<center>
<img src = "./fig/receive_data.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 接收到的声音信号</div>
</center>

​		从上图中可见，经历了扬声器播放、空气传播、麦克风接收的声波信号，和未经传输的信号之间有一定的区别，对应了传输过程中引入的各种噪声。

​		在进行解调之前，我们先来回顾一下脉冲间隔调制的原理。由于脉冲间隔调制使用的是脉冲之间的间隔长短来编码数据，所以解调的关键在于得到每两个相邻脉冲之间的间隔，从而将其转换为对应的二进制数据。要得到脉冲之间的间隔，就需要获取每个脉冲的起始和结束时间。因为每个脉冲的长度是固定的，所以我们只需要知道脉冲的起始位置即可。

​		怎样找到脉冲的起始位置呢？在这个例子中我们采用能量强度阈值的方法。

​		借助傅里叶变换，我们可以获取一段时域信号中某个频率信号的强度。通过把时域信号进行分段的傅里叶变换，每段信号中18 kHz信号的强度都可以被计算出来。由于我们设计的脉冲长度是100个采样点，当我们把傅里叶变换的窗口长度设置为100时，只有窗口从脉冲起始点开始截取信号的时候，才能使得整个时域窗口中都充满18 kHz的声音信号。若是窗口起始点不在脉冲起始的位置，那么时域窗口中将不可避免地包含到一部分空白信号（没有声音信号，采样值接近0）。根据傅里叶变换的原理，频域上的能量强度是时域上对应频率能量的叠加。所以当窗口对齐脉冲起始位置时，傅里叶变换得到的18 kHz​处的能量是最高的。我们可以记录下每个时域窗口对应的18 kHz​的能量强度，通过寻找极大值得到每个脉冲信号的起始位置。

<center>
<img src = "./fig/winding.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 脉冲信号和时域窗口</div>
</center>

​		接下来我们进行解调操作。首先对信号进行滤波，去除掉环境中的噪音，只保留信号调制所用到的$18kHz$的声音信号：

~~~matlab
%% 对录音数据进行滤波
%定义一个带通滤波器
hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,17500,18500,fs),'butter');
%用定义好的带通滤波器对data进行滤波
data = filter(hd,data);
~~~

> 思考：实际上，在脉冲间隔调制中，滤波这一操作不是必须的，你知道是为什么吗？

​		接下来我们对录音信号进行滑动窗口的傅里叶变换，得到每一段数据中18 kHz​信号的强度信息：

~~~matlab
%% 对数据进行带滑动窗口的傅里叶变换。得到每一段数据中18kHz信号的强度信息
f = 18000;                      %目标频率为18kHz
[n,~] = size(data);             %获取数据的长度值
window = 100;                   %设置窗口大小为100个采样点
%定义变量数组impulse_fft，用于存储每个时刻对应的数据段中18kHz信号的强度
impulse_fft = zeros(n,1);	
for i= 1:1:n-window
    %对从当前点开始的window长度的数据进行傅里叶变换
    y = fft(data(i:i+window-1));
    y = abs(y);
    %得到目标频率傅里叶变换结果中对应的index
    index_impulse = round(f/fs*window);
    %考虑到声音通信过程中的频率偏移，我们取以目标频率为中心的5个频率采样点中最大的一个来代表目标频率的强度
    impulse_fft(i)=max(y(index_impulse-2:index_impulse+2));
end
% 在figure中展示每个窗口对应的18kHz信号的强度
figure(2);
plot(impulse_fft);
~~~

​		在下图中展示每个时域窗口的信号对应的18 kHz​信号的强度：

<center>
<img src = "./fig/impulse_fft_raw.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 每个时域窗口对应的18 kHz信号的强度</div>
</center>


​		对局部进行放大，我们可以观察到锯齿形的曲线：

<center>
<img src = "./fig/impulse_fft_raw_zoom.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 时域上的18kHz信号强度的局部放大</div>
</center>

​		我们的目的是通过找极大值准确得到每个脉冲信号的起始位置，然而锯齿形的信号的最大值可能不严格出现在信号峰的中间位置。我们需要通过滑动窗口平均来对impulse_fft进行均值滤波，得到一个平滑的曲线。在这里我们设置一个大小为11的窗口：

~~~matlab
% 滑动平均（均值滤波）
sliding_window = 5;
impulse_fft_tmp = impulse_fft;
for i = 1+sliding_window:1:n-sliding_window
    impulse_fft_tmp(i)=mean(impulse_fft(i-sliding_window:i+sliding_window));
end
impulse_fft = impulse_fft_tmp;
% 在figure中展示平滑后的impulse_fft
figure(2);
plot(impulse_fft);
hold on;
~~~

​		我们可以从下图中看出，均值滤波有效地把锯齿形的信号转化成了相对平滑的信号。对于滑动窗口的大小，可以根据实际需要进行调整。

<center>
<img src = "./fig/impulse_fft_sliding_zoom.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 经过滑动平均的18kHz信号强度的局部放大</div>
</center>

​		由于在实际操作中，我们不能保证经过平滑之后的信号在峰的两侧都是单调的，所以我们用局部最大值来替代极大值来进行判断。通过找到局部最大值得到峰的中间位置，从而得到脉冲信号的起始位置。由于脉冲的长度为100，所以我们再次使用一个长度为100的窗口，这次的窗口是以当前点为窗口的中间，往前后各取半个窗口的长度。当中心点的值是整个窗口中的最大值时，说明左右两侧的点都比中间点的值小，也就是说，当前窗口的中心点是一个峰。为了去除空白数据处的曲线波动对峰值判断的干扰，我们多加了一个对峰的高度的判断，当数据值小于等于$0.3$（阈值）时，无论曲线在此处的走势如何，这里都不会是一个峰。

~~~matlab
% 取出impulse 起始位置（峰的中间位置）
position_impulse=[];    %用于存储峰值的index
half_window = 50;
for i= half_window+1:1:n-half_window
    %进行峰值判断
    if impulse_fft(i)>0.3 && impulse_fft(i)==max(impulse_fft(i-half_window:i+half_window))
        position_impulse=[position_impulse,i];
    end
end
~~~

​		根据我们前面的分析可知，峰值的位置就是脉冲的起始位置。为了验证这个结论，我们把得到的峰值位置在时域信号图中展示出来，并计算相邻两个脉冲之间的间隔：

~~~matlab
%% 在图中表示出脉冲起始位置并计算相邻两个脉冲之间的间隔
[~,N]= size(position_impulse);
%定义变量delta_impulse用于存储相邻两个脉冲之间的间隔
delta_impulse=zeros(1,N-1);
for i = 1:N-1
    %在18kHz信号的强度图中标出脉冲起始位置
    figure(2);
    plot([position_impulse(i),position_impulse(i)],[0,0.8],'m');
    %在时域信号上标出脉冲起始位置
    figure(1);
    plot([position_impulse(i),position_impulse(i)],[0,0.2],'m','linewidth',2);
    %计算两个相邻脉冲之间的间隔。-100是减去脉冲信号长度
    delta_impulse(i) = position_impulse(i+1) -  position_impulse(i) -100;
end
~~~

​		脉冲起始位置在原始时域声音信号上的展示如下图所示。观察发现，代表着我们计算得到的脉冲起始位置的洋红色线条所切割的位置，并不是真正的脉冲信号起始位置。在洋红色线条之前已经有一段的声音信号存在了。

<center>
<img src = "./fig/impulse_position_raw.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 计算得到的脉冲起始在真实时域信号中与脉冲起始不匹配</div>
</center>

​		然而这些洋红色线条在18kHz​强度的时域图中与峰值很好地一一对应，如下图所示。

<center>
<img src = "./fig/impulse_position_fft.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 计算得到的脉冲起始位置和18kHz信号强度峰值整齐对应</div>
</center>

​		也就是说，18 kHz​信号强度的时域图中的峰值并不是出现在脉冲的起始位置。这个结论我们最初的理论分析是不一致的。为了解释这一现象，我们将真实时域信号和分窗口傅里叶变换得到的18 kHz信号强度时域图画在下图中进行观察。我们发现18 kHz信号强度峰值并没有出现在信号起始处，如下图所示：

<center>
<img src = "./fig/raw_and_fft.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 18kHz信号强度峰值并没有出现在信号起始处</div>
</center>

​		这个现象其实是滤波造成的。如果我们把上图中的原始信号替换成滤波之后的信号，就会发现滤波后的每个脉冲的开头和结尾处的信号比中间的弱。这个滤波器特性导致的现象，再加上多径效应造成的回声现象，使得滑动窗口傅里叶变换得到的最大值并不是出现在脉冲的起始位置。

<center>
<img src = "./fig/filter_and_fft.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 18kHz信号强度时域图以及滤波之后的声音信号</div>
</center>

​		如果我们不对信号进行滤波，而是直接用原始的声音数据进行滑动窗口傅里叶变换，得到的结果如下图所示。我们可以看到18 kHz信号强度的峰值确实出现在了声音信号的起始位置，但由于没有进行滤波，原始信号中存在的频率更杂乱，使得我们得到的18 kHz信号强度曲线也更加波折。

<center>
<img src = "./fig/raw_and_fft2.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. 18kHz信号强度峰值出现在了信号起始处</div>
</center>

​		尽管用滤波前的原始数据和滤波后的数据进行滑动窗口傅里叶变换，得到的峰值位置不一致，事实上，这两种方式都可以成功解码出数据。这是因为我们解码数据依靠的是相邻两个脉冲信号之间的间隔，就算识别出来的脉冲信号的绝对位置有偏差，只要每个脉冲信号位置都偏差大致相似的采样点数，相邻两个脉冲信号之间的间隔就是大致不变的。当我们设计编码时，不同码元使用的间隔之间差异足够大，就可以保证解码的准确性。

## 解码

​		接下来我们使用相邻脉冲之间的间隔进行解码。根据我们设计编码时定义的对应规则把不同长度的间隔映射为不同的编码数据。另外，由于噪声等的影响，我们得到的间隔长度不会严格等于设计值。这时就需要我们在解码时加入一定的鲁棒性。在这个实验中，我们认为只要实际间隔值和设计值之间的误差小于10，就解码出对应的数据，否则解码失败。误差的阈值可以根据信道、信号等的实际情况进行设置。

~~~matlab
%% 解码
%由于每个码元对应2bit，所以先把间隔对应到4进制数
decode_message4 = zeros(1,N-1)-1;
for i = 1:N-1
    if delta_impulse(i) - 50 >-10 &&delta_impulse(i) - 50 <10
        decode_message4(i) = 0;
    elseif delta_impulse(i) - 100 >-10 &&delta_impulse(i) - 100 <10
        decode_message4(i) = 1;
    elseif delta_impulse(i) - 150 >-10 &&delta_impulse(i) - 150 <10
        decode_message4(i) = 2;
    elseif delta_impulse(i) - 200 >-10 &&delta_impulse(i) - 200 <10
        decode_message4(i) = 3;
    end
end
% 把四进制转化为二进制
decode_message = zeros(1,(N-1)*2)-1;
for i = 1:N-1
    if decode_message4(i) == 0
        decode_message(i*2-1)=0;
        decode_message(i*2)=0;
    elseif decode_message4(i) == 1
        decode_message(i*2-1)=0;
        decode_message(i*2)=1;
    elseif decode_message4(i) == 2
        decode_message(i*2-1)=1;
        decode_message(i*2)=0;
    elseif decode_message4(i) == 3
        decode_message(i*2-1)=1;
        decode_message(i*2)=1;
    end
end
~~~

​		现在我们解码出了声音信号中编码的二进制串，要将其转化为可解读的信息还需要将二进制串变成字符串。我们实现一个与```string2bin```函数对应的```bin2string```函数来实现这个功能：

~~~matlab
function [ str ] = bin2string( binary )
% 把二进制串转化为字符串
L = length(binary);
str = [];
binary = reshape(binary',[8,L/8]);
binary = binary';
for i=1:L/8
    s= 0;
    for j = 1:8
        s = s+2^(8-j)*binary(i,j);
    end
    str = [str,char(s)];
end
end
~~~

​		最后，调用```bin2string```函数：

~~~matlab
%把二进制数据根据ascii码值解出对应的字符串
str = bin2string(decode_message)
~~~
​		运行整个脚本可以得到可以解码的数据串:

~~~matlab
>> decoding
str=
    'Tsinghua University'
>>
~~~

​		至此，一个简单的无线传输系统就完成了。

> 思考 
> 1. 能量强度阈值的方法在别的调制方法上是否适用？如果环境中存在较强的干扰，使得能量较强的地方很可能是噪声，应该如何检测信号的起始位置？
> 2. 在脉冲间隔调制中，如果有一个脉冲因噪声没能被检测到，则会导致之后所有的脉冲都错位一个，因此解出的二进制串从这一位后全都没有对齐。如何减少这种情况带来的影响？
> 3. 这里用的是脉冲调制的方法，能不能将调制方法换成前面学过的BPSK，QPSK，8PSK，OQPSK，64QAM，OFDM等？