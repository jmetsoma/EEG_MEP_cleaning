%% Select subject, example of loading data from raw data EEGlab file
subject = {'REFTEP_009'}
filename = [subject{:} '_TEP.set'];
EEGLAB_DATA_PATH='X:\2018-06 REFTEP (Raw EEGLAB)';
cd(fileparts(getfield(matlab.desktop.editor.getActive, 'Filename')));
TOOLBOXPATH = ['..' filesep '..' filesep 'toolboxes'];
addpath(fullfile(TOOLBOXPATH, 'eeglab14_1_2b'))
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename', filename, 'filepath', EEGLAB_DATA_PATH);

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
    if 0
    EMG = pop_select(EEG, 'channel', [-1 0] + length(EEG.chanlocs));
    EMG = pop_epoch(EMG, {'A - Out'}, [-0.5 0.5]);
    ftdata_emg = eeglab2fieldtrip(EMG, 'preprocessing');
    ftdata_emg.trialinfo = [1:length(ftdata_emg.trial)]';
    clear('EMG')
    end
    EEG = pop_select(EEG, 'channel', 1:126); %selecting EEG channels only
    EEG = pop_epoch(EEG, {'A - Out'}, [-1.5 -.05]); %epoching in s
    %
    EEG = pop_rmbase(EEG, [-1500 -3]); %setting the offset in baseline to 0
    EEG = pop_resample( EEG, 1000); % resample
    
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
%% fastica toolbox and EEGlab toolbox with dipfit plugin needed for running the following
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% instead of the top cell. Simply load epoched EEGlab struct if exists.
%% First detrend for noise detection. Consider using heavier detrending here than for final detrending 
% all data sets as (channels x time points x epochs)
% recommendations based on heuristics:
% if SF=1000Hz, use regularization coeff = 1e5
% if SF=5000Hz, use regularization coeff = 1e6
X=bnp_detrendLaplace(double(EEG.data), 1e5); % The latter is a regularization factor (the smaller, the more the trendline follows the original signal)
%% bad chs and trials

% 1. estimate noise. Use detrended data.
% Again the second input param is for regularization.
% If the cap has few channels( ~ 60), normalizing with lead-field matrix is recommended to avoid
% bias (too large noise estimates in the periphery). Using bias_coeff in
% the next step will take care of the normalization
 LFM=ComputeSphericalLFM(EEG, 'FCz'); % to compute LFM if it does not exist already
[noise, bias_coef]=bnp_estimateNoise_EEGlab(X, 1e-4, LFM, EEG);
%%
% bad Channel and trial estimation
% Output: badCh and badTr are logical vectors: 1 = removed channel/epoch 
% Input: data (might be different from previous input data), EEG struct
% ,noise estimate, detrended data (if different from the 1. input), and
% bias_coef from previous step if applicable
[Xremoved, badCh, badTr]=bnp_detectNoisyChannelsEpochs_EEGlab(X,EEG, noise, X, bias_coef); 

%% average referencing (if desired). This cannot be performed before noise estimatio. 
XremovedR=Xremoved-mean(Xremoved,1);
%% Run ica, and choose removable components
% bad trials and channels have been removed prior to this step
fs=EEG.srate;
[Xcleaned, A2, W2, ~, badComps]=bnp_detectBadICs_EEGlab(XremovedR,EEG.chanlocs, badCh, fs);
%% option for rechoosing removable components
% the input data can also be different from original data used for ICA
% computations. However, some statistics may not hold in that case, and leakage between components may arise.
% Same bad channels should be removed first.
[Xcleaned,S2, badComps]=bnp_chooseBadICs_EEGlab(Xcleaned,EEG.chanlocs, badCh,fs, A2, W2, badComps);

%% Aligning the EEG and EMG trials
% removing the needed trials such that the both bad EEG and EMG trials have
% been removed in the final data
[AmpsAl, XAl, indsTot]=bnp_alignEEGandEMGtrials(Xcleaned, AmpsM,badTrEMG, badTr);
%% save
