% 
% Script to generate amplitude modulation 
% wrapping for a Plain-old-ACARS waveform.
% 
% (c) 20 Jan 2022
% Artturi Juvonen
% artturi@juvonen.eu
% 

pkg load signal

% Modulating signal generation
gen_msk_aju1                % gen_msk outputs an CPFSK vector @ 48 kHz

% Variable definitions
Ac = 64;                    % Carrier amplitude
f_s2 = 2;                   % Samples per carrier cycle, f_s2 = 2 equals 96 kHz

% Amplitude modulated waveform generation
cpfskR = kron(cpfsk,ones(1,f_s2)); % Generation of modulating signal
t = [0:1/f_s2:((length(cpfskR)-1)/f_s2)]; % Time vector
ct = Ac*cos(2*pi*t);        % Carrier signal waveform
AM = ct.*(1+cpfskR);        % Amplitude modulated wave

% Waveform scaling, filtering and resampling
cf_AM = Ac.*AM.-Ac;         % Scaling amplitude for subsequent int8 conversion
cf_AM = [cf_AM,zeros(1,(f_s*f_s2*2400)-length(cf_AM))]; % Append waveform with zeros
                            % to make the iq file waveform exactly 1,0 s in length
[b,a] = butter(2,0.0075);   % Low pass filtering leaves only an alias near DC
cf_AM = complex(filter(b,a,cf_AM)); % Complex low pass filtered AM waveform
cf_AM = resample(cf_AM,12,1); % Resampling the completed waveform from 96k to 1M152k

% Waveform saving as signed int8 IQ
interleaved = [int8(real(cf_AM)); int8(imag(cf_AM))]; % Interleaving I and Q samples
interleaved = interleaved(:); % Reshaping interleaved vector
fh = fopen('poa_1M152.cs8', 'w'); % File opening
fwrite(fh,interleaved,'int8'); % File writing
fclose(fh);                 % File closing