% 读入音频文件
[data,fs] = audioread('record.wav');
% 提取第一个声道
data=data(:,1);
% 将数据转化为行向量
data=data.';

% 使用带通滤波器滤波去噪
bp_filter = design(fdesign.bandpass('N,F3dB1,F3dB2',6,20800,21200,fs),'butter');
data = filter(bp_filter,data);

%% 计算相位变化
f0=21000;
c=340;
time = length(data) /fs;
t=0:1/fs:time-1/fs;
% 将正弦和余弦信号分别和原信号相乘
cos_wave = cos(2*pi*f0*t);
sin_wave = sin(2*pi*f0*t);
r1=data.*cos_wave;
r2=data.*sin_wave;

% 将所得信号通过低通滤波器，得到I路和Q路信号
lp_filter = design(fdesign.lowpass('N,F3dB',6,200,fs),'butter');
I = filter(lp_filter,r1);
Q = filter(lp_filter,r2);

% 计算反正切得到相位
phase=atan(Q./I);

%% 利用相位变化计算距离变化
% 消除反正切引起的相位跳变
phase = phase / pi;
p_difference = phase(2:length(phase))-phase(1:length(phase)-1);

bias =0;
for i = 1:length(p_difference)
    if p_difference(i)>0.2
        bias=bias-1;
    end
    if p_difference(i)<-0.2
        bias=bias+1;
    end
    phase(i+1)=phase(i+1)+bias;
end
phase = phase * pi;
distance = phase /(2*pi*f0) *c;

plot(t,distance);
title('基于相位的追踪(LLAP)');
xlabel('时间(s)');
ylabel('距离(m)');
