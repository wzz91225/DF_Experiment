% 将数据转换至频域，将双通道频域最大值用比幅法计算角度
% 利用噪声数据，在频域上将信号与其相减以达到去噪目的



fileaddr = '.\20210115_Experiment_AmCmp\rawdata\TxStay-RxSpin\';
freq_samp = 32e3;
angle_max = 90;

% 未去噪时Pearson相关系数0.9937
N = 262144;	% 去噪数据截取长度

% fft前加窗减少频谱泄露，未加窗时Pearson相关系数0.9939
% timewindow = taylorwin(N);	% 加窗 0.9944
% timewindow = kaiser(N);       % 加窗 0.9944
% timewindow = rectwin(N);      % 加窗 0.9944
% timewindow = hamming(N);      % 加窗 0.9943
% timewindow = gausswin(N);     % 加窗 0.9941

close all;



% 从文件读取噪声数据
noise0 = read_complex_binary(strcat(fileaddr, 'n0_1'));
noise1 = read_complex_binary(strcat(fileaddr, 'n1_1'));

% 取部分时域fft
noise0_fft = fft(noise0(1 : N));
noise1_fft = fft(noise1(1 : N));
% noise0_fft = fft(noise0(1 : N).*timewindow);
% noise1_fft = fft(noise1(1 : N).*timewindow);

% 全部时域转单侧频域
[noisefreq0, nflist0] = time_to_frequency_domain(noise0, freq_samp);
[noisefreq1, nflist1] = time_to_frequency_domain(noise1, freq_samp);

% 噪声绘图
% dual_channel_noise_display( noise0, noisefreq0, nflist0, ...
%                             noise1, noisefreq1, nflist1);


                        
% 数据处理
dmax0 = [];         % 通道0频域最大值
dmax1 = [];         % 通道1频域最大值
freqmax0 = [];      % 通道0频域最大值对应频率值
freqmax1 = [];      % 通道1频域最大值对应频率值

dmax0_denoise = [];     % 通道0去噪频域最大值
dmax1_denoise = [];     % 通道1去噪频域最大值
freqmax0_denoise = [];  % 通道0去噪频域最大值对应频率值
freqmax1_denoise = [];  % 通道1去噪频域最大值对应频率值

for angle_actual = 0 : 15 : angle_max
    filename0 = strcat('d0_', num2str(angle_actual), 'deg');
    filename1 = strcat('d1_', num2str(angle_actual), 'deg');
    
    % 从文件读取对应角度数据
    data0 = read_complex_binary(strcat(fileaddr, filename0));
    data1 = read_complex_binary(strcat(fileaddr, filename1));
    
    % 时域转单侧频域
    [datafreq0, freqlist0] = time_to_frequency_domain(data0, freq_samp);
    [datafreq1, freqlist1] = time_to_frequency_domain(data1, freq_samp);
    
    % 获取频域最大值及其对应频点
    [dmax0(end+1), freqmax0(end+1)] = max(datafreq0);
    freqmax0(end) = freq_samp * freqmax0(end) / length(data0);
    [dmax1(end+1), freqmax1(end+1)] = max(datafreq1);
    freqmax1(end) = freq_samp * freqmax1(end) / length(data1);
    
    % 双通道信号绘图
    dual_channel_signal_display(strcat(num2str(angle_actual), 'deg'), ...
                                data0, datafreq0, freqlist0, ...
                                data1, datafreq1, freqlist1);
    
    
                            
    % 频域去噪
    data0_denoise = ifft(fft(data0(1 : N)) - noise0_fft);
    data1_denoise = ifft(fft(data1(1 : N)) - noise1_fft);
%     data0_denoise = ifft(fft(data0(1 : N).*timewindow') - noise0_fft);
%     data1_denoise = ifft(fft(data1(1 : N).*timewindow') - noise1_fft);
    
    % 时域转单侧频域
    [datafreq0_denoise, freqlist0_denoise] = time_to_frequency_domain(data0_denoise, freq_samp);
    [datafreq1_denoise, freqlist1_denoise] = time_to_frequency_domain(data1_denoise, freq_samp);
    
    % 获取频域最大值及其对应频点
    [dmax0_denoise(end+1), freqmax0_denoise(end+1)] = max(datafreq0_denoise);
    freqmax0_denoise(end) = freq_samp * freqmax0_denoise(end) / N;
    [dmax1_denoise(end+1), freqmax1_denoise(end+1)] = max(datafreq1_denoise);
    freqmax1_denoise(end) = freq_samp * freqmax1_denoise(end) / N;

    % 双通道信号绘图
%     dual_channel_signal_display(strcat('Denoise ', num2str(angle_actual), 'deg'), ...
%                                 data0_denoise, datafreq0_denoise, freqlist0_denoise, ...
%                                 data1_denoise, datafreq1_denoise, freqlist1_denoise);
    
end



% 比幅法计算角度
angle_calc = [];
for i = 1 : angle_max / 15 + 1
    angle_calc(i) = atand(dmax1(i) / dmax0(i));
end

% 比幅法计算去噪角度
angle_calc_denoise = [];
for i = 1 : angle_max / 15 + 1
    angle_calc_denoise(i) = atand(dmax1_denoise(i) / dmax0_denoise(i));
end



% 绘制去噪测向结果
figure('name', 'Angle')
anglelist = (0:15:angle_max);

% plot(anglelist, angle_calc, 'o')
% hold on
% plot(anglelist, angle_calc_denoise, 'x')
% hold off

err_list = abs(angle_calc - anglelist);
err_list_denoise = abs(angle_calc_denoise - anglelist);

errorbar(anglelist, angle_calc, err_list, 'o')
hold on
errorbar(anglelist, angle_calc_denoise, err_list_denoise, 'x')
hold off
xlim([0 90])

err_ave = mean(err_list)
rho = corrcoef(anglelist, angle_calc)
err_ave = mean(err_list_denoise)
rho_denoise = corrcoef(anglelist, angle_calc_denoise)
