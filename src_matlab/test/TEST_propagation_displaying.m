clc;
clear;
close all;

% ************************ BEGIN: parameters ************************

% output picture and vedio
IF_Output_Files = true;
OutputFileAddress = '.\OutputFile_PolarizedEMW\';
OutputFileName_PR = strcat(OutputFileAddress, '1');

samp_rate = 32e3;

% polarization parameters
r = 1.00;                       % AR
rotation = +1;                  % LeftHand:+1 / RightHand:-1
delta_phi = 1/4 * pi;           % phase error [0, 2*pi)

omega = 1e3;                    % angular frequency
Em = 1 * 0.80;                  % amplitude
Exm = Em * r / (r^2 + 1)^0.5;   % X-axis amplitude
Eym = Em / (r^2 + 1)^0.5;       % Y-axis amplitude

data_length = 512;
display_length = 256;
% ************************ END: parameters ************************



% ************************ BEGIN: display 2-D figure ************************
% timeline
tl = 0 : 1/samp_rate : samp_rate/omega;
% !!! must be 1-D array
a0 = zeros(samp_rate^2/omega + 1, 1);
Ex = Exm * cos(omega * tl);
Ey = Eym * cos(omega * tl + rotation * delta_phi);

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
axis([-1 1 -1 1])
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
tl = 0 : 1e3/samp_rate : 1e3*display_length/samp_rate;
% !!! must be 1-D array
a0 = zeros(display_length + 1, 1);

% output propagation vedio
if IF_Output_Files == true
    videofilename = strcat(OutputFileName_PR);
    video = VideoWriter(videofilename, 'MPEG-4');   % default: 'Motion JPEG AVI'
    open(video);
end

figure(2)
set(gcf,'position',[600, 100, 500, 500]);
for t = 1 : data_length - display_length
    % update data
    Ex = Exm * cos(omega * tl);
    Ey = Eym * cos(omega * tl + rotation * delta_phi);

    % updata timeline
    tl = tl + 1e3/samp_rate;

    
    % draw 3-D figure
    figure(2)
    plot3(tl, a0, a0, '--black', 'LineWidth', 2.0)	% axis
    hold on
    plot3(tl, a0, Ex, 'green','LineWidth', 1.0)     % Ex
    hold on
    plot3(tl, Ey, a0, 'blue', 'LineWidth', 1.0)     % Ey
    hold on
    plot3(tl, Ey, Ex, 'red', 'LineWidth', 2.0)      % electromagnetic wave
    hold off
    
    title('Polarized Electromagnetic Wave Propagation', 'fontsize',14)
%     axis equal
    axis([tl(1) tl(display_length + 1) -1 1 -1 1])
    xlabel('Time(ms)')
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
