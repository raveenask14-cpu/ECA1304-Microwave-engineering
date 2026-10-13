
clc;
clear;
close all;

% Microwave Two-Port Network S-Parameter Analysis
% VNA Frequency-Domain Emulation

%% 1. Input parameters
fstart = 8e9;
fstop = 12e9;
Z0 = 50;
df = 0.01e9;

f = (fstart:df:fstop).';
fGHz = f/1e9;

%% 2. Define two-port network
% Illustrative DUT with resonance at 10 GHz
f0 = 10e9;
Q = 12;
x = f/f0-f0./f;

gammaMag = 0.08+0.55*(x.^2)./ ...
           (x.^2+(1/Q)^2);
gammaMag = min(gammaMag,0.95);

phase11 = -2*atan(Q*x);
S11 = gammaMag.*exp(1j*phase11);

S21mag = 0.90./sqrt(1+(Q*x).^2);
phase21 = -2*atan(Q*x);
S21 = S21mag.*exp(1j*phase21);

% Reciprocal and symmetric network assumption
S22 = S11;
S12 = S21;

%% 3. Calculate S-parameter magnitudes
S11dB = 20*log10(max(abs(S11),1e-12));
S21dB = 20*log10(max(abs(S21),1e-12));
S12dB = 20*log10(max(abs(S12),1e-12));
S22dB = 20*log10(max(abs(S22),1e-12));

%% 4. Return loss and VSWR
ReturnLoss = -S11dB;
gamma = abs(S11);
VSWR = (1+gamma)./max(1-gamma,1e-12);

%% 5. Calculate phase
S11phase = unwrap(angle(S11))*180/pi;
S21phase = unwrap(angle(S21))*180/pi;

%% 6. Display results
[~,idx] = min(abs(f-f0));
[minS11,idxMin] = min(S11dB);

fprintf('TWO-PORT NETWORK ANALYSIS\n');
fprintf('Start frequency = %.2f GHz\n',fstart/1e9);
fprintf('Stop frequency = %.2f GHz\n',fstop/1e9);
fprintf('Frequency step = %.3f GHz\n',df/1e9);
fprintf('Reference impedance = %.1f ohms\n',Z0);
fprintf('Frequency points = %d\n',length(f));

fprintf('\nRESULTS AT %.2f GHz\n',f(idx)/1e9);
fprintf('S11 = %.2f dB\n',S11dB(idx));
fprintf('S21 = %.2f dB\n',S21dB(idx));
fprintf('S12 = %.2f dB\n',S12dB(idx));
fprintf('S22 = %.2f dB\n',S22dB(idx));
fprintf('Return loss = %.2f dB\n',ReturnLoss(idx));
fprintf('VSWR = %.3f\n',VSWR(idx));

fprintf('\nMinimum S11 = %.2f dB\n',minS11);
fprintf('Frequency at minimum S11 = %.3f GHz\n', ...
    f(idxMin)/1e9);

%% 7. Plot S-parameter magnitudes
figure;
plot(fGHz,S11dB,'LineWidth',1.5);
hold on;
plot(fGHz,S21dB,'LineWidth',1.5);
plot(fGHz,S12dB,'--','LineWidth',1.5);
plot(fGHz,S22dB,'--','LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Magnitude (dB)');
title('Two-Port Network S-Parameters');
legend('S11','S21','S12','S22','Location','best');

%% 8. Plot return loss and VSWR
figure;

subplot(2,1,1);
plot(fGHz,ReturnLoss,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Return Loss (dB)');
title('Return Loss versus Frequency');

subplot(2,1,2);
plot(fGHz,VSWR,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('VSWR');
title('VSWR versus Frequency');

%% 9. Plot phase response
figure;

subplot(2,1,1);
plot(fGHz,S11phase,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Phase (degrees)');
title('S11 Phase Response');

subplot(2,1,2);
plot(fGHz,S21phase,'LineWidth',1.5);
grid on;
xlabel('Frequency (GHz)');
ylabel('Phase (degrees)');
title('S21 Phase Response');

%% 10. Reflection coefficient plot
theta = linspace(0,2*pi,500);

figure;
plot(cos(theta),sin(theta),'k:');
hold on;
plot(real(S11),imag(S11),'LineWidth',1.5);
plot(real(S22),imag(S22),'--','LineWidth',1.5);
axis equal;
grid on;
xlabel('Real(\Gamma)');
ylabel('Imaginary(\Gamma)');
title('Reflection Coefficient Plot');
legend('Unit circle','S11','S22');

%% 11. Save results to CSV
results = table(fGHz,S11dB,S21dB,S12dB,S22dB, ...
    ReturnLoss,VSWR,S11phase,S21phase);

results.Properties.VariableNames = ...
    {'Frequency_GHz','S11_dB','S21_dB','S12_dB', ...
     'S22_dB','ReturnLoss_dB','VSWR', ...
     'S11_Phase_deg','S21_Phase_deg'};

writetable(results,'two_port_sparameter_results.csv');

fprintf('\nResults saved to two_port_sparameter_results.csv\n');
