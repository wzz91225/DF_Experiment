function [phase_difference] = phase_difference_estimate(s1, s2)
% 相位差估计Δφ=φs1-φs2

data_corr = xcorr(s1, s2);
data_corr_abs = abs(data_corr);
corr_max = data_corr(data_corr_abs == max(data_corr_abs));
phase_difference = angle(corr_max / abs(corr_max));

end
