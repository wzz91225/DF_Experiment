% test programme for phase error estimation
clc; clear;

%% Signal
f0 = 200;  % signal frequency (Hz)
fs = 3000; % sampling frequency (Hz)
T = 5 / f0; % sampling time (s)
N = round(T * fs);
N = N + mod(N, 2);
t = [0: N - 1] / fs;

phase_1 = pi * rand(1, 1);
phase_1_d = phase_1 / (2 * pi) * 360
phase_2 = pi * rand(1, 1);
phase_2_d = phase_2 / (2 * pi) * 360

phase_error = phase_1 - phase_2;
phase_error_d = 360 * phase_error / (2 * pi)

amplitude_1 = 100 * rand(1, 1);
amplitude_2 = 100 * rand(1, 1);

s1 = amplitude_1 * exp(1i * 2 * pi * f0 * t + 1i * phase_1);
s2 = amplitude_2 * exp(1i * 2 * pi * f0 * t + 1i * phase_2);

figure(1)
subplot(211)
plot(real(s1))
hold on
plot(imag(s1))
hold off
subplot(212)
plot(real(s2))
hold on
plot(imag(s2))
hold off

%% Phase error estimation
corr = xcorr(s1, s2);  % cross-correlation function
corr_abs = abs(corr);
corr_max = corr(corr_abs == max(corr_abs));
phase_error_estimated = angle(corr_max / abs(corr_max));
phase_error_estimated_d = 360 * phase_error_estimated / (2 * pi)
