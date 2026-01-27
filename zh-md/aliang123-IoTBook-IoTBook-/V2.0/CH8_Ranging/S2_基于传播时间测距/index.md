# 基于信号传播时间测距

## 信号传播时间

飞行时间（TOF，Time of Flight），指信号在介质内传播时间。已知信号在介质中传播速度的情况下，使用飞行时间可以估算出信号经过的距离。

发送端和接收端的精确时间同步，是测量信号飞行时间的前提。因此如何解决时钟同步问题，是飞行时间测距工作的一个重点，也是难点。传统网络工作中提出了多种网络时间同步机制，例如网络时间协议（Network Time Protocol, NTP)，它也是互联网的时间同步机制。此外，GPS技术也能为不同设备提供全局时间同步，它的原理是在GPS卫星上运行一个高精度的铯原子钟，GPS客户机通过接收卫星发送的伪随机序列，实现与卫星时钟的同步。

现有的时间同步方法在实际使用中仍存在较大的局限性。例如NTP协议主要针对静态网络，并且需要频繁交换消息来不断校准时钟频率偏移带来的误差。此外，NTP协议通常只能达到毫秒级的精度，因此无法满足高精度测距等应用场景的需求。GPS能使设备以纳秒级精度与世界标准时间UTC同步，但GPS受环境遮挡影响大，只适用于室外空旷无遮挡的环境。且GPS设备成本昂贵，功耗也较大，因此无法适用于低功耗物联网节点。

在发送端和接收端时间同步的前提下，接收端就可以记录发送端在哪一时刻开始传输；随后，在收到信号的第一时间，接收端记录信号到达时刻的时间戳；最后，利用接收时间戳减去发送时刻即可得到信号飞行时间。


本章我们将会介绍多个在实际系统中利用ToF进行测距和定位的案例。

## ToF测距
使用$d$表示发送端到接收端的距离，$c$表示信号的传播速度（例如声速），$t$表示测量得到的飞行时间，那么可以得到：

$$
	d = c\times t
$$

这一方法要求能准确获知信号发送时间，即要求发送端和接收端之间进行严格的时间同步。

**利用信号反射实现**

由于直接TOA测距，同步发送端和接收端时间存在困难，因此有方法提出令接收端和发送段为同一设备，从而在计算飞行时间时避免收发机的时间同步。

一种常见的做法是令测距对象作为反射体，直接反射传输的信号。这种方法要求反射体具有一定的体积，并且收发机能在全双工模式工作，即发送信号的同时能接收来自目标对象反射的信号。

令一种方法是利用两个设备分别作为发送端和接收端：发送端于时刻$𝑡_0$发送信号，接收端收到信号后，等待时间$\Delta 𝑡$后返回同样的波，发送端记录收到回复的时刻$𝑡_1$，从而得到距离距离：$𝑑=(𝑣(t_1-t_0-\Delta t))/2$。这种方法既不要求接收端和发送端时钟同步，也不需要设备具有全双工功能。但实际实现时，由于设备软硬件调度、延迟等不确定因素，接收端很难控制等待时间恰好为$\Delta t$，因此实际测得的距离也存在较大误差。

**利用波速差实现**

考虑到发送端和接收端时钟不同步问题带来的飞行时间误差，有研究工作提出通过利用波速差解决同步问题。

一个很简单的例子是，我们可以令发送端同时发送一道电磁波和声波，然后在接收端记录电磁波的到达时刻$𝑡_𝑟$和声波到达时刻$𝑡_𝑠$。则根据这两个不同的到达时刻，可以计算出发送端与接收端之间的距离：

$$
d = \frac{v_r\times v_s \times(t_s-t_r)}{v_r-v_s}
$$

由于$𝑣_𝑟=3\times 10^8 m/s$远大于$𝑣_𝑠=340m/s$，因此距离计算式可简化为：$𝑑=𝑣_𝑠\times (𝑡_𝑠-𝑡_𝑟)$


