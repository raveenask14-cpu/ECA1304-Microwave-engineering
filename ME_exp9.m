
clc;
clear;
close all;

% Microwave Impedance Matching and Frequency-Selective Filter

%% 1. Input parameters
f0 = 10e9;                    % Design frequency: 10 GHz
Z0 = 50;                      % Reference impedance: 50 ohms
ZL = 75 + 1j*25;              % Load impedance: 75+j25 ohms
fc = 10e9;                    % Filter cutoff: 10 GHz
fstart = 8e9;                 % Sweep start: 8 GHz
fstop = 12e9;                 % Sweep stop: 12 GHz

f = linspace(fstart,fstop,1001);
w = 2*pi*f;
w0 = 2*pi*f0;

%% 2. Design the impedance matching network
% Cancel the load's positive imaginary part using a series capacitor.
Rload = real(ZL);
Xload = imag(ZL);

Cmatch = 1/(w0*abs(Xload));
Zcomp = -1j./(w*Cmatch);
ZloadComp = ZL + Zcomp;

% Quarter-wave transformer
Zt = sqrt(Z0*Rload);
betaL = (pi/2)*(f/f0);

Zin = Zt.*(ZloadComp + 1j*Zt.*tan(betaL)) ./ ...
      (Zt + 1j*ZloadComp.*tan(betaL));

%% 3. Calculate reflection coefficient
GammaMatch = (Zin-Z0)./(Zin+Z0);
S11Match = 20*log10(max(abs(GammaMatch),1e-12));

% Unmatched load reflection
GammaLoad = (ZL-Z0)/(ZL+Z0);
S11Load = 20*log10(abs(GammaLoad));

%% 4. Calculate return loss and VSWR
ReturnLoss = -S11Match;
VSWR = (1+abs(GammaMatch))./max(1-abs(GammaMatch),1e-12);

%% 5. Frequency-selective Butterworth filter
filterOrder = 3;

H = 1./sqrt(1+(f/fc).^(2*filterOrder));
Filter_dB = 20*log10(max(H,1e-12));

%% 6. Display results
[~,idx] = min(abs(f-f0));

fprintf('MICROWAVE NETWORK DESIGN RESULTS\n');
fprintf('Design frequency = %.2f GHz\n',f0/1e9);
fprintf('Reference impedance = %.2f ohms\n',Z0);
fprintf('Load impedance = %.2f + j%.2f ohms\n', ...
    real(ZL),imag(ZL));
fprintf('Compensation capacitance = %.4f pF\n',Cmatch*1e12);
fprintf('Transformer impedance = %.4f ohms\n',Zt);
fprintf('Unmatched S11 = %.2f dB\n',S11Load);
fprintf('Matched S11 = %.2f dB\n',S11Match(idx));
fprintf('Return loss = %.2f dB\n',ReturnLoss(idx));
fprintf('VSWR = %.4f\n',VSWR(idx));

%% 7. Plot S11 comparison
figure;
plot(f/1e9,S11Load*ones(size(f)),'--','LineWidth',1.5);
hold on;
plot(f/1e9,S11Match,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('S11 (dB)');
title('Impedance Matching Performance');
legend('Unmatched Load','Matched Network');

%% 8. Plot return loss and VSWR
figure;

subplot(2,1,1);
plot(f/1e9,ReturnLoss,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Return Loss (dB)');
title('Return Loss');

subplot(2,1,2);
plot(f/1e9,VSWR,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('VSWR');
title('Voltage Standing Wave Ratio');

%% 9. Plot filter response
figure;
plot(f/1e9,Filter_dB,'LineWidth',1.5);
hold on;
yline(-3.0103,'--','-3 dB');
grid on;
xlabel('Frequency (GHz)');
ylabel('Magnitude (dB)');
title('Third-Order Butterworth Filter Response');
legend('Filter Response','-3 dB Reference');

%% 10. Plot input impedance
figure;

subplot(2,1,1);
plot(f/1e9,real(Zin),'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Real Impedance (ohms)');
title('Input Impedance - Real Part');

subplot(2,1,2);
plot(f/1e9,imag(Zin),'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Imaginary Impedance (ohms)');
title('Input Impedance - Imaginary Part');
