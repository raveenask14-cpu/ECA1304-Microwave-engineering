
clc;
clear;
close all;

% Microwave Semiconductor Devices and Mixer Simulation

%% 1. Simulation parameters
fRF = 2.4e9;
fLO = 2.3e9;
fs = 20e9;
T = 2e-6;
t = 0:1/fs:T-1/fs;

ARF = 0.5;
ALO = 0.8;
fIF = abs(fRF-fLO);

%% 2. Generate RF and LO signals
RF = ARF*cos(2*pi*fRF*t);
LO = ALO*cos(2*pi*fLO*t);

%% 3. Mixer operation
mixerOut = RF.*LO;

%% 4. Calculate mixer output spectrum
N = length(t);
Y = fft(mixerOut);
P2 = abs(Y/N);
P1 = P2(1:floor(N/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
freq = fs*(0:floor(N/2))/N;

%% 5. Extract intermediate frequency
fc = 300e6;
alpha = exp(-2*pi*fc/fs);
IFout = filter(1-alpha,[1 -alpha],mixerOut);

%% 6. Calculate IF spectrum
Yif = fft(IFout);
P2if = abs(Yif/N);
P1if = P2if(1:floor(N/2)+1);
P1if(2:end-1) = 2*P1if(2:end-1);

%% 7. Display results
fprintf('RF Frequency = %.2f GHz\n',fRF/1e9);
fprintf('LO Frequency = %.2f GHz\n',fLO/1e9);
fprintf('IF Frequency = %.2f MHz\n',fIF/1e6);
fprintf('Sum Frequency = %.2f GHz\n',(fRF+fLO)/1e9);

%% 8. RF and LO signals
figure;
subplot(2,1,1);
plot(t*1e9,RF);
grid on;
xlabel('Time (ns)');
ylabel('Amplitude');
title('RF Input Signal');

subplot(2,1,2);
plot(t*1e9,LO);
grid on;
xlabel('Time (ns)');
ylabel('Amplitude');
title('Local Oscillator Signal');

%% 9. Mixer output and IF output
figure;
subplot(2,1,1);
plot(t*1e9,mixerOut);
grid on;
xlabel('Time (ns)');
ylabel('Amplitude');
title('Mixer Output');

subplot(2,1,2);
plot(t*1e9,IFout);
grid on;
xlabel('Time (ns)');
ylabel('Amplitude');
title('Filtered IF Output');

%% 10. Mixer output spectrum
figure;
plot(freq/1e9,20*log10(max(P1,1e-12)));
grid on;
xlabel('Frequency (GHz)');
ylabel('Magnitude (dB)');
title('Mixer Output Spectrum');
xlim([0 5]);

%% 11. IF spectrum
figure;
plot(freq/1e6,20*log10(max(P1if,1e-12)));
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('Intermediate Frequency Spectrum');
xlim([0 600]);

%% 12. Semiconductor diode I-V characteristic
V = linspace(-0.5,0.8,500);
Is = 1e-12;
n = 1.5;
Vt = 0.02585;

I = Is*(exp(min(V/(n*Vt),40))-1);

figure;
plot(V,I,'LineWidth',1.5);
grid on;
xlabel('Diode Voltage (V)');
ylabel('Diode Current (A)');
title('Semiconductor Diode I-V Characteristic');

%% 13. Illustrative conversion loss
conversionLoss_dB = 7;

fprintf('\nAssumed Conversion Loss = %.2f dB\n', ...
    conversionLoss_dB);
fprintf('Conversion loss is illustrative, not measured.\n');
