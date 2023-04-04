clc;
clear;
close all;

% ************************ BEGIN: parameters ************************
% sampling rate
samp_rate = 32e3;

% length of data
% data_length = 512;
data_length = 256;


InputFileAddress = './20210728_Experiment_NewCirclePolarized/rawdata/';
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


% output picture and video
IF_Output_Pictures = false;
IF_Output_Pictures_23D = false;
IF_Output_Video = false;
OutputFileAddress = './20210728_ExperimentResult/';

% length of data to display in 3-D figure
display_length = 100;

% only display dynamic figure when output video
if IF_Output_Video == false
    data_length = display_length;
end

% % axis range [-axis_maxmin, +axis_maxmin]
% axis_maxmin = 0.4;
% ************************ END: parameters ************************


datanum = length(dataname_arr);
sense_of_rotation = zeros(datanum, 1);
phase_difference = zeros(datanum, 1);
phase_difference_d = zeros(datanum, 1);
tile_angle = zeros(datanum, 1);
tile_angle_d = zeros(datanum, 1);
axial_ratio = zeros(datanum, 1);
a = zeros(datanum, 1);
b = zeros(datanum, 1);

% timeline
tl = 0 : 1/samp_rate : (display_length-1)/samp_rate;       % timeline
% !!! must be 1-D array
a0 = zeros(size(tl));


for i = 1 : datanum
    dataname = dataname_arr(i);


    % input data
    filename0 = strcat(dataname, '_rx0.dat');
    filename1 = strcat(dataname, '_rx1.dat');
    data0 = read_complex_binary(strcat(InputFileAddress, filename0));
    data1 = read_complex_binary(strcat(InputFileAddress, filename1));

    % intercept data
    data0 = data0(1 : data_length);
    data1 = data1(1 : data_length);

    % get axis range
    data0_real_min = min(real(data0));
    data0_real_max = max(real(data0));
    data1_real_min = min(real(data1));
    data1_real_max = max(real(data1));
    dreal_min = min(data0_real_min, data1_real_min);
    dreal_max = max(data0_real_max, data1_real_max);

    
    [sense_of_rotation(i), tile_angle(i), axial_ratio(i), phase_difference(i)] = ...
        get_polarization_characteristics(data0, data1);
        
    tile_angle_d(i) = radiam2angle(tile_angle(i));
    phase_difference_d(i) = radiam2angle(phase_difference(i));
    

    % % time domain to frequency domain
    % [freqdomain0, ~] = time_to_frequency_domain(data0, freq_samp);
    % [freqdomain1, freqlist] = time_to_frequency_domain(data1, freq_samp);

    % % display time and freqency domain
    % if IF_Output_Vedio ~= true
    %     dual_channel_signal_display(strcat(dataname, 'time&frequency domain'), ...
    %                                 data0, freqdomain0, freqlist, ...
    %                                 data1, freqdomain1, freqlist);
    % end

    figure(2 * datanum + i)
    set(gcf,'position',[100, 500, 1000, 500]);

    % ************************ BEGIN: display 2-D figure ************************
    Ex = real(data0);
    Ey = real(data1);
    Em = sqrt(Ex.^2 + Ey.^2);

    % a1 = -axis_maxmin : 2*axis_maxmin*freq/samp_rate : axis_maxmin;
    
    % 根据长半轴和短半轴计算椭圆偏心率
    a(i) = max(Em);
    b(i) = a(i) / axial_ratio(i);
    ecc = axes2ecc(a(i), a(i) / axial_ratio(i));
    [elat, elon] = ellipse1(0, 0, [a(i) ecc], tile_angle_d(i));
    ellipse_max = max(max(elat), max(elon));
    ellipse_min = min(min(elat), min(elon));
    
    
    figure(2 * datanum + i)
    subplot(1, 2, 1)
    plot(Ex, Ey, '.black')
    hold on
    plot(elat, elon, 'black', 'LineWidth', 2.0)
    hold off
    axis equal
    axis([ellipse_min ellipse_max ellipse_min ellipse_max])
    xlabel('Ex')
    ylabel('Ey')
    legend('实际合成电场', '解得极化椭圆')
    legend('Location', 'southoutside')
    title(dataname)
    grid;
    
    
