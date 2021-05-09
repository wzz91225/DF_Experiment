function [data_freqdomain,freqlist] = time_to_frequency_domain(data_timedomain,freq_samp)
% TIME_TO_FREQUENCY_DOMAIN 原始时域数据转频域

% 求数据长度
L = length(data_timedomain);

% fft结果幅值与长度有关，故除以长度，并对复数结果求绝对值
d_fft = abs(fft(data_timedomain) / L);

% 由于奈奎斯特准则，仅保留有效的单侧数据
data_freqdomain = d_fft(1 : L/2+1);

% 改为单侧数据后需将非零点幅值乘二则获得单侧幅值频谱
data_freqdomain(2 : end-1) = 2 * data_freqdomain(2 : end-1);

% 根据采样频率获得频率序列
freqlist = freq_samp * (0 : L/2) / L;

end

