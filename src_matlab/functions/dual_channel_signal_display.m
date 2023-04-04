function [] = dual_channel_signal_display( ...
                                figure_name, ...
                                data0_time, data0_freq, freqlist0, ...
                                data1_time, data1_freq, freqlist1)
% DUAL_CHANNEL_SIGNAL_DISPLAY 双通道信号时域与频域绘图

d0_real = real(data0_time);
d0_imag = imag(data0_time);
d1_real = real(data1_time);
d1_imag = imag(data1_time);

figure('name', figure_name)
subplot(221)
plot(d0_real)
hold on
plot(d0_imag)
hold off
% ylim([-1 1])
axis([1 100 -1 1])

subplot(222)
plot(d1_real)
hold on
plot(d1_imag)
hold off
% ylim([-1 1])
axis([1 100 -1 1])

subplot(223)
plot(freqlist0, data0_freq)
xlim([1.20e3 1.35e3])
ylim([0 10])
% axis([1.20e3 1.35e3 0 1.5])

subplot(224)
plot(freqlist1, data1_freq)
xlim([1.20e3 1.35e3])
ylim([0 10])
% axis([1.20e3 1.35e3 0 1.5])

end

