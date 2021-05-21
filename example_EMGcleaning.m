
% the EMG data as (channels x time points x  trials)
% remove all the redundant channels at this point to avoid extra work
% If bad trials are determined for each channel separately, run this script
% for each channel separately. Then, align with EEG also separately.
dataEMG=permute(EMG1.data,[1 2 3]);
%time vector
times=EMG1.times/1000;
% sample rate
fs=EMG1.srate;
%% detrending and eliminating 50 Hz
[THchns, YestBL, Yest, t_mep_end]=bnp_detrendEMG(dataEMG(:,:,:), times, fs);
%% checking the for preinnervation
time_preinnervation=-300; % the time  (relative to TMS) from which preinnervation is checked
[badTrEMG]=bnp_detectPreinnervation(dataEMG, YestBL, THchns, times, time_preinnervation, false);
%% fitting and removing exponential decay artifact
[AmpsM, RMSE]=bnp_removeTMSartifact(Yest, times, badTrEMG, t_mep_end);

%% Aligning the EEG and EMG trials

[AmpsAligned, XAligned]=bnp_alignEEGandEMGtrials(Xcleaned, AmpsM,badTrEMG, badTr);
