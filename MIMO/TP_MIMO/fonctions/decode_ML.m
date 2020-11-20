function [X_res] = decode_ML(Y,H,X_tot)
% décode ML, choisir mot de code X qui  minimise distance entre observation Y et HX
% 1. Tu test tous les mots de code possible
% 2. Tu regarde la distance Y - HX
% 3. Tu prend le mot de code qui donne la distance minimale
X_res=X_tot;
Y_tot = Y;
% on veut décoder les symboles 2 par 2 de tous le merdier de X
[N_tot,L_tot] = size(X_tot); % L_tot = nb de symbol total modulé et arrangé en V-blast
nb_paquet = L_tot/2; % on les envoie 2 par 2

% X_tot = reshape(symboles_x_all,N,L);


for paquet = 1:nb_paquet %on coupe le mega message en entree en message de 2 symboles (on prend 2 premiere colonnes etc)

X = X_tot(:,1:2); % on prend toujours les 2 premiers symboles car on décode 2 par 2
X_tot(:,1:2) = []; % comme on est entrain de les décoder on les enleve du msg de depart

Y = Y_tot(:,1:2); % même chose avec les Y qui sont la réception observé
Y_tot(:,1:2) = []; %pareil on enleve les 2 premiers quand on les a traité

if L_tot==1
    X=X_tot;
    Y=Y_tot;
end

%%% Decodage 2 symboles par 2 symboles de tout ce qu'on reçoit
[Alphabet_X] = generer_Alphabet_QPSK_X(X); % [2x2x256]
[M,~]=size(H);
[N,L,taille_alphabet]=size(Alphabet_X);

diff = zeros(M,L);
index_X_decode=0;
diff_tab = zeros(taille_alphabet,1); %stockage des diff avec chaque mot de code
 
for i = 1:taille_alphabet
    
    diff = Y-H*Alphabet_X(:,:,i);
    
    diff = norm_Frobenius(diff);
    
    diff_tab(i) = diff;
end

[diff_min index_dec]=min(diff_tab); %On prend l'index de la diff min

X_dec=Alphabet_X(:,:,index_dec); % Et on renvoie le mot de code associé à cet index pour la décision

%%%%%%%%%%%% Fin decodage 2 par 2, et on recommence avec un autre paquet de 2 symboles


X_res(:,(2*nb_paquet-1):nb_paquet*2)=X_dec(:,:); %On stock les décisions dans un vecteur qu'on renvoie

end

end

