function [Xtr3d]=bnp_detrendLaplace(Xtr3,lambda)
%
% Laplacian detrending function, where trendline is assumed to have a small
% value of laplacian operator in time domain (non-spiky)
%
%input: 
% Xtr3: The 3D data matrix channels x time points x trials
% lambda: regularization coefficient. If larger, the trendline becomes
% smoother and, if smaller, the trendline starts following the original EEG
% signal more precisely
% if fs=5kHz, e.g. lambda =1e6 is reasonable, if fs=1kHz l, lambda=1e5 is
% reasonable
% 
% output: 
% Xtr3d: detrended data with same dimensions as input
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................

[Nc,Nt, Nr]=size(Xtr3);
I = speye(Nt);
D2 = spdiags(ones(Nt-2,1)*[1 -2 1],[0:2],Nt-2,Nt);

Xtr3d=zeros(Nc, Nt, Nr);
for i=1:Nr
trend = ((I+lambda^2*(D2'*D2))\squeeze(Xtr3(:,:,i))')';
Xtr3d(:,:,i)=Xtr3(:,:,i)-trend;

end

Xtr3d=Xtr3d-mean(Xtr3d,2);