## BeepBeep测距

2007年的SenSys上提出了一种基于声波信号传播时间的测距方法。待测距的两台设备均需要具有扬声器和麦克风，如下图所示：

<center>
<img src="./fig/device.png" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. BeepBeep测距示意图</div>
</center>
​
设备$A$和$B$都需要发送和接收声波。每台设备不仅接收另一台设备发来的声波，同时也接收该设备本身发送的声波。BeepBeep的测距原理如下：

<center>
<img src="./fig/ranging.png" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. BeepBeep测距原理图</div>
</center>

上图中有表示设备$A$ ($M_A$)和设备$B$($M_B$)的两条箭头，代表两台设备的时间线，从左到右按时间顺序进行对应的操作，步骤如下：

1. $t^*_{A0}$时刻，设备$A$在应用程序中执行播放声音的命令，但由于软硬件调度等因素，设备A真实播放声音的起始时刻为$t_{A0}$，相对于$t^*_{A0}$时刻有一个延迟。

2. 设备$A$会在自身的麦克风上收到自己播放的声音，声音实际到达设备$A$麦克风的时刻为$t_{A1}$，但由于软硬件调度等因素，设备$A$在应用程序中收到声音的时刻会滞后一段时间，在$t^*_{A1}$时刻应用程序才开始接收声音。

3. 设备$B$也会收到设备$A$播放的声音，并且和设备$A$类似，声音实际到达设备$B$麦克风的时刻为$t_{B1}$，而设备$B$的应用程序开始接收声音的时刻为$t^*_{B1}$。

4. 设备$B$接收设备$A$发送的声音后，在$t^∗_{B2}$时刻执行发送声音的指令，和设备A类似，声音实际播放的时刻为$t_{B2}$。

5. 在$t_{B3}$时刻设备$B$发送的声音到达自身的麦克风，但在应用程序中开始收到声音的时刻为$t^∗_{B3}$。

6. 在$t_{A3}$时刻设备B发送的声音到达设备A的麦克风，但在应用程序中设备A开始收到声音的时刻为$t^∗_{A3}$。

有了上述的时刻，我们可以推导出两台设备之间的距离和各个时刻之间的公式。设声速为$c$，定义$d_{X,Y}$为设备$X$的扬声器到设备$Y$麦克风距离，例如$d_{A,B}$为设备$A$的扬声器到设备$B$的麦克风的距离，$d_{A,A}$为设备A的扬声器到自己的麦克风的距离，则有：

$$
d_{A,A}=c(t_{A1}-t_{A0}), d_{A,B}=c(t_{B1}-t_{A0}), d_{B,A}=c(t_{A3}-t_{B2}), d_{B,B}=c(t_{B3}-t_{B2})
$$

设备$A$和$B$的间距$D$可以表示为：

$$
D = \frac{1}{2}(d_{A,B}+d_{B,A})
$$

​		化简后有：

$$
D = \frac{𝑐}{2}[(𝑡_{𝐴3}−𝑡_{𝐴1})-(𝑡_{𝐵3}−𝑡_{𝐵1})]+𝑑_{𝐴,𝐴}+𝑑_{𝐵,𝐵}
$$

​其中$𝑑_{𝐴,𝐴}$和$𝑑_{𝐵,𝐵}$都和设备本身的设计有关，可以在测距之前提前测量得到。因此测距结果只和两个时间差$𝑡_{𝐴3}−𝑡_{𝐴1}$和$𝑡_{𝐵3}−𝑡_{𝐵1}$有关，并且两个时间差可以分别在设备$A$和设备$B$上测量出来，而不需要设备$A$和设备$B$进行时钟对齐。

