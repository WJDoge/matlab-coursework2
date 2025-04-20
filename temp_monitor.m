function temp_monitor(a)
% temp_monitor 持续监控舱内温度并根据测量值控制 LED
%
% 此函数通过 Arduino 读取温度传感器数据，实时更新温度随时间变化的图形，
% 并根据以下条件控制三个 LED：
%
%   - 温度在 18°C 到 24°C 范围内：绿灯持续常亮；
%   - 温度低于 18°C：黄灯以 0.5 秒间隔闪烁；
%   - 温度高于 24°C：红灯以 0.25 秒间隔闪烁。
%
% 输入参数：
%   a - 由 arduino() 创建的 Arduino 对象
%
% LED 连接口分配（请根据你的实际接线情况调整）：
%   绿灯：D10, 黄灯：D11, 红灯：D12
%
% 示例调用：
%   temp_monitor(a);
% -------------------------------------------------------------------------

% 定义 LED 数字口
greenPin = 'D10';
yellowPin = 'D11';
redPin = 'D12';

% 初始化实时绘图数据
time_data = [];
temp_data = [];
startTime = tic;

figure;
hPlot = plot(nan, nan, '-o');
xlabel('时间 (秒)');
ylabel('温度 (°C)');
title('实时温度监控');
grid on;

% 无限循环（执行时请按 Ctrl+C 终止）
while true
    currentTime = toc(startTime);
    
    % 读取温度传感器数据
    % 温度转换参数（假设与 Task 1 中相同）
    V0 = 0.5;
    TC = 0.01;
    voltage_raw = readVoltage(a, 'A0');
    voltage = voltage_raw;
    currentTemp = (voltage - V0) / TC;

    % 累积数据用于绘图
    time_data(end+1) = currentTime;
    temp_data(end+1) = currentTemp;
    
    % 更新实时图形
    set(hPlot, 'XData', time_data, 'YData', temp_data);
    xlim([max(0, currentTime-60) currentTime+5]); % 显示最近 60 秒数据
    ylim([min(temp_data)-1, max(temp_data)+1]);
    drawnow;
    
    % 根据温度控制 LED 状态
    if (currentTemp >= 18) && (currentTemp <= 24)
        % 温度处于舒适区：绿灯常亮，其它灯灭
        writeDigitalPin(a, greenPin, 1);
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
        pause(1);  % 每秒更新
    elseif currentTemp < 18
        % 温度过低：黄灯闪烁，周期约为 1 秒（0.5 s 亮，0.5 s 灭）
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, redPin, 0);
        writeDigitalPin(a, yellowPin, 1);
        pause(0.5);
        writeDigitalPin(a, yellowPin, 0);
        pause(0.5);
    elseif currentTemp > 24
        % 温度过高：红灯闪烁，周期约为 1 秒（0.25 s 亮，0.25 s 灭，循环两次）
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        for blinkCycle = 1:2
            writeDigitalPin(a, redPin, 1);
            pause(0.25);
            writeDigitalPin(a, redPin, 0);
            pause(0.25);
        end
    end
end

end
