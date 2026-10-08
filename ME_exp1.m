clc; clear; close all;

x = linspace(0,1,100);
y = linspace(0,1,100);
[X,Y] = meshgrid(x,y);
TEM = ones(size(X));
TE = sin(pi*X);
TM = sin(pi*X).*sin(pi*Y);

figure;

subplot(1,3,1)
imagesc(x,y,TEM);
title('TEM Mode');
xlabel('x'); ylabel('y');
colorbar;

subplot(1,3,2)
imagesc(x,y,TE);
title('TE_{10} Mode');
xlabel('x'); ylabel('y');
colorbar;

subplot(1,3,3)
imagesc(x,y,TM);
title('TM_{11} Mode');
xlabel('x'); ylabel('y');
colorbar;

sgtitle('Electromagnetic Propagation Modes');