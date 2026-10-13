
clc;
clear;
close all;

% Microwave Signal Spectral Analysis Using FFT

%% 1. Input parameters
fc = 10e9;             % Carrier frequency: 10 GHz
A = 1;                 % Carrier amplitude: 1 V
fm = 0.1e9;            % Modulating frequency: 100 MHz
mu = 0.5;              % Modulation index
fs = 50e9;             % Sampling frequency: 50 GHz

T = 10e-6;             % Observation time
t = 0:1/fs:T-1/fs;
N = length(t);

%% 2. Generate carrier and message signals
carrier = A*cos(2*pi*fc*t);
message = cos(2*pi*fm*t);

%% 3. Generate AM signal
amSignal = A*(1+mu*message).*cos(2*pi*fc*t);

%% 4. Plot time-domain signals
nShow = round(20e-9*fs);
tShort = t(1:nShow)*1e9;

figure;
subplot(2,1,1);
plot(tShort,carrier(1:nShow));
grid on;
xlabel('Time (ns)');
ylabel('Amplitude (V)');
title('10 GHz Carrier Signal');

subplot(2,1,2);
plot(tShort,amSignal(1:nShow));
grid on;
xlabel('Time (ns)');
ylabel('Amplitude (V)');
title('Amplitude-Modulated Microwave Signal');

%% 5. Calculate FFT spectrum
window = 0.5-0.5*cos(2*pi*(0:N-1)/(N-1));
Y = fft(amSignal.*window);

P2 = 2*abs(Y)/sum(window);
P1 = P2(1:floor(N/2)+1);
P1(1) = P1(1)/2;

if rem(N,2)==0
    P1(end) = P1(end)/2;
end

freq = fs*(0:floor(N/2))/N;
spectrum_dBV = 20*log10(max(P1,1e-12));

%% 6. Find carrier and sidebands
[~,iC] = min(abs(freq-fc));
[~,iL] = min(abs(freq-(fc-fm)));
[~,iU] = min(abs(freq-(fc+fm)));

fprintf('MICROWAVE SPECTRUM ANALYSIS\n');
fprintf('Carrier frequency = %.2f GHz\n',fc/1e9);
fprintf('Modulating frequency = %.2f MHz\n',fm/1e6);
fprintf('Modulation index = %.2f\n',mu);
fprintf('Sampling frequency = %.2f GHz\n',fs/1e9);
fprintf('Frequency resolution = %.2f kHz\n',fs/N/1e3);

fprintf('\nSPECTRAL COMPONENTS\n');
fprintf('Lower sideband = %.2f GHz, %.3f V\n', ...
    freq(iL)/1e9,P1(iL));
fprintf('Carrier = %.2f GHz, %.3f V\n', ...
    freq(iC)/1e9,P1(iC));
fprintf('Upper sideband = %.2f GHz, %.3f V\n', ...
    freq(iU)/1e9,P1(iU));

%% 7. Plot spectrum near the carrier
figure;
plot(freq/1e9,spectrum_dBV,'LineWidth',1.3);
grid on;
xlabel('Frequency (GHz)');
ylabel('Amplitude (dBV)');
title('Microwave Spectrum Analyzer Emulation');
xlim([9.5 10.5]);

%% 8. Plot wideband spectrum
figure;
plot(freq/1e9,spectrum_dBV,'LineWidth',1.3);
grid on;
xlabel('Frequency (GHz)');
ylabel('Amplitude (dBV)');
title('Wideband Microwave Signal Spectrum');
xlim([0 15]);

%% 9. Calculate theoretical bandwidth
BW = 2*fm;

fprintf('\nTheoretical AM bandwidth = %.2f MHz\n',BW/1e6);
fprintf('Lower sideband frequency = %.2f GHz\n',(fc-fm)/1e9);
fprintf('Upper sideband frequency = %.2f GHz\n',(fc+fm)/1e9);

%% 10. Save spectrum data
results = table(freq(:)/1e9,P1(:),spectrum_dBV(:), ...
    'VariableNames',{'Frequency_GHz','Amplitude_V','Amplitude_dBV'});

writetable(results,'microwave_spectrum_results.csv');

fprintf('Spectrum data saved to CSV file.\n');
