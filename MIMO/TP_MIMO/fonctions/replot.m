clear all; close all; clc;



figure(2)
load('V-Blast1.mat');
semilogy(EbN0dB,ber,'LineWidth',1);

% hold on;
% load('ZF.mat');
% semilogy(EbN0dB,ber,'LineWidth',1);

xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('Pe','Interpreter', 'latex', 'FontSize',14)
title('Probabilité erreur de chaque décodeur');

legend('ML','ZF')
