clc;
clear;
close all;

% ************************ BEGIN: parameters ************************

% output picture and video
IF_Output_Pictures = false;
IF_Output_Video = false;
OutputFileAddress = '.\OutputFile_GraduationThesis\';
OutputFileName_PR = strcat(OutputFileAddress, 'tmp');

% EMW frequency
freq = 1e4;

% sampling rate
samp_rate = 64 * freq;

% polarization parameters
r = 1.00;                       % AR
rotation = +1;                  % LeftHand:+1 / RightHand:-1
delta_phi = 2/4 * pi;           % phase error [0, 2*pi)

Em = 1 * 1.00;                  % amplitude
Exm = Em * r / (r^2 + 1)^0.5;   % X-axis amplitude
Eym = Em / (r^2 + 1)^0.5;       % Y-axis amplitude

% display 4 cycles in figure
display_length = 4 * samp_rate / freq;

% only display dynamic figure when output video
if IF_Output_Video == true
    data_length = 2 * display_length;
else
    data_length = 1 * display_length;
end

% axis range [-axis_maxmin, +axis_maxmin]
axis_maxmin = max(Exm, Eym);
% ************************ END: parameters ************************



% ************************ BEGIN: display 2-D figure ************************
% timeline
tl = 0 : 1/samp_rate : 1/freq;
% !!! must be 1-D array
a0 = zeros(size(tl));
Ex = Exm * cos(2 * pi * freq * tl);
Ey = Eym * cos(2 * pi * freq * tl + rotation * delta_phi);

a1 = -axis_maxmin : 2*axis_maxmin*freq/samp_rate : axis_maxmin;

% draw 2-D figure
figure(1)
set(gcf,'position',[100, 100, 600, 500]);
% plot(a1, a0, '--magenta','LineWidth', 1.5)
plot(a1, a0, '--black','LineWidth', 1.5)
hold on
% plot(a0, a1, '-.blue', 'LineWidth', 1.5)
plot(a0, a1, '-.black', 'LineWidth', 1.5)
hold on
% plot(Ex, Ey, 'red', 'LineWidth', 3.0)
plot(Ex, Ey, 'black', 'LineWidth', 3.0)
hold off
% title('Electromagnetic Wave Polarization', 'fontsize', 14)
axis equal
axis([-axis_maxmin axis_maxmin -axis_maxmin axis_maxmin])
xlabel('Ex')
ylabel('Ey')
legend('电场分量Ex', '电场分量Ey', '合成电场E')
legend('Location', 'eastoutside')
grid;

% output 2-D picture
if IF_Output_Pictures == true
    exportgraphics(gcf, strcat(OutputFileName_PR, '_2D.png'));	% , 'Resolution', 300
end
% ************************ END: display 2-D figure ************************


% ************************ BEGIN: display 3-D figure ************************
% timeline / Z-axis
tl = 0 : 1/samp_rate : display_length/samp_rate;
% !!! must be 1-D array
a0 = zeros(size(tl));

% output propagation video
if IF_Output_Video == true
    videofilename = strcat(OutputFileName_PR);
    video = VideoWriter(videofilename, 'MPEG-4');   % default: 'Motion JPEG AVI'
    open(video);
end

figure(2)
set(gcf,'position',[700, 100, 700, 500]);
for a1 = 0 : data_length - display_length
    % update data
    Ex = Exm * cos(2 * pi * freq * tl);
    Ey = Eym * cos(2 * pi * freq * tl + rotation * delta_phi);

    % updata timeline
    tl = tl + 1/samp_rate;

    
    % draw 3-D figure
    figure(2)
    plot3(tl, a0, a0, ':black', 'LineWidth', 1.5)	% axis
    hold on
%     plot3(tl, Ex, a0, '--magenta','LineWidth', 1.0)     % Ex
    plot3(tl, Ex, a0, '--black','LineWidth', 1.0)     % Ex
    hold on
%     plot3(tl, a0, Ey, '-.blue', 'LineWidth', 1.0)     % Ey
    plot3(tl, a0, Ey, '-.black', 'LineWidth', 1.0)     % Ey
    hold on
%     plot3(tl, Ex, Ey, 'red', 'LineWidth', 2.0)      % electromagnetic wave(EMW)
    plot3(tl, Ex, Ey, 'black', 'LineWidth', 2.0)      % electromagnetic wave(EMW)
    hold off
    
%     title('Polarized Electromagnetic Wave Propagation', 'fontsize',14)
%     axis equal
    axis([tl(1) tl(end) ...
        -axis_maxmin axis_maxmin -axis_maxmin axis_maxmin])
    xlabel('时间(s)')
    ylabel('Ex')
    zlabel('Ey')
    legend('传播方向z轴', '电场分量Ex', '电场分量Ey', '合成电场E')
    legend('Location', 'eastoutside')
    set(gca, 'fontsize', 12)
    set(gca,'YDir','reverse')   % Y-axis reverse
    grid;
    
    % make display smoothly when not output video 
    if IF_Output_Video == true
        drawnow
    else
        drawnow limitrate
    end

    
    % output 3-D picture
    if IF_Output_Pictures == true && a1 == 0
        exportgraphics(gcf, strcat(OutputFileName_PR, '_3D.png'));	% , 'Resolution', 300
    end
    
    % output video
    if IF_Output_Video == true
        frame = getframe(gcf);
        writeVideo(video, frame);
    end
end

% finish video output
if IF_Output_Video == true
    close(video);
end
% ************************ END: display 3-D figure ************************
