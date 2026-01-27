% 读入音频文件
[data,fs] = audioread('record.wav');
% 提取第一个声道
data=data(:,1);
% 将数据转化为行向量
data=data.';

% 使用带通滤波器滤波去噪
bp_filter = design(fdesign.bandpass('N,F3dB1,F3dB2',6,20800,21200,fs),'butter');
data = filter(bp_filter,data);

%% 使用STFT计算频率偏移
% 窗口大小1024个采样点
slice_len = 1024;
slice_num = floor(length(data)/slice_len);
delta_t = slice_len/fs;

% 每个时间窗口的信号频率
slice_f=zeros(1,slice_num);
% 在fft时补256倍的0，提高fft分辨率
fft_len = 1024*256;
for i = 0:1:slice_num-1
    %对每个窗口进行fft，取频率谱的峰值频率作为该时间窗口的信号频率
    fft_out = abs(fft(data(i*slice_len+1:i*slice_len+slice_len),fft_len));
    [~, idx] = max(abs(fft_out(1:round(fft_len/2))));
    slice_f(i+1) = (idx/fft_len)*fs;
end

%% 计算距离变化
f0=21000;
c=340;

%起始位置坐标为0
position=0;
distance=zeros(0,slice_num);
v = (slice_f-f0)/f0*c;
for i = 1:slice_num
    %把一段时间窗口内的移动当作匀速运动
    %由于速度方向取靠近声源为正，计算距离时应使用减法
    position = position - v(i)*delta_t;
    distance(i) = position;
end

time = 1:slice_num;
time = time*delta_t;
plot(time,distance);
title('基于多普勒效应的追踪');
xlabel('时间(s)');
ylabel('距离(m)');
