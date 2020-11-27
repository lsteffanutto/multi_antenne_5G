function [X_dec] = decode_ML_ALAMOUTI(Y,H)
%decode ML Alamouti

[~,N]=size(H);
[M,~]=size(Y);
% 3. On décode symbole par symbole
nb_symboles_possibles=N*M;

%BAILS POUR GENERER TOUS LES SYMBOLES QPSK
combis_bits=(0:nb_symboles_possibles-1);
combis_bits=str2num(dec2bin(combis_bits));
reel_part = num2str(combis_bits)-'0';
reel_part(reel_part==-16) = 0;
alphabet_QPSK = [reel_part(:,1)+1i*reel_part(:,2)];
%%%

h1=H(:,1);
h2=H(:,2);

y1=Y(:,1);
y2=Y(:,2);

z1=h1'*y1+y2'*h2;
z2=h2'*y1-y2'*h1;

diff = zeros(nb_symboles_possibles,1); %Stock les diff d'un symbole a decode avec chaque symbole QPSK
symbole_test=diff;
X_res=zeros(2,2);

diff_1=abs(z1-norm_Frobenius(H)*alphabet_QPSK).^2;
[diff1_min index_dec1]=min(diff_1);
x1_dec=alphabet_QPSK(index_dec1);

diff_2=abs(z2-norm_Frobenius(H)*alphabet_QPSK).^2;
[diff2_min index_dec2]=min(diff_2);
x2_dec=alphabet_QPSK(index_dec2);

x_1_2 = -x2_dec';
x_2_2 = x1_dec';

X_dec=[x1_dec x_1_2 ; x2_dec x_2_2];

end

