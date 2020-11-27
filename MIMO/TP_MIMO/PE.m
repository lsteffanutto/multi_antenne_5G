clear all; clc; beep off;

%CODE DE R.TAJAN ADAPTE POUR LA Pe Multi-antenne SNR=1./sigma2

%% Parametres
% -------------------------------------------------------------------------

ALAMOUTI=0;
V_BLAST=1;

M=8; %Nombre d'antennes de réception
N=2; %Nombre d'antennes d'émission
L=2; %Nombre de symboles transmis

% Channel Matrix deterministe
H = randn(M,N) + 1i*randn(M,N); % [MxN] % Constante, contient les h_m_n = gain complexe entre n_eme antenne emission et m_eme antenne reception

ML=1; %the best
ZF=0;   %moins bon
MMSE=0; %même que ZF si sigma2=0 comme je lui ai mis en parametre pour test
SIC=0;  %meilleur si SNR bon

puissance_signal=1;
nb_bit_dans_mdc=N*L;

EbN0dB_min  = -4; % Minimum de EbN0
EbN0dB_max  = 8; % Maximum de EbN0
EbN0dB_step = 1;% Pas de EbN0

nbr_erreur  = 100;  % Nombre d'erreurs à observer avant de calculer une Pe
nbr_bit_max = 100e6;% Nombre de bits max à simuler
Pe_min     = 1e-6; % Pe min

EbN0dB = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de SNR à simuler en dB à simuler
EbN0   = 10.^(EbN0dB/10); %variance du bruit
% SNR=-10*log10(sigma2);
sigma2 = 1./EbN0; % <= SNR défini dans cours : ICI ON FAIT VARIER LE SNR
% -------------------------------------------------------------------------
%% Construction de l'objet évaluant le TEB
stat_erreur = comm.ErrorRate(); % Calcul du nombre d'erreur et du BER

%% Initialisation des vecteurs de résultats
%Pe = je mot de code décodé different du mot de code envoyé
P_ERROR = zeros(1,length(EbN0dB));

%% Préparation de l'affichage
figure(1)
h_Pe = semilogy(EbN0dB,P_ERROR,'XDataSource','EbN0dB', 'YDataSource','ber');
% h_Pe = semilogy(EbN0dB,paquet_err,'XDataSource','EbN0dB', 'YDataSource','Pe');
hold all
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('$P_{error}$','Interpreter', 'latex', 'FontSize',14)

%% Préparation de l'affichage en console
msg_format = '|   %7.2f  |   %9d   |  %9d | %2.2e |  %8.2f kO/s |   %8.2f kO/s |   %8.2f s |\n';

fprintf(      '|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')
msg_header =  '|  Eb/N0 dB  |    X_tot      | X_dec_faux |   Pe     |    Debit Tx    |     Debit Rx    | Tps restant  |\n';
fprintf(msg_header);
fprintf(      '|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')






%% Simulation
for i_snr = 1:length(EbN0dB)   %<==== ON FAIT VARIER LES SNR
    reverseStr = ''; % Pour affichage en console
    sigma2_temp = sigma2(i_snr);% Mise a jour du SNR pour le canal pour la simulation
    
    stat_erreur.reset; % reset du compteur d'erreur
    err_stat    = [0 0 0]; % vecteur résultat de stat_erreur
       
    nb_MDC_envoye_pour_SNR = 0;        %on compte les mots envoyé pour la simulation
    nb_MDC_decode_faux_pour_SNR = 0;   %on compte les mots de code faux pour la simulation 
    
    T_rx = 0;
    T_tx = 0;
    general_tic = tic;
    
    while (err_stat(2) < nbr_erreur && err_stat(3) < nbr_bit_max)
        
        nb_MDC_envoye_pour_SNR = nb_MDC_envoye_pour_SNR + 1; %chaque tour on envoie un nouveau mot de code de 2 symbole aleatoire QPSK
        
        %% Emetteur
        tx_tic = tic; % Mesure du débit d'encodage
        
        % Génération des symboles QPSK
        if V_BLAST==1
            %On les reshape verticalement à la V-BLAST (chaque antenne transmet un symbole)
            symboles_x_all = randi([0 1], 1, N*L) + 1i * randi([0 1], 1, N*L);
            X = reshape(symboles_x_all,N,L); % [NxL] %Mot de code avec les symboles répartis verticalement
            X=complex(X);
        end
        
        
