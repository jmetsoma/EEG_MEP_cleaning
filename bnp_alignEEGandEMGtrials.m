function [AmpsAl, XAl, totalInds]=bnp_alignEEGandEMGtrials(Xfinal, Amps,badTrEMG, badTrEEG)

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
    