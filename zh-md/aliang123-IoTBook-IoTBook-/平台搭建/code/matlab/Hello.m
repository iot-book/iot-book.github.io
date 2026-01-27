%从录音文件receive.wav中读取数据和采样频率
[data, fs] = audioread('receive.wav');
%把数据展示到figure中
figure;
plot(data);