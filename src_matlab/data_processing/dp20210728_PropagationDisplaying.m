clc;
clear;
close all;

freq_samp = 32e3;
N = 512;

% output vedio
IF_Output_Vedio = false;


fileaddr = '.\20210728_Experiment_NewCirclePolarized\rawdata\';

% filename prefix
dataname_arr = [ ...
%     "data945_0", ...
%     "data945_15", ...
%     "data945_30", ...
%     "data945_45", ...
%     "data945_60", ...
%     "data945_75", ...
%     "data945_90", ...
    "data945", ...
    "data1575", ...
    "data2205" ...
];

datanum = length(dataname_arr);
phase_error_estimated_d = zeros(datanum, 1);

for i = 1 : datanum
    dataname = dataname_arr(i);

    % input data
    filename0 = strcat(dataname, '_rx0.dat');
    filename1 = strcat(dataname, '_rx1.dat');
    data0 = read_complex_binary(strcat(fileaddr, filename0));
    data1 = read_complex_binary(strcat(fileaddr, filename1));

    % intercept data
    data0 = data0(1 : N);
    data1 = data1(1 : N);

    % get axis range
    data0_real_min = min(real(data0));
    data0_real_max = max(real(data0));
    data1_real_min = min(real(data1));
    data1_real_max = max(real(data1));
    dreal_min = min(data0_real_min, data1_real_min);
    dreal_max = max(data0_real_max, data1_real_max);

    % estimate phase error between data0 and data1
    phase_error_estimated = phase_difference_estimate(data0, data1);
    phase_error_estimated_d(i) = 360 * phase_error_estimated / (2 * pi);

    % time domain to frequency domain
    [freqdomain0, ~] = time_to_frequency_domain(data0, freq_samp);
    [freqdomain1, freqlist] = time_to_frequency_domain(data1, freq_samp);

    % display time and freqency domain
    if IF_Output_Vedio ~= true
        dual_channel_signal_display(strcat(dataname, 'time&frequency domain'), ...
                                    data0, freqdomain0, freqlist, ...
                                    data1, freqdomain1, freqlist);
    end

    % output propagation vedio
    if IF_Output_Vedio == true
        videofilename = strcat('.\20210411_ExperimentResult\20210411', dataname, '_PropagationVedio');
        video = VideoWriter(videofilename, 'MPEG-4');   % default: 'Motion JPEG AVI'
        open(video);
    end

    display_length = 256;                   % length of data to display in 3-D figure
    x = 0 : 1/32 : display_length/32;       % timeline
    m0 = zeros(display_length + 1, 1);      % !!! must be 1-D array
    
    for t = 1 : N - display_length
        % update data
        Ex = real(data0(t : t + display_length));
        Ey = real(data1(t : t + display_length));

        % updata timeline
        x = x + 1/32;

        % display 3-D figure
        figure(i * 2)
        plot3(x, m0, m0, '--black', 'LineWidth', 2.0)   % axis
        hold on
        plot3(x, m0, Ex, 'green','LineWidth', 1.0)      % rx0 data
        hold on
        plot3(x, Ey, m0, 'cyan', 'LineWidth', 1.0)      % rx1 data
        hold on
        plot3(x, Ey, Ex, 'red', 'LineWidth', 2.0)       % polaried electromagnetic wave
        hold off

        title(dataname, 'fontsize',14)
        xlim([x(1) x(display_length + 1)])
        ylim([dreal_min-0.1 dreal_max+0.1])
        zlim([dreal_min-0.1 dreal_max+0.1])
        xlabel('Time(ms)')
        ylabel('rx1')
        zlabel('rx0')
        set(gca, 'fontsize', 12)
        set(gca,'YDir','reverse')   % Y-axis reverse
        grid;

        drawnow     % or "drawnow limitrate" when not output vedio

        if IF_Output_Vedio == true
            frame = getframe(gcf);
            writeVideo(video, frame);
        end

    end

    if IF_Output_Vedio == true
        close(video);
    end

end
