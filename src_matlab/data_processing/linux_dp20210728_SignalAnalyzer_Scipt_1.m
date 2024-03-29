% Extract time region of interest from signals

% Generated by MATLAB(R) 9.12 and Signal Processing Toolbox 9.0.
% Generated on: 30-Mar-2023 15:42:46


clc
close all
clear;


InputFileAddress = './20210728_Experiment_NewCirclePolarized/rawdata/';
dataname = 'data945';

filename0 = strcat(dataname, '_rx0.dat');
filename1 = strcat(dataname, '_rx1.dat');
data0 = read_complex_binary(strcat(InputFileAddress, filename0));
data1 = read_complex_binary(strcat(InputFileAddress, filename1));




% Parameters
timeLimits = [0.1 61.84584]; % seconds

%%
data0_ROI = data0(:);
sampleRate = 32000; % Hz
startTime = 0; % seconds
minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;
maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(data0_ROI)-1))+1;
data0_ROI = data0_ROI(minIdx:maxIdx);

%%
data1_ROI = data1(:);
sampleRate = 32000; % Hz
startTime = 0; % seconds
minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;
maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(data1_ROI)-1))+1;
data1_ROI = data1_ROI(minIdx:maxIdx);
