% 
% Script to generate a minimum shift keying
% A.K.A. continuous phase frequency shift
% keying for a Plain-old-ACARS waveform.
% 
% (c) 20 Jan 2022
% Artturi Juvonen
% artturi@juvonen.eu
% 
% Modified from work by:
% Krishna Sankar M (2021). Simulation of an MSK transmission (https://www.mathworks.com/matlabcentral/fileexchange/19404-simulation-of-an-msk-transmission), MATLAB Central File Exchange. Retrieved December 13, 2021.
% CC BY-NC 2.5 IN
% 

% Message content generation
gen_acars_msg_aju1          % gen_acars_msg_aju1 outputs line coded binary

N = length(bin_nrzs);       % Length of binary message
f_s = 20;                   % 20 samples per bit equals 2400 bd @ 48 kHz

% Phase shift generation for zeroes
ip = 2*bin_nrzs-2;          % Shift binary from 1...0 to 0...-2
fm = ip/4;                  % Corresponding phase shift
fmR = kron(fm,ones(1,f_s)); % Repeating vector to match sample rate

% Sampling instant generation
ts = [0:1/f_s:1];           % Time vector
ts = ts(1:end-1);           % Remove last instant
tsR = kron(ones(1,N),ts);   % Repeating vector to match sample rate

% Phase generation
theta = pi/2*filter([0 1],[1 -1],ip); % Phase vector
thetaR = kron(theta,ones(1,f_s)); % Repeating vector to match sample rate

% CPFSK waveform generation
cpfsk = cos(2*pi*(1+fmR).*tsR + thetaR);