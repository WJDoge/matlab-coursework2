
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

        % ------------------ 新增代码开始 ------------------
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