​以设备$A$为例，设备$A$在测距过程中保持麦克风打开，在接收到的声音信号中，我们需要找到设备$A$自己发送的声音被接收到的时刻$𝑡^*_{𝐴1}$，和设备$B$发送的声音被接收到的时刻$𝑡^*_{𝐴3}$，然后用$t^*_{𝐴3}−𝑡^*_{𝐴1}$来近似$𝑡_{𝐴3}−𝑡_{𝐴1}$。

​这样，两台设备之间的测距问题就转化成了测量接收信号起始位置的问题。

## BeepBeep手机测距实现

​在该代码示例中，我们采用两台电脑作为测距设备，使用`Matlab`编写代码。为了能够把设备$B$测量的时间差传回设备$A$以进行距离计算，代码在设备$A$和$B$之间建立了TCP连接，通过局域网进行数据传输。在这里，设备$A$作为TCP连接的服务端，设备$B$作为客户端。

设备$A$：

```matlab
%%
% TCP连接，IP地址和端口可以自己设置，只需保证设备A和设备B一致即可
IP = '0.0.0.0';
PortN = 20000;

%设备A发送调频连续波信号(chirp)，频率从4000Hz变化到6000Hz，持续0.5秒
fs = 48000;
T = 0.5;
f1 = 4000; f2 = 6000; f3 = 8000;
t = linspace(0, T, fs * T);
y = chirp(t, f1, T, f2);
%%
% 启动TCP连接的服务端
Server = tcpip(IP, PortN, 'NetworkRole', 'server');
fopen(Server);
%%
Rec = audiorecorder(fs, 16, 1);
fprintf(Server, 'Server Ready'); 	%服务端发送消息给客户端，设备A准备开始发送声波
rdy = fgetl(Server);							%服务端收到客户端准备就绪的消息
record(Rec, T * 6);								%设备A开始录音
soundsc(y, fs, 16);								%设备A发送声音
pause(T * 6);											%等待录音结束
%%
recvData = getaudiodata(Rec)';
spectrogram(recvData, 128, 120, 128, fs);

%找到信号起始位置
z1 = chirp(t, f1, T, f2); z1 = z1(end : -1 : 1);
z2 = chirp(t, f2, T, f3); z2 = z2(end : -1 : 1);
[~, p1] = max(conv(recvData, z1, 'valid'));
[~, p2] = max(conv(recvData, z2, 'valid'));

%从频谱图中可以比对找到的信号开始位置是否准确
p1 = (p1 - 1) / fs;
p2 = (p2 - 1) / fs;
hold on;
plot([0, fs / 1000 / 2], [p1, p1], 'r-');
plot([0, fs / 1000 / 2], [p2, p2], 'b-');

%从客户端处收到设备B计算的信号起始位置差，转换成时间差
psub = fgetl(Server);
psub = str2double(psub) / fs;

%声速取343m/s，设备A和设备B自身的麦克风与扬声器间距取值20cm
dAA = 0.2;
dBB = 0.2;
fprintf('Result: %f\n', 343 / 2 * (p2 - p1 - psub) + dAA + dBB);

%%
fclose(Server);
```

设备$B$

