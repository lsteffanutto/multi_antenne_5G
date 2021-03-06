clear all; close all; 

clc;

%% VAR
% P_M=zeros(5,1);
M=20;        %capteurs  
N=500;       %nb_echantillons
sigma_s1=1;  %energie signal recu
sigma_s2=1; 
sigma_s = [ sigma_s1 sigma_s2];
% sigma_v=5;%energie du bruit
% sigma_v_tab = [0.1 1 3 5 10 ];
sigma_v_tab = [0.1 1 3 5 10];
nb_sigma=length(sigma_v_tab);
% nb_sigma=1;
% sigma_v_tab=3
for variance = 1:nb_sigma

sigma_v=sigma_v_tab(variance);%energie du bruit

theta1= 40 %en degré
theta2 = 50
theta= [theta1 theta2]*(pi/180);      %degré élévation de la source
K=length(theta);

%% Filtrage Spatial Capon 2 sources

test=0;
if test==1  % N=1 echantillon


v = sqrt(sigma_v/2)*(randn(M,1)+1i*randn(M,1)); % [5x1]      % bruit pour chaque capteur
s = diag(sqrt(sigma_s/2))*(randn(K,1)+1i*randn(K,1));               % [2x1]      % signal recu
A=zeros(M,K);                % [5x1]      % direction arrivee de la source determinee par chaque capteur

for j =1:K
    
    for i =1:M
        A(i,j) = exp(-1i*pi*(i-1)*sin(theta(1,K)));
    end

 end

y = A*s + v;
end


% N=500 echantillons
V_n = sqrt(sigma_v/2)*(randn(M,N)+1i*randn(M,N));% [5x500]    % bruit pour chaque capteur, pour chaque échantillon
S_n = sqrt(diag(sigma_s/2))*(randn(K,N)+1i*randn(K,N));              % [1x500]    % signal recu de la source, pour chaque echantillon
% A=zeros(5,1);                  % [5x1]      % direction arrivee de la source determinee par chaque capteur pour un echantillon
A_n = zeros(M,K);              % [5x500]    % % direction arrivee de la source determinee par chaque capteur pour chaque echantillon

% for j=1:N
    
for k =1:K
    A=zeros(M,1);
    for i=1:M
        A_n(i,k) = exp(-1i*pi*(i-1)*sin(theta(1,k)));
    end
%     A_n(:,j) = A; % on concatene l'observation des 5 capteur pour chaque echantillon
end
        
% end

Y_n = A_n*S_n + V_n;

xx=1:N;

disp=0;
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
[U, D] = eig(R_chap); % les vecteurs propres sont les col de U, les val propres la diag de D
%D = grand lambda
%U = U estimé , contenant les vecteurs propres en colonnes 
%[ u_1_chap , u_2_chap , u_3_chap , ... , u_M_chap ]

