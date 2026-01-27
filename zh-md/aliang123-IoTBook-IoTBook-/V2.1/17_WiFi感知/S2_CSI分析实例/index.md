# 获取及分析CSI信息

按照 https://dhalperi.github.io/linux-80211n-csitool/installation.html 所提供的指导，安装数据记录工具，并使用其提供的matlab函数进行数据获取。我们把数据记录到`csi.dat`文件中，读取并分析数据的样例代码如下：

~~~matlab
csi_trace = read_bf_file('csi.dat');
csi_entry = csi_trace{4};
csi = get_scaled_csi(csi_entry);
% CSI是一个Ntx×Nrx×30 的矩阵，对应了发射天线数x接收天线数x30个子载波的信道信息
figure
plot(db(abs(squeeze(csi(1,:,:)).')))
hold on
plot(db(abs(squeeze(csi(2,:,:)).')))
legend('RX Antenna A', 'RX Antenna B','TX Antenna A', 'TX Antenna B', 'Location', 'SouthEast' );
xlabel('Subcarrier index');
ylabel('SNR [dB]');
~~~

<center>
<img src="./fig/csidata.jpg" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">图. CSI数据转化的SNR值</div>
</center>



例如上图中就展示了2\*2（nTx\*nRx）组天线的CSI数据转化来的SNR结果，其中横轴为30个不同的子载波，纵轴为SNR值的大小。
我们介绍了基础的CSI获取方法，基于这一些获取方法实际上已经可以开展大部分的CSI感知的工作了，大家看到的很多相关的论文都是以此为基础，后面就是对CSI数据的处理和应用，例如利用机器学习的方法进行分类、对CSI数据进行处理减少噪声影响、分离多径的数据等等。 
关于CSI获取和分析的相关工具很多，前一节中我们也给出了相关的参考链接，大家也可以进行参考，最重要的就是基于CSI数据如何进行应用。另外大家也应该想清楚CSI数据的局限性是什么，虽然现在基于CSI应用感知的工作很多，建议大家获取到后结合我们在通信那一部分介绍的CSI的概念思考一下其局限性，然后开展相关应用工作。