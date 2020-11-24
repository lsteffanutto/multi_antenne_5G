function [A_pseudo_inverse,matrice_ok] = pseudo_inverse(A)

[U,S,V] = svd(A);

[M,r1]=size(U);
[N,r2]=size(V);

matrice_ok=0;

if rank(A)==r1 && r1==r2 %condition matrice semi-positive
    matrice_ok=1;
    A_pseudo_inverse = V*S^(-1)*U';
end

end

