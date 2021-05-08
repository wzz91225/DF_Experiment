close all;

Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1500;             % Length of signal
t = (0:L-1)*T;        % Time vector

fftn = 128;

S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);

X = S + 2 * randn(size(t));

P1 = fft(S, fftn) / L;

% f = Fs * (0 : L-1) / L;
f = Fs * L * (0 : fftn-1) / fftn;

subplot(221)
plot(f, abs(P1))
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

Z = ifft(P1 * L);

subplot(223)
plot(S)
axis([0 100 -2 2])
subplot(224)
plot(Z)
axis([0 100 -2 2])