PI_chap_SES = (U(1:K,1:K)*U(1:K,1:K)');                          %sous-espace SIGNAL (projette orthogonale)
PI_chap_bar_SEB = (U(K+1:end,K+1:end)*U(K+1:end,K+1:end)');      %sous-espace BRUIT  (projette orthogonale)

U_Kplus1_to_M_chap = U(:,K+1:end); %vecteur propre du SEB       [MxM-K]
U_1_to_K_chap = U(:,1:K); %vp correspondants au SES    [MxK]

[l,c]=size(D);
vp = zeros(M,M);
nb_vp=M;

for j = 1:M
    for i =1:M
        vp(i,j)=D(M-i+1,M-j+1);
    end
end

plot_vp = diag(vp);

sigma_chap = (1/(M-K))*( sum(plot_vp((K+1):M))); %on estime le seuil


disp_vp=0;
if disp_vp==1
    figure,
    scatter(1:nb_vp,plot_vp','+','LineWidth',1.5);
    title('Valeur des VP estimés en fonction de leur index')
    xlabel('Index de la VP');
    ylabel('Valeur');
    hold on;
    plot([0 nb_vp],[sigma_chap sigma_chap],'r--','LineWidth',1);
    legend("VPs","\sigma_v="+sigma_v)
end

% Stmp = S >= seuil;
% S = Stmp.*S;

% w_chap = zeros(M,1); %[5x1]
% w_teta = [];
% W_cap=[]; %[5x181]
d_teta=[];     %E_estime_sortie_filtre % [1x181] = une pour chaque angle
P=[];
for teta=-pi/2:pi/180:pi/2 % on parcourt tous les angles
    
    a_teta_fixe_M_capteurs = zeros(M,1); % [5x1]
    for m = 1:M 
        a_teta_fixe_M_capteurs(m,1) = exp(-1i*pi*(m-1)*sin(teta)); %on calcul les vecteur directionnels pour chaque teta
    end
    a_teta_fixe_M_capteurs_conj = zeros(1,M);
    a_teta_fixe_M_capteurs_conj = a_teta_fixe_M_capteurs'; % [5x1]* = [5x1].' = [1x5]
            
    d = sum(abs(a_teta_fixe_M_capteurs_conj*U(:,K+1:M))).^2;
%   d=0;

%     res = sum(abs(d).^2);
    res = d;
%     
    d_teta = [d_teta res];
    
%     p_teta = 1/(a_teta_fixe_M_capteurs_conj*U_1_to_K_chap*U_1_to_K_chap'*a_teta_fixe_M_capteurs);
%     p_teta = 1/(a_teta_fixe_M_capteurs_conj*R_chap^(-1)*a_teta_fixe_M_capteurs);

    %Pseudo-spectre 
%     P = [ P p_teta ];
       
 
    
end


angle_radian = -pi/2:pi/180:pi/2;
hold on
plot(angle_radian*180/pi,d_teta,'LineWidth',1.5);
xlabel('\theta (\circ)');
ylabel('d(\theta)','rotation',0);
title("d(\theta) estimé pour \theta_1= "+theta1+"\circ, \theta_2= "+theta2+"\circ, M = " + M +" capteurs");
legend("\sigma_v="+sigma_v_tab(1),"\sigma_v="+sigma_v_tab(2),"\sigma_v="+sigma_v_tab(3),"\sigma_v="+sigma_v_tab(4),"\sigma_v="+sigma_v_tab(5));


disp=0;

if disp ==1
% figure,
    hold on
    plot( angle_radian*180/pi,abs(P)/(N*M),'LineWidth',1.5);
    xlabel('\theta (\circ)');
    ylabel('P(\theta)','rotation',0);
    title("P(\theta) estimé MUSIC pour \theta_1= "+theta1+"\circ, \theta_2= "+theta2+"\circ, M = " + M +" capteurs");
    % legend("Capon M=20","MUSIC M="+M);
end

if nb_sigma ==3
    legend("MUSIC M="+M);
end

if variance == 1

    [pks, locs] = findpeaks(abs(P));
    indices_peak_2_sources = find(pks>0.1);
    index_peak = [angle_radian(locs(indices_peak_2_sources(1,:)))*180/pi];
    peaks = [ abs(P(locs(indices_peak_2_sources(1)))) abs(P(locs(indices_peak_2_sources(2))))];
end

end

if nb_sigma ==3
legend("\sigma_v="+sigma_v_tab(1),"\sigma_v="+sigma_v_tab(2),"\sigma_v="+sigma_v_tab(3));
end

%PLOT BONNES DoA
% hold on;
% scatter(index_peak(1),peaks(1),100,'g+','LineWidth',2.5);
% hold on;
% scatter(index_peak(2),peaks(2),100,'r+','LineWidth',2.5);
% 


% %Spectre de puissance estimé en sortie du filtre de Capon
% title("P(\theta) estimé pour \theta_1= "+theta1+"\circ, \theta_2= "+theta2+"\circ, M=" + M);
% legend('\sigma_v=0.1','\sigma_v=0.5','\sigma_v=1');


% [pks, locs] = findpeaks(abs(P));
% 
% indices_peak_2_sources = find(pks>0.1)
% index_peak = [ angle_radian(locs(indices_peak_2_sources(1,:)))*180/pi]
% hold on;
% scatter(index_peak(1),abs(P(locs(indices_peak_2_sources(1)))),'r+');
% hold on;
% scatter(index_peak(2),abs(P(locs(indices_peak_2_sources(2)))),'r+');

% plot(locs(pks(1,:)),pks)

% plot(locs(pks)*180/pi,abs(P(locs(pks))))

% scatterplot(abs(P(locs)))
% angle_source = locs*180/pi

angle_radian = -pi/2:pi/180:pi/2;
figure, plot(angle_radian*180/pi,d_teta);
xlabel('\theta (\circ)');
ylabel('d(\theta)','rotation',0);
title("d(\theta) estimé pour \theta_1= "+theta1+"\circ, \theta_2= "+theta2+"\circ, M = " + M +" capteurs");

%% leur technique
% R=zeros(M);
% axe_theta=-90:0.1:90;
% a_theta=zeros(M,length(axe_theta));
% 
% for theta=axe_theta
%     for source=1:M
%         a_theta(source,k)=exp(-1i*pi*(source-1)*sin(deg2rad(theta)));
% %         P(1,k)=1/(a_theta(:,k)'*R^(-1)*a_theta(:,k));
%     end
%     k=k+1;
% end
% 
% 
% [U,Lambda]=eig(R_chap);
% dd=0;
% for ii=K+1:M
%     dd=dd+abs(a_theta'*U(:,ii)).^2;
% end
% figure, plot(axe_theta,dd(2:end)');


