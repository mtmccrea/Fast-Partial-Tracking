% ********************************************************************* %
% Demo of fast partial tracking, synthesis, read and write functions.
%
% Reference:
% 
% J. Neri and P. Depalle, "Fast Partial Tracking of Audio with Real-Time
% Capability through Linear Programming", In Proceedings of the 21st
% International Conference on Digital Audio Effects (DAFx-18), Aveiro,
% Portugal, pp. 325-333, Sep. 2018.
%
% Julian Neri, 180914
% McGill University, Montreal, Canada
% ********************************************************************* %

clc;clear;close all;
addpath('utilities')

% Input audio
input_filename = 'demo_sound.wav';

[x, fs] = audioread(input_filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis Window Length
N = 2^11-1; 
% Oversampling Factor
OverSample = 2;
% Hop Size Factor (HopSize = N/HopFactor)
HopFactor = 4;
% Magnitude Threshold for Peak-Picking (dB)
Peak_dB = -50;
% Polynomial Order Q of the short-term sinusoidal model
% 1 = Frequency, Damping
% 2 = Frequency Derivative, Damping Derivative
% 3 = Frequency 2nd Derivative, Damping 2nd Derivative, and so on..
Q = 2;
% These parameters control the assignment cost function
delta = .2; % 0<delta<1
zeta_f = 50; % Hz
zeta_a = 15; % dB


%%%%%%%%%%%%%%%%%%%%%%%%% PARTIAL TRACKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Partials, time, padding, L, S] = jun_track_partials(x,fs,...
    N,HopFactor,OverSample,Peak_dB,Q,delta,zeta_f,zeta_a);

disp('Completed tracking');

% Can also read partials from file
[Partials, time, padding, L, fs, num_tracks] = jun_read_partials('demo_partials.bin');

%%%%%%%%%%%%%%%%%%%%%%%%% PARTIAL SYNTHESIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
y = jun_synthesize_partials(Partials,time,L+sum(padding));

disp('Completed synthesis');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove zero-padding
y = y(padding(1)+1:end-padding(2)); 
RSNR = snr(x,x-y);
fprintf('\nR-SNR = %4.2f dB\n\n',RSNR);

% Play the synthesized sound
soundsc(y,fs)

% Plots
figure('pos',[0 1000 500 500]);
subplot(4,1,1)
plot((1:L)/fs, x,'k', (1:L)/fs, y, 'r');
axis([0 inf -inf inf]); grid on; box on;
subplot(4,1,2:4);
% Plots Partials and Spectrogram
jun_plot_partials(Partials,time-padding(1),fs, num_tracks);
% Plot Spectrogram
hold on
Ndft = size(S,1);
f = fs*(0:Ndft-1)'/(Ndft);
f = f(1:Ndft/2);
Smag = abs(S(1:Ndft/2,:)); Smag = Smag/max(Smag(:));
h = imagesc((time-padding(1))/fs, f, 20*log10(Smag));
uistack(h,'bottom');
cmap = colormap('gray'); caxis([-100 inf]); box on; grid on; axis xy;
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
axis([0 L/fs -inf 5e3]);






