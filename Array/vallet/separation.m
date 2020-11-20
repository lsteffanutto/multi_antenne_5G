function [nb_sources,P,axe_theta,R,a_theta] = separation(signal_struct)
    %% Initialisation
    signal_2=signal_struct.data;
    F=signal_struct.Fs;
    signal=signal_2(:,2*F+1:end); % 2 premières secondes=bruit
    M=length(signal(:,1));
    N=length(signal(1,:));
    
    R=zeros(M); % Covariance signal
    Rbruit=zeros(M); % Covariance bruit
    
    sound(signal(1,:),F); % Ecoute du signal sur le premier capteur
    
    % Calcul de Rbruit
    for i=1:2*F
        Rbruit=Rbruit+signal_2(:,i)*signal_2(:,i)';
    end
    Rbruit=1/(2*F)*Rbruit; 
    
    % Calcul de R
    for j=1:N
        R=R+signal(:,j)*signal(:,j)';
    end
    R=1/N*R; 
    
    %% Calcul nb_sources
    e=eig(R);
    e=rot90(rot90(e)); 
    ebruit=eig(Rbruit);
    ebruit=rot90(rot90(ebruit));
    
    moy=round(mean(ebruit),7);
    nb_sources=length(find(ebruit>moy));
    
    %% Séparation
    axe_theta=-90:0.1:90;
    a_theta=zeros(M,length(axe_theta));
    
    k=1;
    for theta=axe_theta
        for source=1:M
            a_theta(source,k)=exp(-1i*pi*(source-1)*sin(deg2rad(theta)));
            P(1,k)=1/(a_theta(:,k)'*R^(-1)*a_theta(:,k));
        end
        k=k+1;
    end
end