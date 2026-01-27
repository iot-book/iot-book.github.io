# RFID

RFID（ **R**adio  **F**requency  **ID**entification，射频识别）顾名思义，就是使用射频技术进行识别的技术。具体来说，RFID技术使用RFID阅读器(Reader)通过射频信号对RFID标签(Tag)进行非接触式信息传输，并且通过所传输的信息，RFID reader可以识别被嵌入RFID tag的物品的身份信息。

一个RFID系统主要由标签、天线、阅读器（阅读器通常集成了传送器、接收器和微处理器）构成。每个RFID标签内部存有唯一的电子编码，用来标识目标对象。标签进入RFID阅读器扫描区以后，接收到阅读器发出的射频信号，凭借感应电流获得的能量发送出存储在芯片中的编号。基于backscatter原理，RFID标签能够在收到射频信号后将要发送的数据加载在反射信号上发出来。

RFID标签结构简单，体积小，无需任何电池进行供电，可以嵌入到不同形状和不同类型的物品中，适用范围广泛，所呈现出的形态有标签、卡片、纽扣等。数以亿计的RFID标签广泛用于库存管理、智能物流、资产跟踪、室内定位等场景中。

## RFID协议标准

RFID的标准主要包括物理特性、空中接口规范、编码规则、读写器协议、测试应用规范、信息安全协议等。目前，全球RFID标准制定者主要为分别是ISO/IEC和EPCGlobal。下面，我们将以EPC Global Class1 Gen2标准为例，介绍RFID物理层和MAC层的简要知识。

RFID阅读器使用PIE（脉冲间隔编码）与ASK（振幅键控）向标签发送Query等命令。脉冲间隔编码（回顾前面章节的知识）的“0”是短暂的高电平跟随短暂的低电平，而“1”是长时间的高电平跟随短暂的低电平。RFID标签使用包络检测器可以得到高低电平交替的基带信号，并判断高电平的持续时间就可接收到RFID阅读器发送到的指令。接着RFID阅读器发出单频连续波 ( **C**ontinuous  **W**ave, CW)，CW既作为供给标签的无线电源，又作为标签产生的基带信号的载波。

<center>
<img src="./fig/PIE.png" width=450px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. PIE编码</div>
</center>

标签使用FM0编码与ASK调制将数据搭载到阅读器发出的CW上。FM0在每个新符号开始时做一次反相（1→0/0→1)，编码“0”时，在符号中间做一次反相，编码“1”时，符号在整个传输过程中保持不变。在进行ASK调制时，标签使用阅读器发出的CW作为载波，无法主动控制信号的电平，因此标签控制其天线在完全吸收/完全反射两种状态中切换，因此反射出去的信号就在最小/最大振幅之间切换。反射信号的振幅就搭载了标签的基带信号。由于标签仅仅需要控制一个射频开关，能耗非常低，从CW获取的感应电流就可以为其提供能量。

<center>
<img src="./fig/FM0.png" width=450px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. FM0编码</div>
</center>

为了防止标签之间的碰撞，RFID使用了基于时隙ALOHA的MAC层协议。假设有若干个标签进入了某个阅读器的读取范围，其基本的流程如下：

* 阅读器发送查询Query指令，其中，包含了参数 **Q**（默认为4）。并且阅读器和所有标签同时开始计时
* 标签在接收到Query指令后，首先随机选择一个16位的数字 **handle** ，接着在$[0,...,2^{Q}-1]$ 之间随机选择一个值 **slot_time** 
* 如果 **slot_time** **=0**，标签立刻回复其随机选择的 **handle** ；如果 **slot_time** **!=0** ，则标签等到计时器运行到 **slot_time** 再回复 **handle** 
* 在经过$2^{Q}$个时间片（slot）后，如果reader统计每个时间片收到的 **handle** ，对那些没有发生冲突的 **handle** ，依次发送 **ACK_handle** 。在向某个标签发送 **ACK_handle** 后，该tag返回其需要发送的数据，例如EPC编号，其余的标签等待，直到收到阅读器发来相应的 **ACK_handle** 

## 可计算RFID——WISP

传统的RFID标签仅仅能发送其编号信息，为了使得RFID标签进行更加复杂的计算、甚至环境感知任务，研究人员提出了可计算RFID的概念。其中，最为知名的是英特尔公司与华盛顿大学联合启动的一个名为：Wireless Identification and Sensing Platform (WISP)的项目。WISP标签无需专用电池，与商用RFID阅读器兼容，搭载了一个超低功耗微控制器。开发人员可以根据不同的任务需求，通过编写固件让WISP标签完成一些传统RFID标签无法实现的复杂运算。同时WISP上集成了温度、加速度等传感器，能够对周围的环境进行感知。

<center>
<img src="./fig/WISP.png" width=450px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. WISP标签</div>
</center>

为了在WISP上进行RFID相关的实验和应用，你需要如下工具：WISP标签本身和阅读器（Impinj R420、Impinj R1000）；MSP-FET430UIF调试工具；Code Composer Studio (CCS) 集成开发环境 。在获取了相应的工具后，使用WISP大致有如下几个步骤：1）从[这个链接](https://github.com/ransford/sllurp)获取官方的WISP固件（该固件包含了RFID C1G2协议控制和处理的功能；2）将WISP与MSP-FET430UIF调试工具相连，在CCS中对WISP的固件进行开发；3）RFID阅读器硬件配置，包括天线、网络、电源等；4）通过sllurp（WISP官方推荐的一个Python库）或Impinj公司的ItemTest应用程序对RFID reader进行软件配置并进行读取测试。

如果读者对使用WISP进行可计算RFID的开发有进一步的兴趣，可以访问[WISP的Wiki](https://sites.google.com/uw.edu/wisp-wiki/home)获取详细信息。

