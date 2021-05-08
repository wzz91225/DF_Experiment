clc;
clear;
close all;

fileaddr = '.\20210115_Experiment_AmCmp\rawdata\TxStay-RxSpin\';
freq_samp = 32e3;
angle_max = 90;

% N / AccumulationLength 需为整数
N = 262144;
AccumulationLength = 32768;



dmax0 = zeros(angle_max / 15 + 1, 1);
dmax1 = zeros(angle_max / 15 + 1, 1);
freqmax0 = zeros(angle_max / 15 + 1, 1);
freqmax1 = zeros(angle_max / 15 + 1, 1);

phase_difference = zeros(angle_max / 15 + 1, 1);

for i = 1 : angle_max / 15 + 1
    actual_angle = (i - 1) * 15;
    % 从文件读取对应角度数据
    filename0 = strcat('d0_', num2str(actual_angle), 'deg');
    filename1 = strcat('d1_', num2str(actual_angle), 'deg');
    data0 = read_complex_binary(strcat(fileaddr, filename0));
    data1 = read_complex_binary(strcat(fileaddr, filename1));
    
    % 根据设定长度截取数据
    data0 = data0(1 : N);
    data1 = data1(1 : N);
    
    % 测量相位差
    phase_difference(i) = phase_difference_estimate(data0, data1);
    
%     % 移动平均滤波
%     by = [1 1 1 1 1 1]/6;
%     X_r0 = filter(by, 1, real(data0));
%     X_r1 = filter(by, 1, real(data1));
%     X_i0 = filter(by, 1, imag(data0));
%     X_i1 = filter(by, 1, imag(data1));
%     
%     data0 = X_r0 + 1i * X_i0;
%     data1 = X_r1 + 1i * X_i1;

    % 非相干积累 Incoherent Accumulation
    freqlist = zeros(int32(AccumulationLength/2)+1, 1);
    incoherentAcc0 = zeros(int32(AccumulationLength/2)+1, 1);
    incoherentAcc1 = zeros(int32(AccumulationLength/2)+1, 1);
    for j = 0 : (N / AccumulationLength - 1)
        pBegin = j * AccumulationLength + 1;
        pEnd = (j + 1) * AccumulationLength;

        % 通道0
        [freqdomain0, ~] = time_to_frequency_domain(data0(pBegin : pEnd), freq_samp);
        incoherentAcc0 = incoherentAcc0 + freqdomain0;

        % 通道1
        [freqdomain1, freqlist] = time_to_frequency_domain(data1(pBegin : pEnd), freq_samp);
        incoherentAcc1 = incoherentAcc1 + freqdomain1;
    end

    % subplot(211)
    % plot(freqlist, incoherentAcc0)
    % subplot(212)
    % plot(freqlist, incoherentAcc1)
    
    dual_channel_signal_display(strcat(num2str(actual_angle), 'deg'), ...
                                data0, incoherentAcc0, freqlist, ...
                                data1, incoherentAcc1, freqlist);
    
    % 获取频域最大值及其对应频点
    [dmax0(i), freqmax0(i)] = max(incoherentAcc0);
    freqmax0(end) = freq_samp * freqmax0(end) / AccumulationLength;
    [dmax1(i), freqmax1(i)] = max(incoherentAcc1);
    freqmax1(end) = freq_samp * freqmax1(end) / AccumulationLength;
end



% 比幅法计算角度
angle_calc = zeros(1, angle_max / 15 + 1);
for i = 1 : angle_max / 15 + 1
    angle_calc(i) = atand(dmax1(i) / dmax0(i));
end



% 绘制去噪测向结果
figure('name', 'Angle')

anglelist = (0:15:angle_max);
% plot(anglelist, angle_calc, 'o')

err_list = abs(angle_calc - anglelist);
errorbar(anglelist, angle_calc, err_list, 'o')
xlim([0 90])

err_ave = mean(err_list)
rho = corrcoef(anglelist, angle_calc)

xlabel('实际角度(°)')
ylabel('测量角度(°)')
title('基于比幅法的频域测向结果')
