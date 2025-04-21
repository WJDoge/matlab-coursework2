%Tonghui Sha
%ssyts2@nottingham.edu.cn


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]

%Done

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% 清除可能残留的连接变量
if exist('a', 'var')
    clear a;
    instrreset; % 强制释放串口资源（可选）
end
% 建立 Arduino 对象，并将其存储在变量 a 中
a = arduino('COM11', 'Uno')

% LED 分别连接：
%   绿灯：D10
%   黄灯：D11
%   红灯：D12
% 定义 LED 的数字口
greenPin = 'D10';
yellowPin = 'D11';
redPin = 'D12';

disp('开始测试LED是否可用...');

% 初始状态全部关闭
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);
pause(1);

% 单独测试绿灯
disp('测试绿灯...');
writeDigitalPin(a, greenPin, 1);
pause(1);  % 亮1秒
writeDigitalPin(a, greenPin, 0);
pause(0.5);

% 单独测试黄灯
disp('测试黄灯...');
writeDigitalPin(a, yellowPin, 1);
pause(1);
writeDigitalPin(a, yellowPin, 0);
pause(0.5);

% 单独测试红灯
disp('测试红灯...');
writeDigitalPin(a, redPin, 1);
pause(1);
writeDigitalPin(a, redPin, 0);
pause(0.5);

% 同时测试所有LED
disp('同时测试所有LED...');
writeDigitalPin(a, greenPin, 1);
writeDigitalPin(a, yellowPin, 1);
writeDigitalPin(a, redPin, 1);
pause(1);
writeDigitalPin(a, greenPin, 0);
writeDigitalPin(a, yellowPin, 0);
writeDigitalPin(a, redPin, 0);

disp('LED 测试结束。');


%% Task 1 - 温度数据采集、绘图和日志记录
% 本任务中使用 MCP9700A 温度传感器（假设其 0°C 时输出电压 V0 = 0.5 V，
% 温度系数 TC = 0.01 V/°C，

V0 = 0.5;      % 0°C 对应电压，单位：伏特
TC = 0.01;     % 温度系数，单位：伏特/°C

duration = 600;          % 总采集时间 600 秒（10 分钟）
numSamples = duration + 1;  % 包含起始时刻

temp_all = zeros(1, numSamples);  % 存储温度数据
time_all = zeros(1, numSamples);  % 存储对应的时间（秒）
configurePin(a, 'A0', 'AnalogInput');
voltage = readVoltage(a, 'A0');

disp('开始温度数据采集...');
tic;  % 使用 tic/toc 计时
for t = 0:duration
    currentTime = toc;
    time_all(t+1) = currentTime;
voltage = readVoltage(a,'A0');  % 读取原始电压值（单位 mV）        % 转换成伏特
temp_all(t+1) = (voltage - V0) / TC;    % 进行温度换算
    pause(1);  % 每秒采样一次
end
disp('温度数据采集完成。');

% 计算整体数据集的最小、最大和平均温度
minTemp = min(temp_all);
maxTemp = max(temp_all);
avgTemp = mean(temp_all);

% 绘制温度随时间变化图
figure;
plot(time_all, temp_all, '-o');
xlabel('时间 (秒)');
ylabel('温度 (°C)');
title('舱内温度随时间变化');
grid on;

