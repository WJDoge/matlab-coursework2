% 验证三个LED是否可用的代码
% 请确保已建立 Arduino 对象，并将其存储在变量 a 中
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
% 温度系数 TC = 0.01 V/°C，若与你的传感器数据不同，请调整这两个参数）

V0 = 0.5;      % 0°C 对应电压，单位：伏特
TC = 0.01;     % 温度系数，单位：伏特/°C

duration = 30;          % 总采集时间 600 秒（10 分钟）
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
%^disp('启动 Task 2：LED 温度监控设备。');
% 调用函数 temp_monitor，该函数实现了实时监控、图形更新及 LED 控制
%temp_monitor(a);
% 注意：该函数为无限循环，请使用 Ctrl+C 停止执行后再进行 Task 3

%% Task 3 - 温度预测算法
%若需运行 Task 3，请注释掉 Task 2 调用，并取消下面代码行注释
disp('启动 Task 3：LED 温度预测设备。')
temp_prediction(a);

%% Task 4 - 反思性陈述 (400 字以内)
%
% 反思性陈述（请在下面注释中填写，不超过 400 字）：
%
% 本项目要求将 MATLAB 与 Arduino 集成，实现温度数据采集、实时监控、LED 控制及温度预测。
% 在完成过程中，我学到了如何配置 Arduino 支持包、利用 Git 进行版本控制，
% 以及如何利用 MATLAB 的图形与文件 I/O 功能实现数据记录和显示。
% 本次作业也暴露了实时控制与采样之间的权衡，未来可考虑使用异步任务或计时器提高响应效率。
%
% (请根据实际体验详细描述你在项目中遇到的挑战、优势、局限和改进建议)

%% 任务 5 - 代码注释、版本控制与专业实践
% 请确保整个代码过程均有详尽的注释，并在开发过程中多次提交（commit）代码版本。
% =========================================================================
