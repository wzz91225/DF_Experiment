function [sense_of_rotation, tile_angle, axial_ratio, phase_difference] ...
    = get_polarization_characteristics(data0, data1)
%GET_POLARIZATION_CHARACTERISTICS calculate characteristics of the polarization ellipse
%   calculate sense of rotation, tilt angle and axial ratio of the polarization ellipse
%   calculate phase difference between data0 and data1


% estimate phase difference
% phase_difference = phase_difference_estimate(data0, data1);
data_corr = xcorr(data0, data1);
data_corr_abs = abs(data_corr);
corr_max = data_corr(data_corr_abs == max(data_corr_abs));
phase_difference = angle(corr_max / abs(corr_max));

if (0 < phase_difference) && (phase_difference < pi)
    sense_of_rotation = +1;
elseif ((-pi < phase_difference) && (phase_difference < 0))
    sense_of_rotation = -1;
else
    sense_of_rotation = 0;
end

% get peak-peak
data0_pp = max(real(data0)) - min(real(data0));
data1_pp = max(real(data1)) - min(real(data1));

% calculate tile angle (tau)
tile_angle = 0.5 * atan( ...
	(2 * data0_pp * data1_pp * cos(phase_difference)) ...
	/ (data0_pp^2 - data1_pp^2) ...
    );

% calculate axial ratio (AR)
sin(tile_angle)
cos(tile_angle)
sin(2 * tile_angle)
cos(phase_difference)
b = data0_pp^2 * cos(tile_angle)^2 ...
    + data0_pp * data1_pp * sin(2 * tile_angle) * cos(phase_difference) ...
    + data1_pp^2 * sin(tile_angle)^2;
a = data0_pp^2 * sin(tile_angle)^2 ...
    - data0_pp * data1_pp * sin(2 * tile_angle) * cos(phase_difference) ...
    + data1_pp^2 * cos(tile_angle)^2;
if a>b
    axial_ratio = sqrt(a / b);
else
    axial_ratio = sqrt(b / a);
end


end

