function [X_dec] = decode_ML_mieux(Y,H,X_tot)
% décode ML, choisir mot de code X qui  minimise distance entre observation Y et HX
% 1. Tu test tous les mots de code possible
% 2. Tu regarde la distance Y - HX
% 3. Tu prend le mot de code qui donne la distance minimale
X_res=X_tot;
Y_tot = Y;
% on veut décoder les symboles 2 par 2 de tous le merdier de X
[N_tot,L_tot] = size(X_tot); % L_tot = nb de symbol total modulé et arrangé en V-blast

X = X_tot(:,:); % on prend tout

[Alphabet_X] = generer_Alphabet_QPSK_X(X); % [2x2x256]
[M,~]=size(H);
[N,L,taille_alphabet]=size(Alphabet_X);

diff = zeros(M,L);
diff_tab = zeros(taille_alphabet,1); %stockage des diff avec chaque mot de code
 
for i = 1:taille_alphabet
    
    diff = Y-H*Alphabet_X(:,:,i);
    
    diff = norm_Frobenius(diff);
    
    diff_tab(i) = diff;
end

[diff_min index_dec]=min(diff_tab); %On prend l'index de la diff min

X_dec=Alphabet_X(:,:,index_dec); % Et on renvoie le mot de code associé à cet index pour la décision
end

