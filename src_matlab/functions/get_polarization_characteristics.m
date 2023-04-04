function [sense_of_rotation, tile_angle, axial_ratio, phase_difference] ...
    = get_polarization_characteristics(data0, data1)
%GET_POLARIZATION_CHARACTERISTICS calculate characteristics of the polarization ellipse
%   calculate sense of rotation, tilt angle and axial ratio of the polarization ellipse
%   calculate phase difference between data0 and data1


% 估计相位差（相关法）
data_corr = xcorr(data0, data1);
data_corr_abs = abs(data_corr);
corr_max = data_corr(data_corr_abs == max(data_corr_abs));
phase_difference = angle(corr_max / abs(corr_max));

% 判断极化电磁波旋向
if (0 < phase_difference) && (phase_difference < pi)
    sense_of_rotation = +1;
elseif ((-pi < phase_difference) && (phase_difference < 0))
    sense_of_rotation = -1;
else
    sense_of_rotation = 0;
end

% 计算双通道幅值
data0_am = max(real(data0)) - min(real(data0)) / 2;
data1_am = max(real(data1)) - min(real(data1)) / 2;

% 计算极化倾角
tile_angle = 0.5 * atan( ...
	(2 * data0_am * data1_am * cos(phase_difference)) ...
	/ (data0_am^2 - data1_am^2) ...
    );

% 计算长短轴
a = data0_am^2 * cos(tile_angle)^2 ...
    + data0_am * data1_am * sin(2 * tile_angle) * cos(phase_difference) ...
    + data1_am^2 * sin(tile_angle)^2;
b = data0_am^2 * sin(tile_angle)^2 ...
    - data0_am * data1_am * sin(2 * tile_angle) * cos(phase_difference) ...
    + data1_am^2 * cos(tile_angle)^2;
if a < b
    c = a;
    a = b;
    b = c;
    % 改变倾角取值范围
    if tile_angle > 0
        tile_angle = tile_angle - pi/2;
    else
        tile_angle = tile_angle + pi/2;
    end
end

% 计算极化轴比
axial_ratio = sqrt(a / b);

end

