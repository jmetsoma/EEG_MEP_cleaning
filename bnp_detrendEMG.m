function [THchns, YestBL, Yest, t2]=bnp_detrendEMG(datacube_emg, ts, fs)
%
% robust removal of slow trends and 50-Hz noise from the EMG signal
% The user defines the window which is excluded from estimating the trend
% and the noise.
% The user also selects the thresholds for excluding pre-innervated trials
%
% input:
% datacube_emg: (channels x times x trials) EMG signals
% ts: (1 x time instants) time axis in seconds (ms)
% fs: sampling frequency
%
% output:
% Thchns: (1 x channels) thresholds for detecting pre-innervation
% YestBL: (times x trials x channels) estimate signal for preTMS time interval 
% Yest: (times x trials x channels) estimate signal
% t2: end time of the excluded data window, as selected by the user
%
% .........................................................................
% 18 May 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................

gc=[0 0 0]+0.5;

R=size(datacube_emg,3);

for EMG_chn=1:size(datacube_emg,1)% set here the relevant row of ftdata_emg.trial
close all
Y(:,:, EMG_chn)=double(squeeze(datacube_emg(EMG_chn,:,:)));


t1=-5/1000; t2=0.06;

[~, it1]=min(abs(ts-t1));
[~, it2]=min(abs(ts-t2));
Y(:,:, EMG_chn)=Y(:,:, EMG_chn)-repmat(mean(Y(1:it1,:, EMG_chn)),[size(Y,1),1]);
figure('units','normalized','outerposition',[0 0 1 1]), subplot(2,1,1), hold off

plot(ts,Y(:,:,EMG_chn)+repmat((0:(R-1))*00,[length(ts), 1]), 'k');
v=axis;
title({'Left-click to move the green boundary.' ;'Define the area including the artifact and MEP between the vertical lines.'; 'Right-click to proceed with correcting for baseline and 50Hz noise.'})
hold on, plot([t1 t1], v([3 4]),'r', 'linewidth', 1.5), h21=plot([t2 t2], v([3 4]), 'g', 'linewidth', 1.5);
sa2=subplot(2,1,2); hold off
plot(ts,Y(:,:, EMG_chn)+repmat((0:(R-1))*00,[length(ts), 1]), 'k');

axis([t1-0.01 t2+0.01 v(3:4)])
hold on, plot([t1 t1], v([3 4]),'r', 'linewidth', 1.5), h22=plot([t2 t2], v([3 4]), 'g', 'linewidth', 1.5);

xlabel('Time (s)')
ylabel('Amplitude (\muV)')
[t2,~,bm]=ginput(1);

while bm==1
    
    
    set(h22, 'Xdata', [t2 t2])
    set(sa2, 'xlim',[t1-0.01 t2+0.01]) 
    set(h21, 'Xdata', [t2 t2])
    
    [~, it2]=min(abs(ts-t2));
    [t2,~,bm]=ginput(1);  
end
t2=ts(it2);


for i=1:R
[yestim,~]=removeTrendlineLaplaceMEP2(Y(:,i, EMG_chn)', it1, it2, 1, 1e4);
[yestimBL,~]=removeTrendlineLaplaceMEP2(Y(1:it1,i, EMG_chn)', [], [], 0, 1e3);
[yestim2, ytrend]=fitRemoveFrequency([yestimBL zeros(1,length(ts)-it1)], [1:it1], 50, fs);
Yest(:,i, EMG_chn)=yestim-ytrend;
YestBL(:,i, EMG_chn)=yestim2(1:it1);
end
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,1)

plot(ts,squeeze(Yest(:,:, EMG_chn)), 'k');
title('Corrected EMG. Click to proceed to checking for pre-innervation.')
hold on, plot([t1 t1], v([3 4]),'r'), plot([t2 t2], v([3 4]), 'r')
subplot(2,1,2)
plot(ts,squeeze(Yest(:,:, EMG_chn)), 'k');
hold on, plot([t1 t1], v([3 4]),'r'), plot([t2 t2], v([3 4]), 'r')
axis([t1-0.01 t2+0.01 v(3:4)])
xlabel('Time (s)')
ylabel('Amplitude (\muV)')
ginput(1);

% Prestimulus range threshold for pre-innervation
figure('units','normalized','outerposition',[0 0 1 1])
[~, it_pre]=min(abs(ts-(-10/1000)));
Pre_range_M=range(YestBL(1:it_pre,:, EMG_chn),1);

threshold=1000;
hold off
subplot(2,2,1)
hist(Pre_range_M, [0:2:max(Pre_range_M)])
xlabel('Prestimulus range (\muV)')
ylabel('Count')
title(['Range limit :' num2str(threshold)])
%plot(Pre_range,'k')
v1=axis;
hold on
h1=plot([threshold threshold], [0 v1(end)], 'r', 'linewidth', 2);
axis(v1)
subplot(2,2,2)
hold off
plot(Pre_range_M, 'b')
xlabel('Trial')
ylabel('Pre-stimulus range (\muV)')
hold on

h2=plot([0 R], [threshold threshold], 'r', 'linewidth', 2);
axis([0 R 0 150])
title({'Left-click to set the range limit.';'Right-click if ready.'})
[~, limtemp, b]=ginput(1);
while b==1
    
    threshold=limtemp;
    delete(h2)
    h2=plot([0 R], [threshold threshold], 'r', 'linewidth', 2);
    delete(h1)
    subplot(2,2,1)
    h1=plot([threshold threshold], [0 v1(end)], 'r', 'linewidth', 2);
    title(['Range limit :' num2str(threshold)])
    indsLim=find(Pre_range_M>threshold);
    subplot(2,1,2)
    plot(ts(1:it1),YestBL(1:it1,indsLim, EMG_chn)+repmat(0:length(indsLim)-1, it1,1)*30)
    axis([ts(1) ts(it1) -20 30*length(indsLim)+20])
    set(gca, 'ytick', [])
    xlabel('Time (s)')
    title([num2str(length(indsLim)) 'Trials exceeding the range limit'])
    
    [~, limtemp, b]=ginput(1);
end
disp(['Final threshold for channel ' num2str(EMG_chn) ' : ' num2str(threshold) 'muV'])
THchns(EMG_chn)=threshold;
end
close all