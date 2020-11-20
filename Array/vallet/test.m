clear; close all; clc;

%% Initialisation
signal_struct=load('data.mat');

signal_2=signal_struct.data;
F=signal_struct.Fs;
signal=signal_2(:,2*F+1:end); % 2 premières secondes=bruit
M=length(signal(:,1));
N=length(signal(1,:));

R=zeros(M); % Covariance signal
Rbruit=zeros(M); % Covariance bruit

sound(signal(1,:),F); % Ecoute du signal sur le premier capteur

% Calcul de Rbruit
for i=1:2*F
    Rbruit=Rbruit+signal_2(:,i)*signal_2(:,i)';
end
Rbruit=1/(2*F)*Rbruit; 

% Calcul de R
for j=1:N
    R=R+signal(:,j)*signal(:,j)';
end
R=1/N*R; 

%% Calcul nb_sources
e=eig(R);
e=rot90(rot90(e)); 
ebruit=eig(Rbruit);
ebruit=rot90(rot90(ebruit));

moy=round(mean(ebruit),7);
nb_sources=length(find(ebruit>moy));

%% Séparation
axe_theta=-90:0.1:90;
a_theta=zeros(M,length(axe_theta));
tr_pi=zeros(1,length(axe_theta));
%determinants=zeros(1,length(axe_theta));

k=1;
for theta=axe_theta
    for source=1:M
        a_theta(source,k)=exp(-1i*pi*(source-1)*sin(deg2rad(theta)));
    end
    pi_mat=a_theta(:,k)*(a_theta(:,k)'*a_theta(:,k))^(-1)*a_theta(:,k)';
    tr_pi(k)=abs(trace(pi_mat*Rbruit));
    %determinants(k)=abs(log(det(pi_mat*R*pi_mat+mean(ebruit)*(eye(length(pi_mat))-pi_mat))));
    k=k+1;
end

% thetas=zeros(1,nb_sources);
% tr_pi(1,1)=0;
% tr_pi(1,1801)=0;
% 
% for K=1:nb_sources
%     theta_prov=max(tr_pi);
%     pos=find(tr_pi==theta_prov);
%     thetas(1,K)=axe_theta(1,pos);
%     tr_pi(1,pos)=-Inf;
% end
