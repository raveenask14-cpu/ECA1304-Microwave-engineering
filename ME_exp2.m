
clc;
clear;
close all;

% Numerical Simulation and Performance Analysis of Microwave
% Transmission Lines and Two-Port Networks Using Scattering Parameters

%% 1. Define simulation parameters
Z0 = 50;                    % Port/reference impedance in ohms
Zline = 75;                 % Transmission-line impedance in ohms
lineLength = 0.10;          % Line length in metres
c = 3e8;                    % Speed of light in m/s
er = 2.2;                   % Relative permittivity
vp = c/sqrt(er);            % Phase velocity
f = linspace(1e9, 10e9, 501);
w = 2*pi*f;
beta = w/vp;                % Phase constant

%% 2. Calculate ABCD parameters
A = cos(beta*lineLength);
B = 1j*Zline.*sin(beta*lineLength);
C = 1j*(1/Zline).*sin(beta*lineLength);
D = cos(beta*lineLength);

%% 3. Calculate S-parameters
den = A + B/Z0 + C*Z0 + D;
S11 = (A + B/Z0 - C*Z0 - D)./den;
S21 = 2./den;
S12 = 2*(A.*D - B.*C)./den;
S22 = (-A + B/Z0 - C*Z0 + D)./den;

%% 4. Calculate performance parameters
S11_dB = 20*log10(max(abs(S11),1e-12));
S21_dB = 20*log10(max(abs(S21),1e-12));
S12_dB = 20*log10(max(abs(S12),1e-12));
S22_dB = 20*log10(max(abs(S22),1e-12));

ReturnLoss = -S11_dB;
gamma = abs(S11);
VSWR = (1+gamma)./max(1-gamma,1e-12);

%% 5. Display results at 5 GHz
[~,idx] = min(abs(f-5e9));

fprintf('MICROWAVE TWO-PORT NETWORK ANALYSIS\n');
fprintf('Frequency: %.2f GHz\n',f(idx)/1e9);
fprintf('S11: %.4f dB\n',S11_dB(idx));
fprintf('S21: %.4f dB\n',S21_dB(idx));
fprintf('S12: %.4f dB\n',S12_dB(idx));
fprintf('S22: %.4f dB\n',S22_dB(idx));
fprintf('Return Loss: %.4f dB\n',ReturnLoss(idx));
fprintf('VSWR: %.4f\n',VSWR(idx));

%% 6. Plot all four S-parameters
figure;
plot(f/1e9,S11_dB,'LineWidth',1.5);
hold on;
plot(f/1e9,S21_dB,'LineWidth',1.5);
plot(f/1e9,S12_dB,'--','LineWidth',1.5);
plot(f/1e9,S22_dB,'--','LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('S-parameter Magnitude (dB)');
title('S-Parameter Analysis of Microwave Transmission Line');
legend('S11','S21','S12','S22','Location','best');

%% 7. Plot return loss and VSWR
figure;

subplot(2,1,1);
plot(f/1e9,ReturnLoss,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Return Loss (dB)');
title('Return Loss versus Frequency');

subplot(2,1,2);
plot(f/1e9,VSWR,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('VSWR');
title('VSWR versus Frequency');

%% 8. Plot reflection coefficient
figure;
plot(f/1e9,abs(S11),'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('|S11|');
title('Input Reflection Coefficient');
ylim([0 1]);

%% 9. Check network reciprocity
fprintf('\nNETWORK VERIFICATION\n');
fprintf('Reciprocity error: %.3e\n',abs(S21(idx)-S12(idx)));
fprintf('S21 and S12 should be equal for this reciprocal network.\n');
