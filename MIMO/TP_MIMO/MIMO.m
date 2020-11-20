clear all; close all; clc; beep off;

%% VAR
M=2; %Nombre d'antennes de réception
N=2; %Nombre d'antennes d'émission
L=1; %Nombre de symboles transmis

sigma2=100;
SNR=1/sigma2;
contrainte_puissance=N*L;

%% V-BLAST (Dépend nombre antenne de réception)

%%% CODAGE %%%
H = randn(M,N) + 1i*randn(M,N); % [MxN] % Constante, contient les h_m_n = gain complexe entre n_eme antenne emission et m_eme antenne reception
V = sqrt(sigma2/2) *((randn(M,L) + 1i*randn(M,L))); % [MxL] % Bruit additif de variance sigma2

%QPSK = 4 signaux possible => (1 +1i) ; (1-1i) ; (-1-1i) ; (-1+1i)

% V-BLAST, on transmet un symbole par antenne, x_all = [x_1,...,x_NL] => NxL = 2*2= 4 symboles ici
symboles_x_all = randi([0 1], 1, N*L) + 1i * randi([0 1], 1, N*L);

%On les reshape verticalement à la V-BLAST (chaque antenne transmet un symbole)
X = reshape(symboles_x_all,N,L) % [NxL] %Mot de code avec les symboles répartis verticalement

Y = H*X+V % [MxL] = [MxN] x [NxL] + [MxL] % Ce qu'on reçoit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DECODAGE %%%%%%%%%%%%%%%%%%%

% ML 

[X_dec] = decode_ML(Y,H,X)

%Verif bon decodage
decode_success=0;
sum_ressemblance=sum(sum(X==X_dec));
if sum_ressemblance==N*L;
    decode_success=1;
end
decode_success













