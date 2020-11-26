function [X_res] = decode_MMSE(H, Y, sigma2)
% décode MMSE (sigma2=0 on doit retrouver ZF)

[M,N]=size(H);
% 1. Trouver pseudo_inverse_H
[H_pseudo,matrice_ok] = pseudo_inverse(H); %[U,S,V] = svd(H) et H = V*S^-1*U' => F_zf*=H+

%QPSK => Q=Id
Q=eye(M);

%F_MMSE = (HQH'+sigma2)^-1*H*Q;
F_MMSE = ((H*Q*H'+sigma2)^-1)*H*Q; 

% PUIS MEME CHOSE QUE POUR ZF
Z = F_MMSE'*Y; 

[N,L]=size(Z);
[M,~]=size(Y);
% 3. On décode symbole par symbole
nb_symboles_possibles=N*M;

Z_a_decode=Z(:);

%BAILS POUR GENERER TOUS LES SYMBOLES QPSK
combis_bits=(0:nb_symboles_possibles-1);
combis_bits=str2num(dec2bin(combis_bits));
reel_part = num2str(combis_bits)-'0';
reel_part(reel_part==-16) = 0;
alphabet_QPSK = [reel_part(:,1)+1i*reel_part(:,2)];
%%%

% Pour chaque symbole de Z tu vas le comparer avec diff/norm des symboles alphabet_QPSK

diff = zeros(nb_symboles_possibles,1); %Stock les diff d'un symbole a decode avec chaque symbole QPSK
symbole_test=diff;
X_res=Z;

for j=1:length(Z_a_decode)
    
    symbole_test(:,1) = complex(Z_a_decode(j)); %on met complexe sinon il le mets en réel des fois
    
    
    diff = abs((symbole_test-alphabet_QPSK)).^2;        %on prend chaque symbole z a decode et on les compare d'un coup à tous les mots QPSK
    
    [diff_min index_dec]=min(diff);
    
    X_res(j)=alphabet_QPSK(index_dec); %on récupère comme décision, le symbole QPSK qui minimise cette différence
end




end

