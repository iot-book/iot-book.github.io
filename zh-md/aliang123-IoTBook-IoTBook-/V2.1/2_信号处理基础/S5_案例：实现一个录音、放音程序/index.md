# 案例：实现一个录音、放音程序

 	我们来看一个真实的采样和量化的例子，这也是整个数据处理实验的开始。这个实验在手机上就能实现，来看看手机上如何进行声音的采样和量化。

​	在做实验之前，你需要准备好一个手机（安卓和苹果手机都可以），并配置好基本的开发环境，如果你还不太熟悉，网上有很多材料可供参考。

​	录制声音的关键代码如下。仔细看下面代码，虽然我们使用的以声波信号为例展示采样和量化的过程，但是其主要方法和电磁波及其他无线通信是相通的。

```java
//采样率：48KHz
int SamplingRate = 48000;
//量化位数：16Bit
int audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
//声道数：双声道（立体声）
int channelConfiguration = AudioFormat.CHANNEL_IN_STEREO;

//...其他代码...///

public void StartRecord(String name) {
	//...//
  //文件输出流
  OutputStream os = new FileOutputStream(file);
  BufferedOutputStream bos = new BufferedOutputStream(os);
  DataOutputStream dos = new DataOutputStream(bos);

  //获取在当前采样和信道参数下，每次读取到的数据buffer的大小
  bufferSize = AudioRecord.getMinBufferSize(SamplingRate, channelConfiguration, audioEncoding);
  //建立audioRecord实例，思考一下里面各个参数的意义
  AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SamplingRate, channelConfiguration, audioEncoding, bufferSize);

  //设置用来承接从audiorecord实例中获取的原始数据的数组
  byte[] buffer = new byte[bufferSize];
  //启动audioRecord
  audioRecord.startRecording();

  //设置正在录音的参数isRecording为true
  isRecording = true;
  //只要isRecording为true就一直从audioRecord读出数据，并写入文件输出流。
  //当停止按钮被按下，isRecording会变为false，循环停止
  while (isRecording) {
      int bufferReadResult = audioRecord.read(buffer, 0, bufferSize);
      for (int i = 0; i < bufferReadResult; i++) {
              dos.write(buffer[i]);
      }
  }
  //停止audioRecord，关闭输出流
  audioRecord.stop();
  dos.close();
  //...//
}
```

​	上面的代码表示了一个如下的过程：

​	首先有一个ADC不断的将声音信号转化成为数字信号（因此采样量化过程由硬件已经完成了，这里的代码可以不用考虑这一点；如果真的要做通信前端了，这部分才需要考虑），这个数字信号是存储在一个缓冲区（buffer）里面的，需要我们从buffer中将数据不断读取出来，然后保存成一定格式的声音信号。

​	这个过程类似网络的数据处理。网络数据首先通过网卡的处理，网卡有一个很重要的功能就是将物理信号转化为数字信号。回忆一下在网络编程中（如果还没有实践过，就想象一下实际电脑上网络传输的实现），我们也是需要将收到的数据从某一个buffer中读取出来。

​	进一步来看，如何处理这个buffer中的数据也是有不同的手段的，第一种是轮询，简单的说就是不断地去看buffer中是否有数据；第二种是中断，一旦有数据到来，就会产生一个中断通知进行数据处理。这两种处理方法都可以实现非阻塞模式，即用户无需在这个地方等待buffer内容。还有一种是阻塞模式，用户需要等待buffer内容，当buffer中有数据时才能够继续往下处理。上述的几种模式各有优缺点，如何选择合理的模式，这是通信和与硬件打交道的数据处理中经常要面临的问题。如果数据处理不及时，数据就会被覆盖导致丢失，这个问题在网络传输中也会遇到。
​	将数据读取出来之后，我们就有了采样和量化过后的数据，这才是真实计算机能够处理的数据，注意原始的声音我们是保存不下来的。

​	另外我们还想通过这一部分代码介绍几个重要概念，这也是平时大家在网络学习的过程中容易忽视的概念，因为之前网络学习中接触最底层基础的信号处理较少。在启动录音的过程中，需要设置几个参数，第一个就是采样率，目前设置的是$48 KHz$（到前面看看这个采样率对实际恢复数据的影响，就理解为什么这个参数很重要了），如果原始声音信号的频率是小于$24 KHz$的，那么$48 KHz$的采样率是能够完全还原出原始的声音信号的，这个采样率能够将人耳能听到的声音和人说话的声音录下来（思考一下人耳能听到的声音和人说话的声音大概的频率范围应该是多少）。第二个是量化位数，这里设置的是16位，即每一个采样点用16bit来量化（思考这能将声音量化成多少种取值）。第三个是声道数量，目前选择的是双声道，即有两路数据。

​	如果我们有一个音频文件，这个音频文件可以是通过程序录制得到的，也可以是使用代码生成的，就可以在手机上播放出来。播放声音的关键代码如下：

```java
public void StartPlay(String name) {
//...//
  //文件输入流
	InputStream is = new FileInputStream(file);
  //如果要播放wav格式的文件，需要跳过44字节的文件头，后面的内容才是音频
	is.skip(44);
  //获取在当前采样和信道参数下，每次读取到的数据buffer的大小
  int bufferSize = AudioTrack.getMinBufferSize(SamplingRate,
                channelConfiguration, audioEncoding);
  //建立audioTrack实例
  AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, SamplingRate, channelConfiguration, audioEncoding, bufferSize, AudioTrack.MODE_STREAM);
  //设置一个数组，用来承接从音频文件中获取的音频数据
	byte[] buffer = new byte[bufferSize];
	int readCount;
	while (is.available() > 0 && isPlaying) {
    //从文件中读取一段音频数据
    readCount = is.read(buffer);
    if (readCount == AudioTrack.ERROR_INVALID_OPERATION || readCount == AudioTrack.ERROR_BAD_VALUE) {
      continue;
    }
    if (readCount > 0) {
      //如果读取的音频数据有效，就将数据写入audioTrack并进行播放
      audioTrack.write(buffer, 0, readCount);
      audioTrack.play();
    }
  }
  //停止播放，关闭输入流
  is.close();
  audioTrack.stop();
  //...//
}
```

​	在播放声音时，我们仍然需要指定采样率、量化位数、声道数这些参数，并且这些参数要与生成音频文件时使用的参数相同，才能将音频正常播放出来（思考为什么需要指定这些参数）。注意，上述的整个过程，在正常的无线通信的过程中也都存在，但是大家通常都接触不到，希望大家通过这个直观的例子，理解通信中采样和量化的第一步。

> 大家思考并尝试一下，如果在生成音频时使用的是$48 KHz$采样率，而在播放时使用$24 KHz$采样率，播放出来的声音会是什么效果？同样也可以尝试不同的量化位数或者声道数的组合，并解释播放出来的声音和原本正常的声音不同的原因，就可以对信号的接收、生成等过程有更加深入的了解。

