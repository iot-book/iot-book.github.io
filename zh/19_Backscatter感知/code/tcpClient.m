function [t, TM] = tcpClient()
close all;
portNum = 20000;
global lmd
lmd = 299792458 / 920.625 / 1e6;
%%
t = tcpip('localhost', portNum, 'NetworkRole', 'client');
t.BytesAvailableFcnMode = 'terminator';
t.Terminator = 'LF';
t.BytesAvailableFcn = @(a, b) recvData(a, b, t);
%%
d = get(t, 'UserData');
axes('Position', [0 0 1 1], 'Visible', 'off');
d.axes_handle = axes('Position', [.15 .1 .8 .8]);
d.line_handle = plot(0, 0, 'LineWidth', 2);
d.maxWindowSize = 500;
xlim([0, d.maxWindowSize]);
yMin = -1; yMax = 2.0;
ylim([yMin, yMax]);
ylabel('Position(m)');
set(gca, 'YTick', yMin:0.1:yMax);
set(gca, 'FontSize', 20);
set(gcf, 'position', [0, 0, 900, 700]);
set(t, 'UserData', d); 
%% Smooth timer
period = 0.005;
TM = timer('StartDelay', 1, 'Period', period, ...
              'ExecutionMode', 'fixedRate');
TM.TimerFcn = {@updateFigure};
set(TM, 'UserData', d);
%%
fopen(t);
%start(TM);
%fclose(t)
end

function recvData(~, ~, t) %obj, EventData, t

tmp = fscanf(t, '%s');
curData = textscan(tmp, '%.d64%d%.1f%f', 'Delimiter', ',');
%curTime = EventData.Data.AbsTime;
drawTrace(t, curData{1}, curData{4});

end

function updateFigure(obj, ~)

TM = get(obj, 'UserData');
x = get(TM.line_handle, 'XData');
y = get(TM.line_handle, 'YData');
if length(x) < TM.maxWindowSize
    x = [x, x(end) + 1];
    y = [y, y(end)];
else
    y = [y(2 : end), y(end)];
end
set(gcf, 'CurrentAxes', TM.axes_handle);
set(TM.line_handle, 'XData', x, 'YData', y);
end

function drawTrace(obj, curTagTime, curPhase)
global lmd
if isnan(curTagTime) || isnan(curPhase)
    return
end
d = get(obj, 'UserData');
y = get(d.line_handle, 'YData');

if ~isempty(y)
    curPhase = NextPhase(y(end), curPhase);
end

curP = curPhase / (4 * pi) * lmd;

if length(y) < d.maxWindowSize
    y = [y, curP];
else
    y = [y(2 : end), curP];
end

set(gcf, 'CurrentAxes', d.axes_handle);
set(d.line_handle, 'XData', 1:length(y), 'YData', y);
end

function Npha = NextPhase(lastPhase, curPhase)
global lmd
lastPhase = lastPhase / lmd * (4 * pi);

rndPhase = mod(lastPhase, 2 * pi);
if curPhase - rndPhase > pi
    curPhase = curPhase - 2 * pi - rndPhase;
elseif curPhase - rndPhase < -pi
    curPhase = curPhase + 2 * pi - rndPhase;
else
    curPhase = curPhase - rndPhase;
end
Npha = lastPhase + curPhase;
end