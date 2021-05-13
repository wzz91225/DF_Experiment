clc;
clear;
close all;

% ************************ BEGIN: parameters ************************

% output picture and vedio
IF_Output_Files = false;
OutputFileAddress = '.\OutputFile_PolarizedEMW\';
OutputFileName_PR = strcat(OutputFileAddress, '1');

% EMW frequency
freq = 1e4;

% sampling rate
samp_rate = 64 * freq;
% samp_rate = 32e3;

% polarization parameters
r = 1.00;                       % AR
rotation = +1;                  % LeftHand:+1 / RightHand:-1
delta_phi = 4/4 * pi;           % phase error [0, 2*pi)

Em = 1 * 1.00;                  % amplitude
Exm = Em * r / (r^2 + 1)^0.5;   % X-axis amplitude
Eym = Em / (r^2 + 1)^0.5;       % Y-axis amplitude

display_length = 4 * samp_rate / freq;     % 4 cycles
data_length = 1 * display_length;

axis_maxmin = max(Exm, Eym);
% axis_maxmin = 1.0;
% ************************ END: parameters ************************



% ************************ BEGIN: display 2-D figure ************************
% timeline
tl = 0 : 1/samp_rate : 1/freq;
% !!! must be 1-D array
a0 = zeros(size(tl));
Ex = Exm * cos(2 * pi * freq * tl);
Ey = Eym * cos(2 * pi * freq * tl + rotation * delta_phi);

% draw 2-D figure
figure(1)
set(gcf,'position',[100, 100, 500, 500]);
plot(Ex, a0, 'green','LineWidth', 1.5)
hold on
plot(a0, Ey, 'blue', 'LineWidth', 1.5)
hold on
plot(Ex, Ey, 'red', 'LineWidth', 3)
hold off
title('Electromagnetic Wave Polarization', 'fontsize', 14)
axis equal
axis([-axis_maxmin axis_maxmin -axis_maxmin axis_maxmin])
xlabel('X-axis')
ylabel('Y-axis')
grid;

% output picture
if IF_Output_Files == true
    exportgraphics(gcf, strcat(OutputFileName_PR, '.png'));	% , 'Resolution', 300
end
% ************************ END: display 2-D figure ************************


% ************************ BEGIN: display 3-D figure ************************
% timeline / Z-axis
tl = 0 : 1/samp_rate : display_length/samp_rate;
% !!! must be 1-D array
a0 = zeros(size(tl));

% output propagation vedio
if IF_Output_Files == true
    videofilename = strcat(OutputFileName_PR);
    video = VideoWriter(videofilename, 'MPEG-4');   % default: 'Motion JPEG AVI'
    open(video);
end

figure(2)
set(gcf,'position',[600, 100, 500, 500]);
for t = 0 : data_length - display_length
    % update data
    Ex = Exm * cos(2 * pi * freq * tl);
    Ey = Eym * cos(2 * pi * freq * tl + rotation * delta_phi);

    % updata timeline
    tl = tl + 1/samp_rate;

    
    % draw 3-D figure
    figure(2)
    plot3(tl, a0, a0, ':black', 'LineWidth', 2.0)	% axis
    hold on
    plot3(tl, Ex, a0, 'green','LineWidth', 1.0)     % Ex
    hold on
    plot3(tl, a0, Ey, 'blue', 'LineWidth', 1.0)     % Ey
    hold on
    plot3(tl, Ex, Ey, 'red', 'LineWidth', 2.0)      % electromagnetic wave
    hold off
    
    title('Polarized Electromagnetic Wave Propagation', 'fontsize',14)
%     axis equal
    axis([tl(1) tl(end) ...
        -axis_maxmin axis_maxmin -axis_maxmin axis_maxmin])
    xlabel('Time(s)')
    ylabel('X-axis')
    zlabel('Y-axis')
    set(gca, 'fontsize', 12)
    set(gca,'YDir','reverse')   % Y-axis reverse
    grid;
    
    if IF_Output_Files == true
        drawnow
    else
        drawnow limitrate
    end
    
    
    if IF_Output_Files == true
        frame = getframe(gcf);
        writeVideo(video, frame);
    end
end

if IF_Output_Files == true
    close(video);
end
% ************************ END: display 3-D figure ************************
