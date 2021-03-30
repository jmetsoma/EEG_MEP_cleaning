function [noise, bias_coeff]=bnp_estimateNoise_EEGlab(Xnoise, rf, LFM, EEG)
%
% function computing the uncorrelated noise over channels using the
% data-driven Wiener estimator
%
% input:
% Xnoise: noisy data with dims: channels x time points x trials
% rf: regularization factor for data-driven Wiener estimation e.g. 1e-4
% LFM: lead-field matrix struct with fields: 1)labels (of channels) and 
% LFM_sphere which is the LFM itself. Can also be [] 
%
% output:
% noise: estimated noise with same dimensions as input data
% bias_coeff: the noise levels in each channel if given brain EEG (as
% represented bv LFM). Generally, peripheral channels have bias towards
% higher values of noise level.
%
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
[y_solved, ~ ] = simple_wiener(Xnoise,rf);
noise=Xnoise-y_solved;

if ~isempty(LFM)
    [~, elec_indx]=ismember({EEG.chanlocs(:).labels}, LFM.labels); % position of leadfield channel in data channel
    LFM_sphere_reordered = LFM.LFM_sphere(elec_indx,:);
    [noise_LFM, sigma_LFM ] = simple_wiener(LFM_sphere_reordered,rf);
    
    bias_coeff=sqrt(sigma_LFM);
    

    figure, topoplot(bias_coeff, EEG.chanlocs); title('bias coefficients')
    colormap('parula')
else
    bias_coeff=[];
end
