clear all; close all; clc; beep off;


%% Parametres
% -------------------------------------------------------------------------
%k = nb bit dans un msg
%M = 2^k = nombre de message possible
%n = longueur du msg encodé

R=1;
% bit_par_pqt=2048;
% pqt_par_trame = 1; % Nombre de paquets par trame
% K = pqt_par_trame*bit_par_pqt; % Nombre de bits de message par trame
% N = K/R; % Nombre de bits codés par trame (codée)

M_code = 4; % Modulation BPSK <=> 2 symboles
phi0 = 0; % Offset de phase our la BPSK

EbN0dB_min  = -4; % Minimum de EbN0
EbN0dB_max  = 12; % Maximum de EbN0
EbN0dB_step = 1;% Pas de EbN0

nbr_erreur  = 100;  % Nombre d'erreurs à observer avant de calculer un BER
nbr_bit_max = 100e6;% Nombre de bits max à simuler
ber_min     = 1e-6; % BER min

EbN0dB = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de EbN0 en dB à simuler
EbN0   = 10.^(EbN0dB/10);% Points de EbN0 à simuler
EsN0   = R*log2(M_code)*EbN0; % Points de EsN0
EsN0dB = 10*log10(EsN0); % Points de EsN0 en dB à simuler

% -------------------------------------------------------------------------

%% Construction du modulateur
mod_qpsk = comm.PSKModulator(...
    'ModulationOrder', M_code, ... % QPSK
    'PhaseOffset'    , phi0, ...
    'SymbolMapping'  , 'Gray',...
    'BitInput'       , true);

%% Construction du demodulateur
demod_qpsk = comm.PSKDemodulator(...
    'ModulationOrder', M_code, ...
    'PhaseOffset'    , phi0, ...
    'SymbolMapping'  , 'Gray',...
    'BitOutput'      , true,...
    'DecisionMethod' , 'Log-likelihood ratio');

%% Construction du canal AWGN
awgn_channel = comm.AWGNChannel(...
    'NoiseMethod', 'Signal to noise ratio (Es/No)',...
    'EsNo',EsN0dB(1),...
    'SignalPower',1);

%% Construction de l'objet évaluant le TEB
stat_erreur = comm.ErrorRate(); % Calcul du nombre d'erreur et du BER

%% Initialisation des vecteurs de résultats
ber = zeros(1,length(EbN0dB));
Pe = qfunc(sqrt(2*EbN0));

%% Préparation de l'affichage
figure(1)
h_ber = semilogy(EbN0dB,ber,'XDataSource','EbN0dB', 'YDataSource','ber');
% h_Pe = semilogy(EbN0dB,paquet_err,'XDataSource','EbN0dB', 'YDataSource','Pe');
hold all
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('$P_{error}$','Interpreter', 'latex', 'FontSize',14)

%% Préparation de l'affichage en console
msg_format = '|   %7.2f  |   %9d   |  %9d | %2.2e |  %8.2f kO/s |   %8.2f kO/s |   %8.2f s |\n';

fprintf(      '|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')
msg_header =  '|  Eb/N0 dB  |    Bit nbr    |  Bit err   |   TEB    |    Debit Tx    |     Debit Rx    | Tps restant  |\n';
fprintf(msg_header);
fprintf(      '|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')


M=2; %Nombre d'antennes de réception
N=2; %Nombre d'antennes d'émission
L=1; %Nombre de symboles transmis

H = randn(M,N) + 1i*randn(M,N); % [MxN] % Constante, contient les h_m_n = gain complexe entre n_eme antenne emission et m_eme antenne reception
% V = sqrt(sigma2/2) *((randn(M,L) + 1i*randn(M,L)));

