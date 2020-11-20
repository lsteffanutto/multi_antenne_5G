% TP Traitement d'antenne TS305
clear; close all; clc;

%% Signal reçu par les capteurs 
M=30; % nb de capteurs
N=500; % nb d'echantillons
thetas=[40 50 60 70]; % elevation de la source
K=length(thetas); % nb de sources
Mu=0;
%sigma_s=[1 1]; % energie de la source
sigma_s = ones(1,K);
sigma_v=5; % energie du bruit
A=zeros(M,K); % Matrice des vecteurs directionnels associes aux sources
s=zeros(K,N); % Signal source

for i=1:K
    for j=1:M
        A(j,i)=exp(-1i*pi*(j-1)*sin(deg2rad(thetas(i))));
    end
end 

s=Mu+sqrt(diag(sigma_s))*(randn(K,N)+1i*randn(K,N)); 
v=Mu+sqrt(sigma_v)*(randn(M,N)+1i*randn(M,N)); % Bruit
y=A*s+v; % Signal reçu sur les capteurs

%% Méthode de Capon
R=zeros(M);
axe_theta=-90:0.1:90;
a_theta=zeros(M,length(axe_theta));
P=zeros(1,length(axe_theta));

% Calcul de R
for j=1:N
    R=R+y(:,j)*y(:,j)';
end
R=1/N*R;

% Calcul de P
k=1;
for theta=axe_theta
    for source=1:M
        a_theta(source,k)=exp(-1i*pi*(source-1)*sin(deg2rad(theta)));
        P(1,k)=1/(a_theta(:,k)'*R^(-1)*a_theta(:,k));
    end
    k=k+1;
end

% Affichage
figure, plot(axe_theta,abs(P));
title(['Energie en sortie du filtre, M=',num2str(M),' sigmabruit=',num2str(sigma_v)]);

%% Localisation par methode sous-espaces 
e = eig(R);
e = rot90(rot90(e));
eig_ax = 1:1:length(e);
figure, plot(eig_ax,real(e'),'xb');
ylabel('valeurs propres');

%% MUSIC 
[U,Lambda]=eig(R);
d=0;
for ii=K+1:M
    d=d+abs(a_theta'*U(:,ii)).^2;
end

figure, plot(axe_theta,d);
title(['Pseudo-spectre, M=',num2str(M),' sigmabruit=',num2str(sigma_v)]);

% Affichage signal
% axe_y=linspace(1,500,500);
% figure, 
% subplot(5,1,1), plot(axe_y,abs(y(1,:)));
% title('Signal M1');
% subplot(5,1,2), plot(axe_y,abs(y(2,:)));
% title('Signal M2');
% subplot(5,1,3), plot(axe_y,abs(y(3,:)));
% title('Signal M3');
% subplot(5,1,4), plot(axe_y,abs(y(4,:)));
% title('Signal M4');
% subplot(5,1,5), plot(axe_y,abs(y(5,:)));
% title('Signal M5');