%         symboles_x_all = randi([0 1], 1, N*L) + 1i * randi([0 1], 1, N*L); %2 symboles aléatoires déjà modulés par mes soins
%         % Encodage V-BLAST (~encodé verticale)
%         X = reshape(symboles_x_all,N,L); % [NxL] %Mot de code avec les symboles répartis verticalement
%         X=complex(X);
         
        if ALAMOUTI==1
            symboles_x_all= randi([0 1], N, 1) + 1i * randi([0 1], N, 1);
            x_1_2 = (-symboles_x_all(2))';   % x_2_1=-x_1_2' => x_1_2=-(x_2_1)'
        %     x_1_2 = complex(-(symboles_x_all(2)'));   % x_2_1=-x_1_2' => x_1_2=-(x_2_1)'

            x_2_2 = symboles_x_all(1)';      % x_1_1=x_2_2' => x_2_2=x_1_1'
            alam = [x_1_2 ; x_2_2];
            X = [symboles_x_all,alam];
            X=complex(X);
        end
        
        T_tx   = T_tx+toc(tx_tic);    % Mesure du débit d'encodage
        
        %% Canal
        
        mot_de_code_transmis = H*X; %H = matrice avec les gains complexes entre les antennes
        
        %Y=mot_de_code_transmis % recu sans bruit pour test
        
        %Faut peut etre rajouter H ici
        V = sqrt(sigma2_temp/2) *((randn(M,L) + 1i*randn(M,L)));     % Additive Gaussian noise, assumed spatially white, avec le sigma2_temp pour cette simulation
        Y=mot_de_code_transmis+V; % On reçoit le mot de code avec du bruit
                                                                          
        %% Recepteur
        rx_tic = tic;                  % Mesure du débit de décodage

        %Mon decodeur fait tout: demodulation et decision il parle 0 chinois
        
        % ML
        %rec_b=decode_ML(Y,H,X);
        if ML==1        
            if ALAMOUTI ==1
                [X_dec] = decode_ML_ALAMOUTI(Y,H);
            else
                % [X_dec] = decode_ML(Y,H,X);
                [X_dec] = decode_ML_mieux(Y,H,X); % !!! Marche pour toute taille de L, même L=1 !!!
                %Verif bon decodage
            end
        end
        
        % ZF
        if ZF==1
            [X_dec] = decode_ZF(H, Y);
        end
        
        % MMSE
        if MMSE==1
            [X_dec] = decode_MMSE(H, Y, sigma2_temp);
        end
        
        % SIC
        if SIC==1
            [X_dec] = decode_SIC(H, Y);
        end
        
        rec_b=complex(X_dec); %pcq des fois en décodant mal il oublie de préciser partie imaginaire nulle
        
        
        decode_success=0;
        sum_ressemblance=sum(sum(X==rec_b));  %Matrice logique avec 1 si les symboles egaux 
        if sum_ressemblance==nb_bit_dans_mdc; % SI X_envoye = X_decode      => sum tous les élément = nb element de la matrice alors MDC bien décodé
            decode_success=1;
        end
        
        if decode_success == 0;
            nb_MDC_decode_faux_pour_SNR=nb_MDC_decode_faux_pour_SNR+1; %on compte un mot décodé faux si jamais y'a au moins une erreur
        end    

        T_rx    = T_rx + toc(rx_tic);  % Mesure du débit de décodage
        
        %Dans step mettre que des vecteurs colonne
        err_stat   = step(stat_erreur, X(:), rec_b(:)); % Comptage des erreurs binaires

        err_stat(2) = nb_MDC_decode_faux_pour_SNR; %On remplace le nombre d'erreur observée par le nombre de mot de code FAUX decodé
        err_stat(3) = nb_MDC_envoye_pour_SNR; %A METTRE !!!
        err_stat(1)= err_stat(2)/err_stat(3);
        %% Affichage du résultat
        if mod(nb_MDC_envoye_pour_SNR,100) == 1
            msg = sprintf(msg_format,...
                EbN0dB(i_snr),         ... % EbN0 en dB
                err_stat(3),           ... % Nombre de bits envoyés
                err_stat(2),           ... % Nombre d'erreurs observées => devient le nombre de mot de code faux decode
                err_stat(1),           ... % BER
                err_stat(3)/8/T_tx/1e3,... % Débit d'encodage
                err_stat(3)/8/T_rx/1e3,... % Débit de décodage
                toc(general_tic)*(nbr_erreur - min(err_stat(2),nbr_erreur))/(min(err_stat(2),nbr_erreur))); % Temps restant
            fprintf(reverseStr);
            msg_sz =  fprintf(msg);
            reverseStr = repmat(sprintf('\b'), 1, msg_sz);
        end
        
    end
    
    msg = sprintf(msg_format,...
        EbN0dB(i_snr),         ... % EbN0 en dB
        err_stat(3),           ... % Nombre de bits envoyés
        err_stat(2),           ... % Nombre d'erreurs observées ============v
        err_stat(1),           ... % BER
        err_stat(3)/8/T_tx/1e3,... % Débit d'encodage
        err_stat(3)/8/T_rx/1e3,... % Débit de décodage
        0); % Temps restant
    fprintf(reverseStr);
    msg_sz =  fprintf(msg);
    reverseStr = repmat(sprintf('\b'), 1, msg_sz);
%     err_stat(2);
%     err_stat(3);
%     err_stat(1)=P_ERROR(i_snr);

    P_ERROR(i_snr) = nb_MDC_decode_faux_pour_SNR/nb_MDC_envoye_pour_SNR; % => Pe= nb_MDC_decode_FAUX/nb_tot_MDC_envoye

    drawnow limitrate
    
    if err_stat(1) < Pe_min
        break
    end
    
end
fprintf('|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')

%%
figure(1)
% semilogy(EbN0dB,P_ERROR);
semilogy(EbN0dB,P_ERROR,'LineWidth',1);
hold all
xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('$P_{error}$','Interpreter', 'latex', 'FontSize',14)
title("Pe par decodeur avec M="+M+"; N="+N+"; L="+L);




% EbN0dB = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de SNR à simuler en dB à simuler
% EbN0   = 10.^(EbN0dB/10); %variance du bruit
% sigma2 = 1./EbN0;

if ML==1
   simulation_name='ML' 
end
if ZF==1
   simulation_name='ZF' 
end
if MMSE==1
   simulation_name='MMSE' 
end
if SIC==1
   simulation_name='SIC' 
end

save('ML','EbN0dB','P_ERROR','M','N','L');











