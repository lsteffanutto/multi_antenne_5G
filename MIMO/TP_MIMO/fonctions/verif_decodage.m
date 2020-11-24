function [decode_success] = verif_decodage(X,X_dec)
% retourne si le mot de code decode est bien egal au mot d ecode envoyé

decode_success=0;

[N,L]=size(X);

sum_ressemblance=sum(sum(X==X_dec));
if sum_ressemblance==N*L;
    decode_success=1;
end


end

