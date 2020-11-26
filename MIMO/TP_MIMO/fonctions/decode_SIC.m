function [X_res] = decode_SIC(H, Y)
% decode SIC
[M,N]=size(H);

[Q,R]=qr(H); %Q=[MxN] et R=[NxN]

Z=Q'*Y;
[N,L]=size(Z);

nb_symboles_possibles=N*M;
%BAILS POUR GENERER TOUS LES SYMBOLES QPSK
combis_bits=(0:nb_symboles_possibles-1);
combis_bits=str2num(dec2bin(combis_bits));
reel_part = num2str(combis_bits)-'0';
reel_part(reel_part==-16) = 0;
alphabet_QPSK = [reel_part(:,1)+1i*reel_part(:,2)];
%%%

%On décode d'abord la dernière ligne de X_dec

diff = zeros(nb_symboles_possibles,1); %Stock les diff d'un symbole a decode avec chaque symbole QPSK
ligne_decode=diff;
X_res=Z;

%On décode d'abord la dernière ligne:
% 1. Go dernière ligne N
% 2. On fixe le l et on décode le symbole x_N_l
% 3. Puis tu change de l et tu redecode et ça jusqu'à finir la ligne

% On commence par la dernière ligne
for l = 1:L %On commence par première colonne L=1 => element(N,1)
        
    z_a_decode=complex(Z(N,l)); %on met complexe sinon il le mets en réel des fois
    element_R_diag=R(N,N);
    
    diff = abs(z_a_decode-(element_R_diag*alphabet_QPSK)); %on prend chaque symbole z a decode et on les compare d'un coup à tous les mots QPSK
    
    diff = diff.^2;
    
    [diff_min index_dec]=min(diff);
    
    X_res(N,l)=alphabet_QPSK(index_dec); %on récupère comme décision, le symbole QPSK qui minimise cette différence
    
end % Puis on itère sur les autres éléments des autres colonnescolonne L=2 => element(N,2)

% Denière ligne => décodage OK

% à présent on refait la même en remontant au fur à mesure
%POUR CHAQUE LIGNE
for n = N-1:-1:1 % cas N=2 et L=1 => n=1
    
    for l = 1:L %POUR CHAQUE ELEMENT DE LA LIGNE
        
        z_a_decode=complex(Z(n,l)); %z_n_l
        element_R_diag=complex(R(n,n));      %r_n_n
        
        sum=0;
        for k=n+1:N %N=2 première étape => k=2 = dernière ligne qu'on a décodé avant
            
            element_R_diag_temp=complex(R(n,k)); %r_n_k, première étape => N=2, n=1; r_n_k=r_1_2
            x_dec_prev=complex(X_res(k,l));  %x_dec_k_l=x_dec_2_1=celui qu'in a décodé juste avant en dessous
            sum=sum+(element_R_diag_temp*x_dec_prev);
            
        end %fin de la sum avec les coeff r et les x_dec precedent
        
        diff = abs(z_a_decode-sum-(element_R_diag*alphabet_QPSK)); %|z_n_l-sum-r_n_n*z|
        diff = diff.^2;
        
        [diff_min index_dec]=min(diff);
        X_res(n,l)=alphabet_QPSK(index_dec); % x_dec(n,l)
        
    end
    
end

% for l=N:-1:1
%     
%     ligne_decode(1,:)=Z(j,:); 
%     
%     element_R_diag=R(j,j); %r_N_N
%     
% %     symbole_test(:,1) = complex(Z_a_decode(j)); %on met complexe sinon il le mets en réel des fois
%     
%     
%     diff = (ligne_decode-alphabet_QPSK).^2;        %on prend chaque symbole z a decode et on les compare d'un coup à tous les mots QPSK
%     
%     [diff_min index_dec]=min(diff);
%     
%     X_res(j)=alphabet_QPSK(index_dec); %on récupère comme décision, le symbole QPSK qui minimise cette différence
% end

end

