


function psd=computePSDforMultiEpochs(X, nFFT, nOverlap, f, fs)
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................

if ndims(X)==3

    [M, T, R]=size(X);
else 
    M=1;
    [T, R]=size(X);
end
    
psd=zeros(M,length(f));
for i=1:M
    
    S=zeros(length(f),R);
    for j=1:R
        [s,~,~]=spectrogram(squeeze(X(i,:,j)), hamming(nFFT), nOverlap, f, fs);
        
        S(:,j)=s;
            
    end
    psd(i,:)=mean(abs(S).^2,2);
end