
clc;
clear;
close all;

% Microwave Radar Target Detection and Range Estimation

%% 1. Input parameters
c = 299792458;
fc = 10e9;                 % Carrier frequency: 10 GHz
Rtrue = 1000;              % Target range: 1000 m
Pt_dBm = 20;               % Transmit power: 20 dBm
NF_dB = 5;                 % Receiver noise figure: 5 dB
B = 10e6;                  % Bandwidth: 10 MHz

lambda = c/fc;
Pt = 10^((Pt_dBm-30)/10);

%% 2. Assumed radar parameters
Gt_dBi = 20;               % Transmit antenna gain (assumed)
Gr_dBi = 20;               % Receive antenna gain (assumed)
sigma = 1;                 % Target RCS in m^2 (assumed)
Lsys_dB = 3;               % System losses (assumed)

Gt = 10^(Gt_dBi/10);
Gr = 10^(Gr_dBi/10);
Lsys = 10^(Lsys_dB/10);

%% 3. Calculate delay and range resolution
tau = 2*Rtrue/c;
rangeResolution = c/(2*B);

fprintf('MICROWAVE RADAR SIMULATION\n');
fprintf('Carrier frequency = %.2f GHz\n',fc/1e9);
fprintf('Wavelength = %.4f m\n',lambda);
fprintf('Target range = %.2f m\n',Rtrue);
fprintf('Round-trip delay = %.4f microseconds\n',tau*1e6);
fprintf('Range resolution = %.2f m\n',rangeResolution);

%% 4. Calculate received power
Pr = Pt*Gt*Gr*lambda^2*sigma / ...
    ((4*pi)^3*Rtrue^4*Lsys);
Pr_dBm = 10*log10(Pr)+30;

%% 5. Calculate receiver noise power
k = 1.380649e-23;
T0 = 290;
F = 10^(NF_dB/10);

Pn = k*T0*B*F;
Pn_dBm = 10*log10(Pn)+30;
SNR_dB = Pr_dBm-Pn_dBm;

fprintf('\nRADAR LINK BUDGET\n');
fprintf('Received power = %.2f dBm\n',Pr_dBm);
fprintf('Receiver noise power = %.2f dBm\n',Pn_dBm);
fprintf('Estimated SNR = %.2f dB\n',SNR_dB);

%% 6. Generate transmitted LFM radar pulse
fs = 40e6;                 % Baseband sampling rate
Tp = 20e-6;                % Assumed pulse duration
t = (0:1/fs:Tp-1/fs).';

tx = exp(1j*pi*(B/Tp)*(t-Tp/2).^2);
tx = tx/sqrt(mean(abs(tx).^2));

%% 7. Simulate delayed target echo and noise
delaySamples = round(tau*fs);
Npulse = length(tx);
rxLength = delaySamples+Npulse+round(5e-6*fs);

rx = zeros(rxLength,1);
noiseVar = 10^(-SNR_dB/10);

rx(delaySamples+(1:Npulse)) = tx;

noise = sqrt(noiseVar/2)* ...
    (randn(rxLength,1)+1j*randn(rxLength,1));

rx = rx+noise;

%% 8. Apply matched filter
mf = conj(flipud(tx));
pc = conv(rx,mf);

rangeAxis = ((0:length(pc)-1)-(Npulse-1))*c/(2*fs);

valid = rangeAxis >= 0;
rangePos = rangeAxis(valid);
pcPos = pc(valid);

pc_dB = 20*log10(abs(pcPos)/max(abs(pcPos))+1e-12);

%% 9. Estimate target range
search = rangePos >= 0 & rangePos <= 2000;
rangeSearch = rangePos(search);
pcSearch = abs(pcPos(search));

[peakValue,peakIdx] = max(pcSearch);
Rest = rangeSearch(peakIdx);

fprintf('\nTARGET DETECTION RESULTS\n');
fprintf('True range = %.2f m\n',Rtrue);
fprintf('Estimated range = %.2f m\n',Rest);
fprintf('Range error = %.2f m\n',Rest-Rtrue);
fprintf('Range resolution = %.2f m\n',rangeResolution);

%% 10. Plot transmitted pulse
figure;
plot(t*1e6,real(tx));
grid on;
xlabel('Time (microseconds)');
ylabel('Amplitude');
title('Transmitted LFM Radar Pulse');

%% 11. Plot received signal
tRx = (0:rxLength-1)/fs;

figure;
plot(tRx*1e6,abs(rx));
hold on;
xline(tau*1e6,'--','Expected echo delay');
grid on;
xlabel('Time (microseconds)');
ylabel('Magnitude');
title('Received Radar Signal with Noise');

%% 12. Plot range profile
figure;
plot(rangePos,pc_dB,'LineWidth',1.3);
hold on;
xline(Rtrue,'--','True target range');
xline(Rest,':','Estimated range');
grid on;
xlabel('Range (m)');
ylabel('Normalized magnitude (dB)');
title('Matched-Filter Range Profile');
xlim([0 2000]);

%% 13. Plot detection region
figure;
plot(rangeSearch,pcSearch/max(pcSearch),'LineWidth',1.3);
hold on;
xline(Rtrue,'--','True range');
grid on;
xlabel('Range (m)');
ylabel('Normalized magnitude');
title('Target Detection');
xlim([Rtrue-150 Rtrue+150]);

%% 14. Final summary
fprintf('\nPERFORMANCE SUMMARY\n');
fprintf('Carrier frequency = %.2f GHz\n',fc/1e9);
fprintf('Bandwidth = %.2f MHz\n',B/1e6);
fprintf('Noise figure = %.2f dB\n',NF_dB);
fprintf('Transmit power = %.2f dBm\n',Pt_dBm);

fprintf('\nNote: Antenna gains, target RCS, and system losses\n');
fprintf('are assumed. This is a system-level simulation.\n');
