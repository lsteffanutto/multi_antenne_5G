clear all; close all; 

clc;

d = 0.05; % distance en mètre entre les micros
fc=6000;
c=340;
lamba_c=c/fc;
d/lamba_c; % =0.88 et on veut <=0.5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data=load('data.mat');

%Fonctions retournant le nombre de sources et les DoA
% à partir des data
[nb_sources] = separation(data)

% [nb_sources] = separation(signaux_micros, Fs);





fonction_detection_ok =1;




if fonction_detection_ok ==0
    
Ts=1/Fs;
Y_n=hilbert(data.data);
[M,N] = size(Y_n); % M=10 micros qui récupère chacun N=226706 echantillons
Y_n_1=Y_n(:,2*Fs+1:N); %signal sans les 2 premiere secondes bruit
[M,N_Y_n] = size(Y_n_1);
S_n_1=Y_n(:,1:2*Fs);%2 secondes full bruit

% On a besoin de R autocorrelation du signal recu
% on l'a pas donc il faut l'estimer
% on l'estime avec les N=500 samples de y, dans chaque colonnes de Y_n
R_chap = (1/N_Y_n)*(Y_n_1*Y_n_1');

% On a besoin de R autocorrelation du bruit pour fixer le seuil de Vp
S_chap = (1/(2*Fs))*(S_n_1*S_n_1');




%% Bruit

[U_s, D_s] = eig(S_chap);

[l_s,c_s]=size(D_s);
vp_s = zeros(M,M);
nb_vp_s=M;

for j = 1:M
    for i =1:M
        vp_s(i,j)=D_s(M-i+1,M-j+1);
    end
end
plot_vp_s = diag(vp_s);

disp_vp_bruit=0;
if disp_vp_bruit==1
    figure,
    scatter(1:nb_vp_s,plot_vp_s','+','LineWidth',1.5);
    title('Valeur des VP estimés Bruit en fonction de leur index')
    xlabel('Index de la VP');
    ylabel('Valeur');
%     hold on;
%     plot([0 nb_vp],[sigma_chap sigma_chap],'r--','LineWidth',1);
%     legend("VPs","\sigma_v="+sigma_v)
end

sigma_chap=mean(plot_vp_s);

%% Signal

[U, D] = eig(R_chap);

[l,c]=size(D);
vp = zeros(M,M);
nb_vp=M;

for j = 1:M
    for i =1:M
        vp(i,j)=D(M-i+1,M-j+1);
    end
end

plot_vp = diag(vp);


disp_vp=1;
if disp_vp==1
    
    figure,
    scatter(1:nb_vp,plot_vp','+','LineWidth',1.5);
    title('Valeurs des VP estimés Signal en fonction de leur index')
    xlabel('Index de la VP');
    ylabel('Valeur');
    hold on;
    plot([0 nb_vp],[sigma_chap sigma_chap],'r--','LineWidth',1);
    legend("VPs","\sigma_v="+sigma_chap)
end

K=6;
U_Kplus1_to_M_chap = U_s(:,K+1:end); %vecteur propre du SEB       [MxM-K]
U_1_to_K_chap = U(:,1:K); %vp correspondants au SEB    [MxK]
d_teta=[];     %E_estime_sortie_filtre % [1x181] = une pour chaque angle
P=[];
for teta=-pi/2:pi/180:pi/2 % on parcourt tous les angles
    
    a_teta_fixe_M_capteurs = zeros(M,1); % [5x1]
    for m = 1:M 
        a_teta_fixe_M_capteurs(m,1) = exp(-1i*pi*(m-1)*sin(teta)); %on calcul les vecteur directionnels pour chaque teta
    end
    a_teta_fixe_M_capteurs_conj = zeros(1,M);
    a_teta_fixe_M_capteurs_conj = a_teta_fixe_M_capteurs'; % [5x1]* = [5x1].' = [1x5]
            
    d = a_teta_fixe_M_capteurs_conj*U_Kplus1_to_M_chap;
%     
    res = sum(abs(d).^2);
%     res = d;
%     
    d_teta = [d_teta res];
    
%     p_teta = 1/(a_teta_fixe_M_capteurs_conj*R_chap^(-1)*a_teta_fixe_M_capteurs);
%     p_teta = 1/(a_teta_fixe_M_capteurs_conj*R_chap^(-1)*a_teta_fixe_M_capteurs);

    %Pseudo-spectre 
%     P = [ P p_teta ];
       
 
    
end

angle_radian = -pi/2:pi/180:pi/2;

disp=0;

if disp ==1
figure,
    plot( angle_radian*180/pi,abs(P),'LineWidth',1.5);
    xlabel('\theta (\circ)');
    ylabel('P(\theta)','rotation',0);
    hold on;
    plot([-100 100],[sigma_chap sigma_chap],'r--','LineWidth',1);
    title("P(\theta) estimé MUSIC pour  M = " + M +" capteurs");
end

angle_radian = -pi/2:pi/180:pi/2;
figure, plot(angle_radian*180/pi,d_teta);
xlabel('\theta (\circ)');
ylabel('d(\theta)','rotation',0);
title("d(\theta) estimé MUSIC pour  M = " + M +" capteurs");
end