```matlab
%%
% TCP连接，IP地址和端口可以自己设置，只需保证设备A和设备B一致即可
IP = '0.0.0.0';
PortN = 20000;

%设备B发送调频连续波信号(chirp)，频率从6000Hz变化到8000Hz，持续0.5秒
fs = 48000;
T = 0.5;
f1 = 4000; f2 = 6000; f3 = 8000;
t = linspace(0, T, fs * T);
y = chirp(t, f2, T, f3);
%%
% 启动TCP连接的客户端
Client = tcpip(IP, PortN, 'NetworkRole', 'client');
fopen(Client);
%%
Rec = audiorecorder(fs, 16, 1);
rdy = fgetl(Client);							%客户端收到服务端准备就绪的消息
fprintf(Client, 'Client Ready');	%客户端发送消息给服务端，设备B准备开始发送声波
record(Rec, T * 6);								%设备B开始录音
pause(T * 3);											%接收设备A发送的声音
soundsc(y, fs, 16);								%设备B发送声音
pause(T * 3);											%等待录音结束
%%
recvData = getaudiodata(Rec)';
spectrogram(recvData, 128, 120, 128, fs);

%找到信号起始位置
z1 = chirp(t, f1, T, f2); z1 = z1(end : -1 : 1);
z2 = chirp(t, f2, T, f3); z2 = z2(end : -1 : 1);
[~, p1] = max(conv(recvData, z1, 'valid'));
[~, p2] = max(conv(recvData, z2, 'valid'));

%将计算的信号起始位置差发送给服务端
psub = num2str(p2 - p1);
fprintf(Client, psub);

%从频谱图中可以比对找到的信号开始位置是否准确
p1 = (p1 - 1) / fs;
p2 = (p2 - 1) / fs;
hold on;
plot([0, fs / 1000 / 2], [p1, p1], 'r-');
plot([0, fs / 1000 / 2], [p2, p2], 'b-');
%%
fclose(Client);
```

> **思考**
> 1. BeepBeep的设计消除了哪些软/硬件带来的误差？哪些误差还没有消除？
> 2. 如果要缩短一次测距所花费的时间，有哪些可能的改进方向？提示：是否一定要等到接收完设备$A$发送的声波，设备$B$才能播放声波？

## WiFi ToF的测距方法
最新的WiFi支持ToF进行测距。WiFi ToF通过测量无线AP (`Responder`)与基站 (`Initiator`)之间的信号的往返时间来对距离进行估计。在IEEE 802.11mc修正案中，WiFi Fine Time Measurement（WiFi FTM）协议被提出，用以实现较高精度的基于WiFi的定位。

**协议原理**

由于基站与AP之间的时间无法做到纳秒级的时间同步，单程的信号在发射端与接收端之间的时间戳的差并不能够反映准确的信号传播时间。而利用双向单边测距的原理即可在基站与AP之间完成往返时间的测量。测量的具体过程如下：

基站首先向AP端发送一个FTM请求（FTM request），接下来AP端会向`Initiator`端回复进行确认，并发送正式的FTM帧，其中FTM帧在AP端的天线上的发送时间为$t_1$，在基站端的接收时间为$t_2$，基站在接收到FTM帧后也会立即回复，并记录发送的时间$t_3$，这次回复在AP端被接收到的时间是$t_4$

<center>
    <img src="./fig/ftm-1.jpg" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">FTM测距原理1 图片来源：<a href="#refer-1">[1]</a></div>
</center>



根据双向单边测距的原理，距离$D$可以由以下公式给出，其中$c$是光速。

$$
2*D = ((t_4-t_1)-(t_3-t_2))*c
$$

<center>
    <img src="./fig/ftm-2.jpg" width=600px>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">FTM测距原理2 图片来源：<a href="#refer-1">[1]</a></div>
</center>



在实际的FTM协议中，FTM帧会重复的出现在一个`burst`的周期内，利用多次测量的平均值来对测距误差进行降低。
在FTM协议中，只有`Initiator`端可以获取距离信息，这是因为在一次`burst`请求中，第N+1次FTM帧（由AP发往基站端）中会携带有上一次FTM应答的$t_1$以及$t_4$信息。这就意味着N+1次FTM应答只能获取N个距离值，并且只有在基站端才能获取完整的$t_1$到$t_4$的时间戳信息。

## 如何进行FTM测量
在较新的Linux内核及版本>9.0的Android系统上，都已经完善了对于FTM协议的支持。

