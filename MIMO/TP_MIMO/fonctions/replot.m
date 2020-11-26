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
xlabel('$SNR$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('Pe','Interpreter', 'latex', 'FontSize',14)

% M=2;
% N=2;
% L=1;

title("Pe par decodeur avec M="+M+"; N="+N+"; L="+L);

legend('ML','ZF','MMSE','SIC');