%     % draw 2-D figure
%     figure(i*2-1)
%     set(gcf,'position',[100, 100, 600, 500]);
%     % plot(a1, a0, '--black','LineWidth', 1.5)
%     % hold on
%     % plot(a0, a1, '-.black', 'LineWidth', 1.5)
%     % hold on
%     plot(Ex, Ey, '.black')
%     hold on
%     plot(elat, elon, 'black', 'LineWidth', 2.0)
%     hold off
%     axis equal
%     axis([ellipse_min ellipse_max ellipse_min ellipse_max])
%     xlabel('Ex')
%     ylabel('Ey')
%     % legend('电场分量Ex', '电场分量Ey', '合成电场E')
%     legend('实际合成电场', '解得极化椭圆')
%     legend('Location', 'eastoutside')
%     grid;
% 
%     % output 2-D picture
%     if IF_Output_Pictures == true
%         exportgraphics(gcf, strcat(OutputFileAddress, dataname, '_2D.png'));	% , 'Resolution', 300
%     end
    % ************************ END: display 2-D figure ************************


    % ************************ BEGIN: display 3-D figure ************************
    % output propagation video
    if IF_Output_Video == true
        videofilename = strcat(OutputFileAddress, dataname);
        video = VideoWriter(videofilename, 'MPEG-4');   % default: 'Motion JPEG AVI'
        open(video);
    end

%     figure(i*2)
%     set(gcf,'position',[700, 100, 700, 500]);
    for a1 = 1 : data_length - display_length + 1
        % update data
        Ex = real(data0(a1 : a1 + display_length - 1));
        Ey = real(data1(a1 : a1 + display_length - 1));

        % updata timeline
        tl = tl + 1/samp_rate;
        
        if a1 == 1
            figure(2 * datanum + i)
            subplot(1, 2, 2)
            plot3(tl, a0, a0, ':black', 'LineWidth', 1.5)	% axis
            hold on
            plot3(tl, Ex, a0, '--black','LineWidth', 1.0)     % Ex
            hold on
            plot3(tl, a0, Ey, '-.black', 'LineWidth', 1.0)     % Ey
            hold on
            plot3(tl, Ex, Ey, 'black', 'LineWidth', 2.0)      % electromagnetic wave(EMW)
            hold off
            axis([tl(1) tl(end) ...
                dreal_min dreal_max dreal_min dreal_max])
            xlabel('时间(s)')
            ylabel('Ex')
            zlabel('Ey')
%             legend('传播方向z轴', '电场分量Ex', '电场分量Ey', '合成电场E')
%             legend('Location', 'southoutside')
%             set(gca, 'fontsize', 12)
            set(gca,'YDir','reverse')   % Y-axis reverse
%             title(strcat('移相', num2str(-180+(i-1)*45), '°电磁波传播'))
            grid;
    
            % output 2-D&3-D picture
            if IF_Output_Pictures_23D == true
                exportgraphics(gcf, strcat(OutputFileAddress, dataname, '_23Dtmp.png'));	% , 'Resolution', 300
            end
        end
        
%         % draw 3-D figure
%         figure(i*2)
%         plot3(tl, a0, a0, ':black', 'LineWidth', 1.5)	% axis
%         hold on
%         plot3(tl, Ex, a0, '--black','LineWidth', 1.0)     % Ex
%         hold on
%         plot3(tl, a0, Ey, '-.black', 'LineWidth', 1.0)     % Ey
%         hold on
%         plot3(tl, Ex, Ey, 'black', 'LineWidth', 2.0)      % electromagnetic wave(EMW)
%         hold off
%         
%     %     axis equal
%         axis([tl(1) tl(end) ...
%             dreal_min dreal_max dreal_min dreal_max])
%         xlabel('时间(s)')
%         ylabel('Ex')
%         zlabel('Ey')
%         legend('传播方向z轴', '电场分量Ex', '电场分量Ey', '合成电场E')
%         legend('Location', 'eastoutside')
%         set(gca, 'fontsize', 12)
%         set(gca,'YDir','reverse')   % Y-axis reverse
%         grid;
%         
%         % make display smoothly when not output video 
%         if IF_Output_Video == true
%             drawnow
%         else
%             drawnow limitrate
%         end
% 
%         
%         % output 3-D picture
%         if IF_Output_Pictures == true && a1 == 1
%             exportgraphics(gcf, strcat(OutputFileAddress, dataname, '_3D.png'));	% , 'Resolution', 300
%         end
%         
%         % output video
%         if IF_Output_Video == true
%             frame = getframe(gcf);
%             writeVideo(video, frame);
%         end
    end

    % finish video output
    if IF_Output_Video == true
        close(video);
    end
    % ************************ END: display 3-D figure ************************


end
