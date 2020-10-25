clear all; close all; 
clc;

%% VAR
% P_M=zeros(5,1);
M=20;        %capteurs  
N=500;       %nb_echantillons
sigma_s=1;  %energie signal recu
sigma_v=0.1;%energie du bruit
theta0=40*(pi/180);      %degré élévation de la source
K=1;

%% Filtrage Spatial Capon 1 source

test=1;
if test==1  % N=1 echantillon


v = sqrt(sigma_v/2)*(randn(M,1)+1i*randn(M,1)); % [5x1]      % bruit pour chaque capteur
s = sqrt(sigma_s/2)*(randn(K,1)+1i*randn(K,1));               % [1x1]      % signal recu
A=zeros(M,K);                 % [5x1]      % direction arrivee de la source determinee par chaque capteur

for i =1:M
    A(i,1) = exp(-1i*pi*(i-1)*sin(theta0));
end

y = A*s + v;
end


% N=500 echantillons
V_n = sqrt(sigma_v/2)*(randn(M,N)+1i*randn(M,N));% [5x500]    % bruit pour chaque capteur, pour chaque échantillon
S_n = sqrt(sigma_s/2)*(randn(K,N)+1i*randn(K,N));              % [1x500]    % signal recu de la source, pour chaque echantillon
% A=zeros(5,1);                  % [5x1]      % direction arrivee de la source determinee par chaque capteur pour un echantillon
A_n = zeros(M,K);              % [5x500]    % % direction arrivee de la source determinee par chaque capteur pour chaque echantillon

for k=1:K
    
    A=zeros(M,1);
    for i=1:M
        A(i,1) = exp(-1i*pi*(i-1)*sin(theta0));
    end
    A_n(:,k) = A; % on concatene l'observation des 5 capteur pour chaque echantillon
        
end

Y_n = A_n*S_n + V_n;

xx=1:N;

disp=1;
if disp==1   
figure,

subplot(5,1,1);plot(xx,Y_n(1,:));title('y1');
subplot(5,1,2);plot(xx,Y_n(2,:));title('y2');
subplot(5,1,3);plot(xx,Y_n(3,:));title('y3');
subplot(5,1,4);plot(xx,Y_n(4,:));title('y4');
subplot(5,1,5);plot(xx,Y_n(5,:));title('y5');

suptitle('signal reçu par chaque capteur M');
end

%% Filtre de Capon

% On a besoin de R autocorrelation du signal recu
% on l'a pas donc il faut l'estimer
% on l'estime avec les N=500 samples de y, dans chaque colonnes de Y_n
% R_chap [5x5]
% R_chap = (1/N)*sum(Y_n*conj(Y_n)'); % * X' *=conj transposé

R_chap = (1/N)*(Y_n*Y_n') ; % Dans cours X* = X.' dans matlab
R_chap_inv = inv(R_chap);


% w_chap = zeros(M,1); %[5x1]
% w_teta = [];
% W_cap=[]; %[5x181]
P=[];     %E_estime_sortie_filtre % [1x181] = une pour chaque angle

for teta=-pi/2:pi/180:pi/2 % on parcourt tous les angles
    
    a_teta_fixe_M_capteurs = zeros(M,1); % [5x1]
    
    for m = 1:M % w pour chaque capteur
        a_teta_fixe_M_capteurs(m,1) = exp(-1i*pi*(m-1)*sin(teta)); %on calcul les vecteur directionnels pour chaque teta
    end
    
    a_teta_fixe_M_capteurs_conj = zeros(1,M);
    a_teta_fixe_M_capteurs_conj = a_teta_fixe_M_capteurs'; % [5x1]* = [5x1].' = [1x5]
    
%     w_teta = (R_chap_inv*a_teta_fixe_M_capteurs)/(a_teta_fixe_M_capteurs_conj*R_chap_inv*a_teta_fixe_M_capteurs); %inv(A)*b=A\b
    
%     W_cap = [W_cap w_teta]; %On stock le filtre pour chaque capteur [5x181] => 181 angles
    
    p_teta = 1/(a_teta_fixe_M_capteurs_conj*R_chap_inv*a_teta_fixe_M_capteurs);
    P = [ P p_teta ];   % [1x181] = une pour chaque angle
    
end


angle_radian = -pi/2:pi/180:pi/2;

figure,
plot( angle_radian*180/pi,abs(P));
xlabel('\theta (\circ)');
ylabel('P(\theta)','rotation',0);
%Spectre de puissance estimé en sortie du filtre de Capon
title('P(\theta) pour \theta = 40\circ et M = 5 capteurs');
% legend('M=5','M=20','M=50','M=100');

% https://fr.mathworks.com/matlabcentral/answers/298499-direction-of-arrival-estimation-of-multiple-signals-using-capon-mvdr-beamformer
% https://fr.mathworks.com/matlabcentral/answers/359847-direction-of-arrival-estimation-of-a-chirp-noised-and-attenuated-using-capon-mvdr-beamformer

