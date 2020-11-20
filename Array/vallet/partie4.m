% TP Traitement d'antenne TS305
clear; close all; clc;

%% Séparation
data=load('data.mat');
[nb_sources,P,axe_theta,R,a_theta]=separation(data);

figure, plot(axe_theta,abs(P));
% eig_ax = 1:1:length(ebruit);
% figure, plot(eig_ax,real(ebruit'),'xb');

