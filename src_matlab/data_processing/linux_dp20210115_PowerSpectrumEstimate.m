% clc
close all
clear;



%%
% Import rawdata from local files
InputFileAddress = './20210115_Experiment_AmCmp/rawdata/TxStay-RxSpin/';
dataname = '0deg';

filename0 = strcat('d0_', dataname);
filename1 = strcat('d1_', dataname);

data0 = read_complex_binary(strcat(InputFileAddress, filename0));
data1 = read_complex_binary(strcat(InputFileAddress, filename1));



%%
% Define parameters
sampleRate = 32000; % Hz
timeLimits = [1.0 10.0]; % seconds

frequencyLimits = [0 2000]; % Hz
FrequencyResolution = 31.2576; % Hz



%%
% Index into signal time region of interest
unidatalength = min(length(data0), length(data1));
minIdx = ceil(max(timeLimits(1) * sampleRate, 0)) + 1;
maxIdx = floor(min(timeLimits(2) * sampleRate, unidatalength - 1)) + 1;
data0_ROI = data0(minIdx:maxIdx);
data1_ROI = data1(minIdx:maxIdx);

% Compute spectral estimate
[Pdata0_ROI, Fdata0_ROI] = pspectrum(data0_ROI, sampleRate, ...
    'FrequencyLimits',frequencyLimits, ...
    'FrequencyResolution', FrequencyResolution);

[Pdata1_ROI, Fdata1_ROI] = pspectrum(data1_ROI, sampleRate, ...
    'FrequencyLimits',frequencyLimits, ...
    'FrequencyResolution', FrequencyResolution);



%%
% Plot
figure(1)

subplot(1, 2, 1)
plot(Fdata0_ROI, Pdata0_ROI)
hold on
plot(Fdata1_ROI, Pdata1_ROI)
hold off

grid on
xlabel('Frequency (Hz)')
ylabel('Power Spectrum')
title(strcat(dataname, ' - pspectrum'))


subplot(1, 2, 2)
plot(Fdata0_ROI, pow2db(Pdata0_ROI))
hold on
plot(Fdata1_ROI, pow2db(Pdata1_ROI))
hold off

grid on
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title(strcat(dataname, ' - pspectrum (dB)'))
