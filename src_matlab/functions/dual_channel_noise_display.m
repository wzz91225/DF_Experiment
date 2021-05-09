function [] = dual_channel_noise_display( ...
                                data0_time, data0_freq, freqlist0, ...
                                data1_time, data1_freq, freqlist1)
% DUAL_CHANNEL_NOISE_DISPLAY 双通道信号时域与频域绘图

d0_real = real(data0_time);
d0_imag = imag(data0_time);
d1_real = real(data1_time);
d1_imag = imag(data1_time);

figure('name', 'Noise')
subplot(221)
plot(d0_real(1:100))
hold on
plot(d0_imag(1:100))
hold off
ylim([-1 1])

subplot(222)
plot(d1_real(1:100))
hold on
plot(d1_imag(1:100))
hold off
ylim([-1 1])

subplot(223)
plot(freqlist0, data0_freq)
ylim([0 0.6])

subplot(224)
plot(freqlist1, data1_freq)
ylim([0 0.6])

end

