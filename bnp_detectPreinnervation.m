function [badTr]=bnp_detectPreinnervation(datacube_emg,YestBL, THchns, ts, t0, auto)
%
% Checking though the trials whose amplitude range withing the baseline
% period exceeds the threshold.
% The user determines whether the trial is removed or kept.
%
% input:
% datacube_emg: (channels x times x trials) EMG data
% YestBL: (times x trials x channels) detrended EMG data from the baseline
% period.
% THchns: (channels x 1) thresholds for detecting pre-innervation
% ts: (1 x time instants) time axis (ms)
% t0: the start time for detecting EMG spikes (ms)
% auto: true if no user input required, and bad trials rejected based on
% given THchns
%
% output:
% badTr: (trials x 1) boolean-valued vector, where true mean bad trial
%
% .........................................................................
% 18 May 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................

gc=[0 0 0]+0.5;
R=size(YestBL,2);
EMG_chn=size(YestBL,3);
t1=-5/1000; 
[~, it1]=min(abs(ts-t1));
[~, it_pre]=min(abs(ts-(-10/1000)));
[~, it_pre0]=min(abs(ts-(t0/1000)));
goodTrials=ones(1, R); 
if EMG_chn==1
    indsLim=find(squeeze(range(YestBL(it_pre0:it_pre,:, :),1))>THchns)';
else
    indsLim=find(sum(squeeze(range(YestBL(it_pre0:it_pre,:, :),1))>THchns,2))';
end

if auto
    goodTrials(indsLim)=0;
    
else
figure('units','normalized','outerposition',[0 0 1 1])
for i=indsLim
    for j=1:EMG_chn
        
    subplot(EMG_chn,1,j)
    hold off
    plot(ts(1:it1),datacube_emg(j,1:it1,i)-mean(datacube_emg(j,1:it1,i)), 'color', gc)
    hold on
    plot(ts(1:it1),YestBL(1:it1,i,j),'r', 'linewidth', 1.5)
    plot([ts(1) 0], [THchns(j)/2 THchns(j)/2], '--k', 'handlevisibility', 'off')
    plot([ts(1) 0], [-THchns(j)/2 -THchns(j)/2], '--k', 'handlevisibility', 'off')
    if j==1
    title({[' Rechecking for pre-innervation in trial ' num2str(i)]; 'Press space to reject.';'Right-click to accept.'})
    end
    axis([ts(1) 0 -THchns(j)*3 THchns(j)*3])
    end
    [~, ~, bb]=ginput(1); 
    if bb==32
        goodTrials(i)=0;
    end
end
end
disp([num2str(sum(goodTrials==0)) 'trials rejected'])
badTr=(goodTrials==0);