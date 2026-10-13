
clc;
clear;
close all;

% Microwave Directional Coupler and Two-Way Power Divider
% S-Parameter Characterization

%% 1. Frequency setup
f = linspace(1e9,10e9,501);
fGHz = f/1e9;
f0 = 5.5e9;
x = (f-f0)/f0;

%% 2. Directional coupler model
C_dB = 10;
k0 = 10^(-C_dB/20);

k = k0.*exp(-0.5*(x/0.45).^2);
t = sqrt(1-k.^2);

S11_DC = 0.015+0.10*abs(x);
S21_DC = t;
S31_DC = 1i*k;
S41_DC = 0.005+0.06*abs(x);

S11_DC_dB = 20*log10(abs(S11_DC));
S21_DC_dB = 20*log10(abs(S21_DC));
S31_DC_dB = 20*log10(abs(S31_DC));
S41_DC_dB = 20*log10(abs(S41_DC));

%% 3. Two-way power divider model
bandResponse = exp(-0.5*(x/0.55).^2);

S11_PD = 0.02+0.12*abs(x);
S21_PD = (1/sqrt(2))*bandResponse.*exp(-1i*pi/2*(f/f0));
S31_PD = (1/sqrt(2))*bandResponse.*exp(-1i*pi/2*(f/f0));
S23_PD = 0.01+0.08*abs(x);

S11_PD_dB = 20*log10(abs(S11_PD));
S21_PD_dB = 20*log10(abs(S21_PD));
S31_PD_dB = 20*log10(abs(S31_PD));
S23_PD_dB = 20*log10(abs(S23_PD));

%% 4. Display center-frequency results
[~,idx] = min(abs(f-f0));

fprintf('CENTER FREQUENCY = %.2f GHz\n',f(idx)/1e9);
fprintf('\nDIRECTIONAL COUPLER\n');
fprintf('S11 = %.2f dB\n',S11_DC_dB(idx));
fprintf('S21 = %.2f dB\n',S21_DC_dB(idx));
fprintf('S31 = %.2f dB\n',S31_DC_dB(idx));
fprintf('S41 = %.2f dB\n',S41_DC_dB(idx));

fprintf('\nTWO-WAY POWER DIVIDER\n');
fprintf('S11 = %.2f dB\n',S11_PD_dB(idx));
fprintf('S21 = %.2f dB\n',S21_PD_dB(idx));
fprintf('S31 = %.2f dB\n',S31_PD_dB(idx));
fprintf('S23 = %.2f dB\n',S23_PD_dB(idx));

%% 5. Directional coupler S-parameters
figure;
plot(fGHz,S11_DC_dB,'LineWidth',1.5);
hold on;
plot(fGHz,S21_DC_dB,'LineWidth',1.5);
plot(fGHz,S31_DC_dB,'LineWidth',1.5);
plot(fGHz,S41_DC_dB,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Magnitude (dB)');
title('Directional Coupler S-Parameters');
legend('S11 Reflection','S21 Through', ...
       'S31 Coupling','S41 Isolation','Location','best');

%% 6. Power divider S-parameters
figure;
plot(fGHz,S11_PD_dB,'LineWidth',1.5);
hold on;
plot(fGHz,S21_PD_dB,'LineWidth',1.5);
plot(fGHz,S31_PD_dB,'LineWidth',1.5);
plot(fGHz,S23_PD_dB,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Magnitude (dB)');
title('Two-Way Power Divider S-Parameters');
legend('S11 Reflection','S21 Output 1', ...
       'S31 Output 2','S23 Output Isolation', ...
       'Location','best');

%% 7. Output power division comparison
figure;
plot(fGHz,S21_PD_dB,'LineWidth',1.5);
hold on;
plot(fGHz,S31_PD_dB,'--','LineWidth',1.5);
yline(-3.0103,':','Ideal equal split');
grid on;
xlabel('Frequency (GHz)');
ylabel('Transmission (dB)');
title('Power Divider Output Balance');
legend('S21','S31','Ideal -3.01 dB','Location','best');

%% 8. Return loss and VSWR
RL_DC = -S11_DC_dB;
RL_PD = -S11_PD_dB;

VSWR_DC = (1+abs(S11_DC))./(1-abs(S11_DC));
VSWR_PD = (1+abs(S11_PD))./(1-abs(S11_PD));

figure;

subplot(2,1,1);
plot(fGHz,RL_DC,'LineWidth',1.5);
hold on;
plot(fGHz,RL_PD,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Return Loss (dB)');
title('Return Loss Comparison');
legend('Directional Coupler','Power Divider');

subplot(2,1,2);
plot(fGHz,VSWR_DC,'LineWidth',1.5);
hold on;
plot(fGHz,VSWR_PD,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('VSWR');
title('VSWR Comparison');
legend('Directional Coupler','Power Divider');
