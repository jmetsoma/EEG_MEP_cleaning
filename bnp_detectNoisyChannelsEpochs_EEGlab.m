function [Xremoved, badCh, badTr]=bnp_detectNoisyChannelsEpochs_EEGlab(Xoriginal, EEG, noise, X, bias_coeff)
% semi-automatic bad channel and trial removal based on estimated noise with graphical interface
%
% input:
% Xoriginal: 3D data channels X time points X trials
% EEG: EEGlab struct
% noise: 3D estimated noise with same dimensions as data
% X: set same as Xoriginal 
% bias_coef: noise levels for channels if only brainEEG is recorded. Can be
% set []
%
% output:
% Xremoved: input data with bad channels and trials removed
% badCh: bad channels
% badTr: bad trials
%
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
if isempty(X)
    X=Xoriginal;
end
if isempty(bias_coeff)
    bias_coeff=ones(size(Xoriginal,1),1);
end
X=X-mean(X,1);
%noise=noise-mean(noise,1);

badCh=findBadCh2_EEGlab(noise./bias_coeff, EEG.chanlocs, X./bias_coeff);
badTr=findBadTr2(noise, X, badCh);

% remove bad chs and trials
if Xoriginal
Xremoved=Xoriginal; Xremoved(badCh,:,:)=[]; Xremoved(:,:,badTr)=[];
else
    
Xremoved=Xnoise; Xremoved(badCh,:,:)=[]; Xremoved(:,:,badTr)=[];
end