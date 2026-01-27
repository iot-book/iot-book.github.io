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
[corr,lags] = xcorr(x,y);

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


