function [y_solved, sigmas] = simple_wiener(data,rf)

% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................

        [Nc, Nt, Nr]=size(data);
        data=reshape(data, Nc, []);
        C = cov(data');
        c=sum(diag(C));
        y_solved=zeros(Nc, Nt* Nr);
        for i=1:Nc
            %disp(['Channel: ' num2str(i)])
            idiff = setdiff(1:Nc,i);
            y_solved(i,:) = C(i,idiff)*((C(idiff,idiff)+c*rf/(Nc-1)*eye(Nc-1))\data(idiff,:));
        end
        sigmas = (diag((data-y_solved)*(data-y_solved)'))/(size(data,2));
        y_solved=reshape(y_solved, [Nc, Nt, Nr]);
        
        
