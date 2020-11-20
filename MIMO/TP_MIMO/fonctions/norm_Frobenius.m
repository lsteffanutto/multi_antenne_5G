function [A_normed] = norm_Frobenius(A)
%retourne norm Frobenius d'une matrice A, ||A||^2_F = trace(A*A') %cours antenne p.65

A_normed = trace(A*A');

end

