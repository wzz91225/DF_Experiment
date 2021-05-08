clc;
clear;
close all;

fileaddr = '.\20210115_Experiment_AmCmp\rawdata\TxStay-RxSpin\';
freq_samp = 32e3;
angle_max = 90;

% N / AccumulationLength ��Ϊ����
N = 262144;
AccumulationLength = 32768;



dmax0 = zeros(angle_max / 15 + 1, 1);
dmax1 = zeros(angle_max / 15 + 1, 1);
freqmax0 = zeros(angle_max / 15 + 1, 1);
freqmax1 = zeros(angle_max / 15 + 1, 1);

phase_difference = zeros(angle_max / 15 + 1, 1);

for i = 1 : angle_max / 15 + 1
    actual_angle = (i - 1) * 15;
    % ���ļ���ȡ��Ӧ�Ƕ�����
    filename0 = strcat('d0_', num2str(actual_angle), 'deg');
    filename1 = strcat('d1_', num2str(actual_angle), 'deg');
    data0 = read_complex_binary(strcat(fileaddr, filename0));
    data1 = read_complex_binary(strcat(fileaddr, filename1));
    
    % �����趨���Ƚ�ȡ����
    data0 = data0(1 : N);
    data1 = data1(1 : N);
    
    % ������λ��
    phase_difference(i) = phase_difference_estimate(data0, data1);
    
%     % �ƶ�ƽ���˲�
%     by = [1 1 1 1 1 1]/6;
%     X_r0 = filter(by, 1, real(data0));
%     X_r1 = filter(by, 1, real(data1));
%     X_i0 = filter(by, 1, imag(data0));
%     X_i1 = filter(by, 1, imag(data1));
%     
%     data0 = X_r0 + 1i * X_i0;
%     data1 = X_r1 + 1i * X_i1;

    % ����ɻ��� Incoherent Accumulation
    freqlist = zeros(int32(AccumulationLength/2)+1, 1);
    incoherentAcc0 = zeros(int32(AccumulationLength/2)+1, 1);
    incoherentAcc1 = zeros(int32(AccumulationLength/2)+1, 1);
    for j = 0 : (N / AccumulationLength - 1)
        pBegin = j * AccumulationLength + 1;
        pEnd = (j + 1) * AccumulationLength;

        % ͨ��0
        [freqdomain0, ~] = time_to_frequency_domain(data0(pBegin : pEnd), freq_samp);
        incoherentAcc0 = incoherentAcc0 + freqdomain0;

        % ͨ��1
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
    
    % ��ȡƵ�����ֵ�����ӦƵ��
    [dmax0(i), freqmax0(i)] = max(incoherentAcc0);
    freqmax0(end) = freq_samp * freqmax0(end) / AccumulationLength;
    [dmax1(i), freqmax1(i)] = max(incoherentAcc1);
    freqmax1(end) = freq_samp * freqmax1(end) / AccumulationLength;
end



% �ȷ�������Ƕ�
angle_calc = zeros(1, angle_max / 15 + 1);
for i = 1 : angle_max / 15 + 1
    angle_calc(i) = atand(dmax1(i) / dmax0(i));
end



% ����ȥ�������
figure('name', 'Angle')

anglelist = (0:15:angle_max);
% plot(anglelist, angle_calc, 'o')

err_list = abs(angle_calc - anglelist);
errorbar(anglelist, angle_calc, err_list, 'o')
xlim([0 90])

err_ave = mean(err_list)
rho = corrcoef(anglelist, angle_calc)

xlabel('ʵ�ʽǶ�(��)')
ylabel('�����Ƕ�(��)')
title('���ڱȷ�����Ƶ�������')
