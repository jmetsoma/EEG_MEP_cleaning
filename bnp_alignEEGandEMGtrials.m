function [AmpsAl, XAl, totalInds]=bnp_alignEEGandEMGtrials(Xfinal, Amps,badTrEMG, badTrEEG)
% function to select align the EEG epochs and the MEP amplitudes (both bad
% EEG and EMG trials have been removed from the output data
%
% input:
% Xfinal: Clean EEG data (channels x time points x trials) where EEG bad trials
% where removed
% Amps: Clean MEP amplitudes (trials x channels) where bad EMG trials where
% removed
% badTrEMG: bad EMG trial vector (boolean: true means bad) size = 1 x number of
% trials in the original data
% badTrEEG: bad EEG trials as above
%
% output:
% AmpsAl: MEP amplitudes (trials x channels) with trials aligned with ...
% XAl: EEG data (channels x trials)
% totalInds: indices of the output data trials as referred to the original
% data sets (boolean-valued where true equals to selected data trial, ...
% 1 x number of trials in the orig data)
% 
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
if ~islogical(badTrEMG)
    badTrEMG2=false(size(Amps,1)+length(badTrEMG),1);
    badTrEEG2=badTrEMG2;
    badTrEMG2(badTrEMG)=true;
    badTrEEG2(badTrEEG)=true;
    badTrEMG=badTrEMG2;
    badTrEEG=badTrEEG2;
end
% make sure MEPs are cleaned first before proceeding !
% Remove bad EEG trials from good EMG trial indices
goodTrials=~badTrEMG;

goodEMGTrialsRest=goodTrials(~badTrEEG);

% Pick up only good EMG trials from the remaining EEG trials
XAl=Xfinal(:,:,goodEMGTrialsRest);

% Set good EEG trials
goodTrialsEEG=~badTrEEG;
% Remove bad EMG trials from good EEG trial indices
goodTrialsEEGrest=goodTrialsEEG(~badTrEMG); 
% Pick up only good EEG trials from the remaining EEG trials
AmpsAl=Amps(goodTrialsEEGrest,:);

totalInds=~(badTrEMG | badTrEEG);
    