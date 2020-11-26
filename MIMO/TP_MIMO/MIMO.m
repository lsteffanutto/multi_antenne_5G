clear all; close all; clc; beep off;

%% PROGRAMME POUR TESTER LES DIFFS DECODEURS AVEC ET SANS BRUIT

%% VAR
M=2; %Nombre d'antennes de réception
N=2; %Nombre d'antennes d'émission
L=1; %Nombre de symboles transmis

ML=1;
ZF=1;
MMSE=1;
SIC=1;

sigma2=0;
SNR=1/sigma2;
contrainte_puissance=N*L;

%% CODAGE V-BLAST (Dépend nombre antenne de réception) %%%
H = randn(M,N) + 1i*randn(M,N); % [MxN] % Constante, contient les h_m_n = gain complexe entre n_eme antenne emission et m_eme antenne reception
V = sqrt(sigma2/2) *((randn(M,L) + 1i*randn(M,L))); % [MxL] % Bruit additif de variance sigma2

%QPSK = 4 signaux possible => (1 +1i) ; (1-1i) ; (-1-1i) ; (-1+1i)

% V-BLAST, on transmet un symbole par antenne, x_all = [x_1,...,x_NL] => NxL = 2*2= 4 symboles ici
symboles_x_all = randi([0 1], 1, N*L) + 1i * randi([0 1], 1, N*L)

%On les reshape verticalement à la V-BLAST (chaque antenne transmet un symbole)
X = reshape(symboles_x_all,N,L) % [NxL] %Mot de code avec les symboles répartis verticalement

%% CANAL
Y = H*X+V; % [MxL] = [MxN] x [NxL] + [MxL] % Ce qu'on reçoit

%% DECODAGE %%%%%%%%%%%%%%%%%%%

% ML %%%%%%%%%%%%%

if ML==1
% [X_dec] = decode_ML(Y,H,X);
[X_dec] = decode_ML_mieux(Y,H,X) % !!! Marche pour toute taille de L, même L=1 !!!
%Verif bon decodage
decode_success_ML=verif_decodage(X,X_dec)
end
%%%%%%%%%%%%%%%%%%

% ZF %%%%%%%%%%%%%
if ZF==1
[X_dec] = decode_ZF(H, Y)
decode_success_ZF=verif_decodage(X,X_dec)
end
%%%%%%%%%%%%%%%%%%

% MMSE %%%%%%%%%%%%%
if MMSE==1
[X_dec] = decode_MMSE(H, Y,sigma2)
decode_success_MMSE=verif_decodage(X,X_dec)
end
%%%%%%%%%%%%%%%%%%

% SIC %%%%%%%%%%%%%
if SIC==1
[X_dec] = decode_SIC(H, Y)
decode_success_SIC=verif_decodage(X,X_dec)
end
%%%%%%%%%%%%%%%%%%










