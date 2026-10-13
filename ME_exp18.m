
clc;
clear;
close all;

% Millimeter-Wave Massive-MIMO Simulation
% Beamforming and Spatial Multiplexing

%% 1. Input parameters
fc = 28e9;                % Carrier frequency: 28 GHz
Nt = 16;                  % Transmit antennas
Nr = 4;                   % Receive antennas
SNRdB = 10;                % Signal-to-noise ratio
SNRlin = 10^(SNRdB/10);

lambda = 3e8/fc;

fprintf('MASSIVE-MIMO SIMULATION\n');
fprintf('Carrier frequency = %.2f GHz\n',fc/1e9);
fprintf('Wavelength = %.3f mm\n',lambda*1e3);
fprintf('Transmit antennas = %d\n',Nt);
fprintf('Receive antennas = %d\n',Nr);
fprintf('SNR = %.2f dB\n',SNRdB);

%% 2. Generate Rayleigh MIMO channel
rng(1);                   % Repeatable results

H = (randn(Nr,Nt)+1j*randn(Nr,Nt))/sqrt(2);

%% 3. Generate QPSK data symbols
Ns = min(Nt,Nr);          % Number of spatial streams
numSymbols = 20000;

bits = randi([0 1],2*Ns,numSymbols);

X = (1-2*bits(1:2:end,:)) + ...
    1j*(1-2*bits(2:2:end,:));

X = X/sqrt(2);

%% 4. SVD-based beamforming
[U,S,V] = svd(H,'econ');

% Transmit through the strongest spatial modes
Heff = U'*H*V;
Heff = Heff(1:Ns,1:Ns);

%% 5. Transmit and receive signals
noiseVar = 1/SNRlin;

noise = sqrt(noiseVar/2)* ...
    (randn(Ns,numSymbols)+1j*randn(Ns,numSymbols));

Y = Heff*X + noise;

%% 6. Zero-forcing detection
Xhat = pinv(Heff)*Y;

bitsHat = zeros(size(bits));
bitsHat(1:2:end,:) = real(Xhat)<0;
bitsHat(2:2:end,:) = imag(Xhat)<0;

BER = mean(bitsHat(:)~=bits(:));

%% 7. Calculate MIMO channel capacity
C = log2(real(det(eye(Nr) + ...
    (SNRlin/Nt)*(H*H'))));

C = max(real(C),0);

fprintf('\nPERFORMANCE RESULTS\n');
fprintf('Spatial streams = %d\n',Ns);
fprintf('QPSK bit error rate = %.6g\n',BER);
fprintf('MIMO capacity = %.3f bit/s/Hz\n',C);

%% 8. Plot channel matrix
figure;
imagesc(abs(H));
colorbar;
xlabel('Transmit Antenna');
ylabel('Receive Antenna');
title('MIMO Channel Matrix Magnitude');

%% 9. Plot singular values
figure;
stem(diag(S),'filled');
grid on;
xlabel('Spatial Mode');
ylabel('Singular Value');
title('MIMO Channel Singular Values');

%% 10. BER versus SNR
SNRvec = 0:2:20;
BERvec = zeros(size(SNRvec));

for k = 1:length(SNRvec)

    snrLinear = 10^(SNRvec(k)/10);
    nv = 1/snrLinear;

    noise = sqrt(nv/2)* ...
        (randn(Ns,numSymbols)+1j*randn(Ns,numSymbols));

    Ytemp = Heff*X + noise;
    Xtemp = pinv(Heff)*Ytemp;

    bhat = zeros(size(bits));
    bhat(1:2:end,:) = real(Xtemp)<0;
    bhat(2:2:end,:) = imag(Xtemp)<0;

    BERvec(k) = mean(bhat(:)~=bits(:));
end

figure;
semilogy(SNRvec,max(BERvec,1e-6),'-o','LineWidth',1.5);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER versus SNR');

%% 11. Channel capacity versus SNR
Cap = zeros(size(SNRvec));

for k = 1:length(SNRvec)
    snrLinear = 10^(SNRvec(k)/10);

    Cap(k) = real(log2(det(eye(Nr) + ...
        (snrLinear/Nt)*(H*H'))));
end

figure;
plot(SNRvec,Cap,'-s','LineWidth',1.5);
grid on;
xlabel('SNR (dB)');
ylabel('Capacity (bit/s/Hz)');
title('MIMO Channel Capacity versus SNR');

%% 12. Final summary
fprintf('\nSIMULATION SUMMARY\n');
fprintf('Carrier frequency = %.2f GHz\n',fc/1e9);
fprintf('Antenna configuration = %d x %d\n',Nt,Nr);
fprintf('Operating SNR = %.2f dB\n',SNRdB);
fprintf('Channel = Rayleigh fading\n');
fprintf('Maximum spatial streams = %d\n',Ns);
