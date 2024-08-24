close all
clear all
clc

[x, fs] = audioread('waveform.wav'); % change the file name to appropriate file
T = 1/fs;  % the time period from unknown waveform's frequency
sample_size = size(x,1);
max_time = (sample_size-1)/fs; % maximum time of the unknown sequence
t = 0:T:max_time; % setting up time vector
% Plot the waveform on the time domain
figure; subplot(2,1,1)
plot(t,x);
ylabel('Amplitude');
xlabel('Time (s)');
title('Unknown Sequence Waveform');
xlim('tight')
grid on

% Setting up to use FFT to identify peak frequencies of the waveform
N = 9;
frame_length = 2^N; % number of samples to process per frame, always power of 2 for FFT
% Calculate the number of blocks that need to be processed
number_of_frames = floor(sample_size/frame_length);

% array to store the data of the processed blocks
% This will hold frequency data against frame number
data_stored = zeros(frame_length, number_of_frames);
frame_start = 1;
for frame_number = 1:number_of_frames
    % extract the frames from the sequence
    frame = x(frame_start:frame_start+frame_length-1);
    % perform FFT on the sample block/frame
    frameFFT = abs(fft(frame));
    % store the FFT values in the row
    data_stored(:, frame_number) = frameFFT;
    frame_start = frame_start + frame_length; % point to the next set of samples
end

data_stored(data_stored<29)=0; % remove all low values/noise from set

% Setting up time and frequency data to match the matrix of data stored
% Time goes along the columns
sec_per_frame = max_time/number_of_frames;
time_stored = sec_per_frame*[1:frame_number];
% Frequency goes down along the rows
freq_per_frame_size = fs/frame_length;
frequency_stored = freq_per_frame_size*[1:frame_length]';

% Only need the frequencies in first half of spectrum, since second half 
% is just a mirror image
f_stored_one_sided = frequency_stored(1:end/2);
% Adjusting the total data set to match number of frequencies
% Time (along the columns) is unchanged
data_stored_one_sided = data_stored(1:end/2,:);

% Plot using a 3D plot function to incorporate correct x and y axes for
% FFT data set
subplot(2,1,2)
contour(time_stored, f_stored_one_sided, data_stored_one_sided,'LineWidth', 5);
view(0,90); % flatten the 3D plot to 2D
xlabel('Time (s)');
ylabel('Frequency (hz)');
title('Time-Frequency Distribution');
xticks([0:1:max_time]);
% Set the limit of frequencies shown based on the largest in the data set
[end_row, end_column] = find(data_stored_one_sided,1,'last'); 
max_freq = f_stored_one_sided(end_row+10);
ylim([0 max_freq])
yticks([0:100:max_freq]);
grid on
