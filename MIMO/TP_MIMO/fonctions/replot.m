clear all; close all; clc;

figure(1)

load('ZF2.mat');
semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('MMSE2.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('SIC3.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);

hold on;load('ML3.mat');
semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('ML_M_4.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('ML_M_8_normal_Vblast.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);


load('ML_ALAMOUTI.mat');
semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('ML_ALAMOUTI_M_4.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);
load('ML_ALAMOUTI_M_8.mat');
hold on;semilogy(EbN0dB,P_ERROR,'LineWidth',1);





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

title("MA COLLEC DE TEUBS");

legend('ZF','MMSE','SIC','ML2','ML4','ML8','A2','A4','A8');
