function [Alphabet_X] = generer_Alphabet_QPSK_X(X)
% Genere tous les mots de code possible à pa
[N,L]=size(X);

nb_symboles=N*L;
nb_combinaisions=2^nb_symboles;
taille_alphabet=nb_combinaisions*nb_combinaisions;
Alphabet_X=zeros(N,L,taille_alphabet);

%Toutes combinaison possibles de la partie réelle pour les symboles de X
combis_bits=(0:nb_combinaisions-1);
combis_bits=str2num(dec2bin(combis_bits));
reel_part = num2str(combis_bits)-'0';
reel_part(reel_part==-16) = 0;

X_reel = reshape(reel_part',N,L,nb_combinaisions); %toutes combi possible partie reel
X_im = 1i*reshape(reel_part',N,L,nb_combinaisions); %toutes combi possible partie imaginaire

% maintenant, pour chaque combi partie reel on lui associe toutes les
% combis possible imaginaire et on a tout l'alphabet

X_reel_associe_full_X_im = 1:nb_combinaisions:taille_alphabet;

X1=X_reel(:,:,1)+X_im;
X2=X_reel(:,:,2)+X_im;



for i=1:nb_combinaisions % Pour les 16 X_reels possibles, on leur associe a chacun les 16 X_im possibles
    Xi=X_reel(:,:,i)+X_im;
    
    if i==1 % 1 à 16
        Alphabet_X(:,:,1:(i)*nb_combinaisions)=Xi;
    
    else % 17 à 32
        Alphabet_X(:,:,(i-1)*nb_combinaisions+1:i*nb_combinaisions)=Xi;
        
    end
    
end

verif = sum(sum(sum(Alphabet_X))); %verif si bien toutes les possibilites;
end

