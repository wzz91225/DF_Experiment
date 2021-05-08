% ������ת����Ƶ�򣬽�˫ͨ��Ƶ�����ֵ�ñȷ�������Ƕ�
% �����������ݣ���Ƶ���Ͻ��ź���������Դﵽȥ��Ŀ��



fileaddr = '.\20210115_Experiment_AmCmp\rawdata\TxStay-RxSpin\';
freq_samp = 32e3;
angle_max = 90;

% δȥ��ʱPearson���ϵ��0.9937
N = 262144;	% ȥ�����ݽ�ȡ����

% fftǰ�Ӵ�����Ƶ��й¶��δ�Ӵ�ʱPearson���ϵ��0.9939
% timewindow = taylorwin(N);	% �Ӵ� 0.9944
% timewindow = kaiser(N);       % �Ӵ� 0.9944
% timewindow = rectwin(N);      % �Ӵ� 0.9944
% timewindow = hamming(N);      % �Ӵ� 0.9943
% timewindow = gausswin(N);     % �Ӵ� 0.9941

close all;



% ���ļ���ȡ��������
noise0 = read_complex_binary(strcat(fileaddr, 'n0_1'));
noise1 = read_complex_binary(strcat(fileaddr, 'n1_1'));

% ȡ����ʱ��fft
noise0_fft = fft(noise0(1 : N));
noise1_fft = fft(noise1(1 : N));
% noise0_fft = fft(noise0(1 : N).*timewindow);
% noise1_fft = fft(noise1(1 : N).*timewindow);

% ȫ��ʱ��ת����Ƶ��
[noisefreq0, nflist0] = time_to_frequency_domain(noise0, freq_samp);
[noisefreq1, nflist1] = time_to_frequency_domain(noise1, freq_samp);

% ������ͼ
% dual_channel_noise_display( noise0, noisefreq0, nflist0, ...
%                             noise1, noisefreq1, nflist1);


                        
% ���ݴ���
dmax0 = [];         % ͨ��0Ƶ�����ֵ
dmax1 = [];         % ͨ��1Ƶ�����ֵ
freqmax0 = [];      % ͨ��0Ƶ�����ֵ��ӦƵ��ֵ
freqmax1 = [];      % ͨ��1Ƶ�����ֵ��ӦƵ��ֵ

dmax0_denoise = [];     % ͨ��0ȥ��Ƶ�����ֵ
dmax1_denoise = [];     % ͨ��1ȥ��Ƶ�����ֵ
freqmax0_denoise = [];  % ͨ��0ȥ��Ƶ�����ֵ��ӦƵ��ֵ
freqmax1_denoise = [];  % ͨ��1ȥ��Ƶ�����ֵ��ӦƵ��ֵ

for angle_actual = 0 : 15 : angle_max
    filename0 = strcat('d0_', num2str(angle_actual), 'deg');
    filename1 = strcat('d1_', num2str(angle_actual), 'deg');
    
    % ���ļ���ȡ��Ӧ�Ƕ�����
    data0 = read_complex_binary(strcat(fileaddr, filename0));
    data1 = read_complex_binary(strcat(fileaddr, filename1));
    
    % ʱ��ת����Ƶ��
    [datafreq0, freqlist0] = time_to_frequency_domain(data0, freq_samp);
    [datafreq1, freqlist1] = time_to_frequency_domain(data1, freq_samp);
    
    % ��ȡƵ�����ֵ�����ӦƵ��
    [dmax0(end+1), freqmax0(end+1)] = max(datafreq0);
    freqmax0(end) = freq_samp * freqmax0(end) / length(data0);
    [dmax1(end+1), freqmax1(end+1)] = max(datafreq1);
    freqmax1(end) = freq_samp * freqmax1(end) / length(data1);
    
    % ˫ͨ���źŻ�ͼ
    dual_channel_signal_display(strcat(num2str(angle_actual), 'deg'), ...
                                data0, datafreq0, freqlist0, ...
                                data1, datafreq1, freqlist1);
    
    
                            
    % Ƶ��ȥ��
    data0_denoise = ifft(fft(data0(1 : N)) - noise0_fft);
    data1_denoise = ifft(fft(data1(1 : N)) - noise1_fft);
%     data0_denoise = ifft(fft(data0(1 : N).*timewindow') - noise0_fft);
%     data1_denoise = ifft(fft(data1(1 : N).*timewindow') - noise1_fft);
    
    % ʱ��ת����Ƶ��
    [datafreq0_denoise, freqlist0_denoise] = time_to_frequency_domain(data0_denoise, freq_samp);
    [datafreq1_denoise, freqlist1_denoise] = time_to_frequency_domain(data1_denoise, freq_samp);
    
    % ��ȡƵ�����ֵ�����ӦƵ��
    [dmax0_denoise(end+1), freqmax0_denoise(end+1)] = max(datafreq0_denoise);
    freqmax0_denoise(end) = freq_samp * freqmax0_denoise(end) / N;
    [dmax1_denoise(end+1), freqmax1_denoise(end+1)] = max(datafreq1_denoise);
    freqmax1_denoise(end) = freq_samp * freqmax1_denoise(end) / N;

    % ˫ͨ���źŻ�ͼ
%     dual_channel_signal_display(strcat('Denoise ', num2str(angle_actual), 'deg'), ...
%                                 data0_denoise, datafreq0_denoise, freqlist0_denoise, ...
%                                 data1_denoise, datafreq1_denoise, freqlist1_denoise);
    
end



% �ȷ�������Ƕ�
angle_calc = [];
for i = 1 : angle_max / 15 + 1
    angle_calc(i) = atand(dmax1(i) / dmax0(i));
end

% �ȷ�������ȥ��Ƕ�
angle_calc_denoise = [];
for i = 1 : angle_max / 15 + 1
    angle_calc_denoise(i) = atand(dmax1_denoise(i) / dmax0_denoise(i));
end



% ����ȥ�������
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
