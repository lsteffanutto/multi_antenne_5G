clear all; close all; clc;

figure(1)

load('ZF2.mat');
semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('MMSE2.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('SIC3.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
hold on;load('ML2.mat');
semilogy(EbN0dB,P_ERROR,'LineWidth',1);

xlim([0 10])
ylim([1e-4 1])
grid on
xlabel("SNR en dB",'Interpreter', 'latex', 'FontSize',14)
ylabel("Probabilité d'erreur",'Interpreter', 'latex', 'FontSize',14)
title("Probabilités d'erreur par décodeur M=N=L=2");

legend('ZF','MMSE','SIC','ML');


figure(2),

load('ML2.mat');
semilogy(EbN0dB,P_ERROR,'--','LineWidth',1);
load('ML_M_4.mat');
hold on;semilogy(EbN0dB,P_ERROR,'--','LineWidth',1);
load('ML_M_8_normal_Vblast.mat');
hold on;semilogy(EbN0dB,P_ERROR,'--','LineWidth',1);

load('ML_ALAMOUTI.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('ML_ALAMOUTI_M_4.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('ML_ALAMOUTI_M_8.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);

xlim([0 10])
ylim([1e-6 1])
grid on
xlabel("SNR en dB",'Interpreter', 'latex', 'FontSize',14)
ylabel("Probabilité d'erreur",'Interpreter', 'latex', 'FontSize',14)

title("Probabilités d'erreur codes V-Blast/Alamouti pour décodeur ML ");

legend('ML M=2','ML M=4','ML M=8','Alamouti M=2','Alamouti M=4','Alamouti M=8');






% hold on;
% load('ZF.mat');
% semilogy(EbN0dB,ber,'LineWidth',1);


% M=2;
% N=2;
% L=1;



%,'ML4','ML8','A2','A4','A8');