verif=0;
%% Simulation
for i_snr = 1:length(EbN0dB)
    reverseStr = ''; % Pour affichage en console
    awgn_channel.EsNo = EsN0dB(i_snr);% Mise a jour du EbN0 pour le canal
    
    stat_erreur.reset; % reset du compteur d'erreur
    err_stat    = [0 0 0]; % vecteur résultat de stat_erreur
    
    erreur_dans_paquet = 0;
    taux_erreur_paquets = 0;
    
    demod_qpsk.Variance = awgn_channel.Variance;
    
    n_frame = 0;
    T_rx = 0;
    T_tx = 0;
    general_tic = tic;
    while (err_stat(2) < nbr_erreur && err_stat(3) < nbr_bit_max)
        n_frame = n_frame + 1;
        
        %% Emetteur
        tx_tic = tic; % Mesure du débit d'encodage
     
        symboles_x_all = randi([0 1], 1, N*L) + 1i * randi([0 1], 1, N*L); %2 symboles aléatoires déjà modulés par mes soins

        X = reshape(symboles_x_all,N,L); % [NxL] %Mot de code avec les symboles répartis verticalement
        %krari c'est encodé verticale à la V-BLAST
        
        T_tx   = T_tx+toc(tx_tic);    % Mesure du débit d'encodage
        
        %% Canal
        
        mot_de_code_transmis = H*X; %H = matrice avec les gains complexes entre les antennes
                                   %1. Y = H*X
        
        %Y=mot_de_code_transmis % sans bruit pour commencer                     
                                   
        Y = step(awgn_channel,mot_de_code_transmis); % Ajout d'un bruit gaussien au message transmis
        %2. Y = Y+V; 
%       Y = H*X+V; % [MxL] = [MxN] x [NxL] + [MxL] % Ce qu'on reçoit 

        %% Recepteur
        rx_tic = tic;                  % Mesure du débit de décodage

        %Mon decodeur fait tout: demodulation et decision il parle 0 chinois
        
        % ML
%         rec_b=decode_ML(Y,H,X);
%         rec_b = decode_ML_mieux(Y,H,X); % !!! Marche pour toute taille de L, même L=1 !!!
        
        % ZF
        [X_dec] = decode_ZF(H, Y);

        rec_b=complex(X_dec); %pcq des fois en décodant mal il oublie de préciser partie imaginaire nulle
        
        if verif==1
            decode_success=0;
            sum_ressemblance=sum(sum(X==rec_b));
            if sum_ressemblance==N*L;
                decode_success=1;
            end
            msg_recu_egal_msg_envoye=isequal(X,rec_b)*1  %voir si msg_recu=msg_envoye SANS BRUIT
            diff_entre_msg_envoye_msg_recu = find(X~=rec_b)
            nb_differences=length(diff_entre_msg_envoye_msg_recu)
            X
            rec_b
            decode_success
        end
        
        

        T_rx    = T_rx + toc(rx_tic);  % Mesure du débit de décodage
        
        %Dans step mettre que des vecteurs colonne
        err_stat   = step(stat_erreur, X(:), rec_b(:)); % Comptage des erreurs binaires
        
        
        %% Affichage du résultat
        if mod(n_frame,100) == 1
            msg = sprintf(msg_format,...
                EbN0dB(i_snr),         ... % EbN0 en dB
                err_stat(3),           ... % Nombre de bits envoyés
                err_stat(2),           ... % Nombre d'erreurs observées
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
    
%     ber(i_snr) = err_stat(1);              %JUSTE TEB
    ber(i_snr) = err_stat(2)/err_stat(3);    % => Pe= nb_erreur/nb_tot bits envoyé
    refreshdata(h_ber);
    drawnow limitrate
    
    if err_stat(1) < ber_min
        break
    end
    
end
fprintf('|------------|---------------|------------|----------|----------------|-----------------|--------------|\n')

%%
figure(1)
semilogy(EbN0dB,ber,'k');
% semilogy(EbN0dB,paquet_err,'--');
hold all
xlim([0 10])
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('$P_{error}$','Interpreter', 'latex', 'FontSize',14)
title("ML decoder M="+M+"; N="+N+"; L="+L);

save('ZF','EbN0dB','ber')















