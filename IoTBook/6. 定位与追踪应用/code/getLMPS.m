function [ lmps ] = getLMPS( y )  %输入是窗口信号的强度，输出的该窗口信号的lmps
lmp = 0; 
lmps = 0;
for i=2:length(y)-1   %计算除首尾的采样点的lmp
    if y(i)>y(i-1) && y(i)>y(i+1)
        lmp = lmp + 1;
    end  %如果该采样点是局部最大值，则lmp+1
    lmps = lmps +lmp;  %lmps是所有采样点的lmp的和
end
lmps = lmps + lmp;   %最后一个采样点的lmp一定与倒数第二个相同