% 日志记录：按照示例格式，每分钟记录一次数据（从 Minute 0 至 Minute 10 共 11 个数据点）
logIndices = 1:60:numSamples;  % 例如采样点 1, 61, 121,...,601
numLogs = length(logIndices);
logText = sprintf('Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
logText = [logText, 'Location - Nottingham\n\n'];
for i = 1:numLogs
    logText = [logText, sprintf('Minute\t\t%d\n', i-1)];
    logText = [logText, sprintf('Temperature\t%.2f C\n\n', temp_all(logIndices(i)))];
end
logText = [logText, sprintf('Max temp\t%.2f C\n', maxTemp)];
logText = [logText, sprintf('Min temp\t%.2f C\n', minTemp)];
logText = [logText, sprintf('Average temp\t%.2f C\n\n', avgTemp)];
logText = [logText, 'Data logging terminated\n'];

% 在命令窗口输出日志
disp(logText);

% 将日志写入文本文件 cabin_temperature.txt
fid = fopen('cabin_temperature.txt', 'w');
if fid == -1
    error('无法打开文件 cabin_temperature.txt 进行写入。');
end
fprintf(fid, '%s', logText);
fclose(fid);
disp('温度日志已写入文件 cabin_temperature.txt');



%% Task 2 - LED 温度监控设备实现



function temp_monitor(a)

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


%% Task 3 - 温度预测算法


function temp_prediction(a, V0, TC)

    greenPin = 'D10';
    yellowPin = 'D11';
    redPin = 'D12';
    
    if nargin < 2
        V0 = 0.5;
    end
    if nargin < 3
        TC = 0.01;
    end

    % 设置平滑窗口：使用30秒内的数据来计算变化率
    windowSize = 30;
    temperatureBuffer = [];
    timeBuffer = [];
    
    disp('Starting temperature prediction algorithm...');
    persistent startTime;
    if isempty(startTime)
        startTime = tic;
    end

    while true
        elapsed = toc(startTime);
        % 读取电压值（单位：伏特）
        voltage = readVoltage(a, 'A0');      
        % 计算当前温度（单位：°C）
        currentTemp = (voltage - V0) / TC;
        
        % 将当前数据加入缓冲区
        temperatureBuffer(end+1) = currentTemp;
        timeBuffer(end+1) = elapsed;
        
        % 删除超过平滑窗口的数据
        while (timeBuffer(end) - timeBuffer(1)) > windowSize
            temperatureBuffer(1) = [];
            timeBuffer(1) = [];
        end
        
        % 当缓冲区数据足够时，计算温度变化率（dT/dt，单位：°C/s）
        if length(temperatureBuffer) >= 2
            dT = temperatureBuffer(end) - temperatureBuffer(1);
            dt = timeBuffer(end) - timeBuffer(1);
            derivative = dT / dt;   % 单位：°C/s
        else
            derivative = 0;
        end
        
        % 使用当前变化率外推未来 5 分钟（300秒）的温度
        predictedTemp = currentTemp + derivative * 300;

      
        % 将温度变化率转换为 °C/分钟
        rate_per_min = derivative * 60;
        
        maxRateLimit = 5;  % 设置上限为 5°C/分钟
        
        if abs(rate_per_min) > maxRateLimit
            derivative = 0;
            rate_per_min = 0;
            predictedTemp = currentTemp;  % 预测温度直接采用当前温度
        end
     
        
        % 打印结果：当前温度、温度变化率（°C/s）以及5分钟后的预测温度
        fprintf('Current Temp: %.2f °C, Rate: %.4f °C/s, Predicted Temp (5 min later): %.2f °C\n', ...
            currentTemp, derivative, predictedTemp);
           % 控制 LED
        if rate_per_min > 4
            writeDigitalPin(a, redPin, 1);
            writeDigitalPin(a, yellowPin, 0);
            writeDigitalPin(a, greenPin, 0);
        elseif rate_per_min < -4
            writeDigitalPin(a, yellowPin, 1);
            writeDigitalPin(a, redPin, 0);
            writeDigitalPin(a, greenPin, 0);
        else
            writeDigitalPin(a, greenPin, 1);
            writeDigitalPin(a, redPin, 0);
            writeDigitalPin(a, yellowPin, 0);
        end
        
  
        pause(1);  % 每秒更新一次
    end
end


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

%% REFLECTIVE STATEMENT

% During the development process, one of the first issues I encountered was a significant difference in real-time 
% temperature readings between the main script and the task2/task3 scripts. Eventually, I discovered that the problem 
% originated from incorrect wiring – I had not properly connected the resistor and LED in series before integrating 
% them into the circuit. As a result, the LEDs caused a voltage drop, which affected the A0 analog readings. 
% This explained why the same code produced different outputs in different scripts. After correcting the wiring, 
% the voltage readings became much more consistent.

% Another major challenge was the implementation of temperature prediction in Task 3. Since it forecasts temperature 
% five minutes into the future, using a purely linear algorithm caused unrealistic predictions due to random voltage 
% spikes. To address this, I added a threshold filter for the rate of change to reject outliers. This helped stabilize 
% the predictions significantly. Although this reduces sensitivity, it is a reasonable trade-off in a cabin environment 
% where temperature is generally stable.

% I believe the strength of my implementation lies in the simplicity of the approach. I prioritized clear, minimal 
% logic to reduce development complexity and error rates, while making it easier to expand with new features in the future.

% However, there are still limitations. For example, Task 3 predictions are not always accurate, and due to hardware 
% limitations, further algorithm optimization may have limited effect. Thus, I chose to keep the algorithm simple.

% Given more time, I would address the unstable readings during the initial execution of the program, and add a more 
% user-friendly interface for selecting between different functionalities (rather than commenting/uncommenting code). 
% Furthermore, if better hardware was available, I would consider integrating multiple sensors and refining the 
% prediction logic for improved accuracy in both monitoring and forecasting cabin temperature.

