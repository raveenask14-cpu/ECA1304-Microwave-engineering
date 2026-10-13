
clc;
clear;
close all;

% Microstrip Patch Antenna Analysis

%% 1. Input parameters
c = 299792458;
f0 = 2.4e9;
er = 4.4;
h = 1.6e-3;
W = 37.2e-3;
L = 28.8e-3;

fStart = 1.8e9;
fStop = 3.0e9;
N = 2401;
f = linspace(fStart,fStop,N);
fGHz = f/1e9;

%% 2. Calculate effective permittivity
eeff = (er+1)/2 + (er-1)/2 * ...
       (1+12*h/W)^(-0.5);

%% 3. Calculate fringing length
deltaL = 0.412*h*((eeff+0.3)*(W/h+0.264)) / ...
         ((eeff-0.258)*(W/h+0.8));

%% 4. Calculate theoretical resonant frequency
Leff = L+2*deltaL;
fr = c/(2*Leff*sqrt(eeff));

fprintf('MICROSTRIP PATCH ANTENNA\n');
fprintf('Design frequency = %.2f GHz\n',f0/1e9);
fprintf('Effective permittivity = %.4f\n',eeff);
fprintf('Effective length = %.3f mm\n',Leff*1e3);
fprintf('Theoretical resonance = %.4f GHz\n',fr/1e9);

%% 5. Approximate S11 response
Q = 25;
x = f/fr-fr./f;
beta = 1;

Gamma = (1-beta+1j*Q.*x) ./ ...
        (1+beta+1j*Q.*x);

S11dB = 20*log10(max(abs(Gamma),1e-12));

%% 6. Calculate VSWR
g = abs(Gamma);
VSWR = (1+g)./max(1-g,1e-12);

%% 7. Calculate -10 dB bandwidth
valid = S11dB <= -10;

if any(valid)
    fb = f(valid);
    flow = min(fb);
    fhigh = max(fb);
    BW = fhigh-flow;

    fprintf('-10 dB bandwidth = %.2f MHz\n',BW/1e6);
    fprintf('Lower frequency = %.4f GHz\n',flow/1e9);
    fprintf('Upper frequency = %.4f GHz\n',fhigh/1e9);
else
    fprintf('-10 dB bandwidth not found.\n');
end

[~,idx] = min(S11dB);
fprintf('Minimum S11 = %.2f dB\n',S11dB(idx));
fprintf('VSWR at minimum S11 = %.3f\n',VSWR(idx));

%% 8. Plot S11
figure;
plot(fGHz,S11dB,'LineWidth',1.5);
hold on;
yline(-10,'--','-10 dB');
xline(f0/1e9,':','Design frequency');
grid on;
xlabel('Frequency (GHz)');
ylabel('S11 (dB)');
title('Patch Antenna Return Loss');
legend('S11','-10 dB limit','Design frequency');

%% 9. Plot VSWR
figure;
plot(fGHz,VSWR,'LineWidth',1.5);
hold on;
yline(2,'--','VSWR = 2');
grid on;
xlabel('Frequency (GHz)');
ylabel('VSWR');
title('VSWR versus Frequency');
legend('VSWR','Target');

%% 10. Illustrative radiation pattern
theta = linspace(0,180,721);
pattern = abs(cosd(theta)).^2;
pattern_dB = 10*log10(max(pattern,1e-4));
pattern_dB = pattern_dB-max(pattern_dB);

figure;
polarplot(deg2rad(theta),pattern,'LineWidth',1.5);
title('Illustrative Radiation Pattern');

%% 11. Radiation pattern in dB
figure;
plot(theta,pattern_dB,'LineWidth',1.5);
grid on;
xlabel('Angle (degrees)');
ylabel('Normalized Pattern (dB)');
title('Normalized Radiation Pattern');
ylim([-40 2]);

%% 12. Display design targets
fprintf('\nDESIGN TARGETS\n');
fprintf('Resonant frequency: approximately 2.4 GHz\n');
fprintf('Minimum S11: <= -10 dB\n');
fprintf('VSWR: <= 2\n');
fprintf('Bandwidth: approximately 60-100 MHz\n');
fprintf('Gain: approximately 5-7 dBi (verify using HFSS/CST)\n');