**Android端FTM协议测量**
1. FTM协议必须基于特定的硬件平台实现，目前支持的设备可以参见Google的[开发者文档](https://developer.android.com/guide/topics/connectivity/wifi-rtt#supported-phones)
2. 需要获取以下权限
~~~xml
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
~~~
3. 必须从已扫描获取的WiFi列表中构建测距请求

相关样例代码如下
~~~java
/*
* 检测设备是否支持WIFI RTT
*/
if (getPackageManager().hasSystemFeature(PackageManager.FEATURE_WIFI_RTT)) {
    // 设备具有WIFI RTT支持
} else {
    // 设备不具有WIFI RTT支持
}
// 构建测距请求
RangingRequest.Builder builder = new RangingRequest.Builder();
builder.addAccessPoints(ftmAPs);
RangingRequest req = builder.build();
Executor executor = new DirectExecutor();
wifiRttManager.startRanging(req, executor, new RangingResultCallback() {
    @Override
    public void onRangingFailure(int code) {
        Log.d("onRangingFailure", "Fail in ranging:" + Integer.toString(code));
        runOnUiThread(() -> {
            Toast.makeText(MainActivity.this, "测距请求失败", Toast.LENGTH_SHORT).show();
        });

    }

    @Override
    public void onRangingResults(List<RangingResult> results) {
        Log.d("onRangingResults", "Success in ranging:");
        // 处理数据

    }
});

~~~

**Linux端FTM协议测量**

对于Linux Kernal在5.4及以上的系统，直接安装最新版本的`iw`及`hostapd`工具，以及较新的Intel无线网卡（如AX200、AX201），即可搭建测距测试平台。

执行测距需要设置`Responder`端 (AP)与`Initiator`端 (phone)，下面给出如何进行测距的操作说明：

**`Responder`端**

首先创建配置文件`hostapd.conf`。

```bash
# 改成机器上的网卡接口名称
interface=wlp2s0
driver=nl80211
# 改成网卡的MAC地址
bssid=c8:58:c0:a6:67:bf
# 改一个合适的SSID
ssid=FTM-TEST
hw_mode=g
ieee80211n=1
ht_capab=[HT40+][SHORT-GI-40]
channel=2
wmm_enabled=1
wme_enabled=1
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
ftm_`Responder`=1
ftm_`Initiator`=1
```

启动 AP

```bash
sudo hostapd <配置文件路径>
```

若无法启动，可以尝试重启网卡：

```bash
sudo nmcli radio wifi off
sudo rfkill unblock wlan
sudo ifconfig wlp2s0 up # 改成当前的网卡接口名称
```

**`Initiator`端**

使用`iw`工具扫描 AP列表，获取支持FTM协议的AP：

```bash
sudo iw dev <interface> scan > scan.txt # 输出到文件
```
在扫描结果的文件中搜索 `FTM`，找到支持FTM的 Wifi，记下 `MAC 地址` 和中心频率`freq`。例如（已省略部分信息）：

```
BSS 20:16:b9:70:8a:91(on wlp4s0)
	freq: 2417
	SSID: FTM-TEST-2
	Extended capabilities:
		 * FTM `Responder`
		 * FTM `Initiator`
```


创建配置文件，配置文件中，一行代表一个 `Responder`，其格式如下：

```
<addr> bw=<[20|40|80|80+80|160]> cf=<center_freq> [cf1=<center_freq1>] [cf2=<center_freq2>] [ftms_per_burst=<samples per burst>] [asap] [bursts_exp=<num of bursts exponent>] [burst_period=<burst period>] [retries=<num of retries>] [burst_duration=<burst duration>] [tb]
```

执行测距：
```bash
sudo iw <interface> measurement ftm_request <配置文件路径>
```
## 参考文献
1. [How To Achieve 1 Meter Accuracy In Android](http://gpsworld.com/how-to-achieve-1-meter-accuracy-in-android) <div id="refer-1"></div>
2. Peng, Chunyi & Shen, Guobin & Zhang, Yongguang & Li, Yanlin & Tan, Kun. (2007). BeepBeep: A high accuracy acoustic ranging system using COTS mobile devices. SenSys. 1-14. 10.1145/1322263.1322265. 