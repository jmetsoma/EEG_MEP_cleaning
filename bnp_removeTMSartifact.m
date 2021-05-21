function [AmpsM, RMSE]=bnp_removeTMSartifact(Yest, ts, badTr, t2)
%
% Robust fitting of exponential decay signal to the TMS artifact.
% User defines the excluded time window for 10 consecutive trials
% simultaneously.
% The fitting is performed for one channel at a time.
%
% Input:
% Yest: (times x channels x trials) detrended EMG data
% ts: (1 x times) time axis (ms)
% badTr: (trials x 1) boolean-valued vector defining bad trials (true)
% t2: end time of the time window including evoked activitx
%
% Output:
% AmpsM: Amplitudes of the MEPs
% RMSE: root-mean-square error of the exponential fit
%
% .........................................................................
% 18 May 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................

goodTrials=~badTr;
AmpsM=zeros(length(find(goodTrials)),size(Yest,3));
RMSE=zeros(length(find(goodTrials)),size(Yest,3));
for EMG_chn=1:size(Yest,3)
close all
figure('units','normalized','outerposition',[0 0 1 1])




gc=[0 0 0]+0.5;
plot(ts,Yest(:,:,EMG_chn), 'k');
v=axis;

t=[5 15 35 40]*1000;
hold on, h(1)=plot([t(1) t(1)], v([3 4]),'r', 'linewidth', 2); h(2)=plot([t(2) t(2)], v([3 4]), 'r', 'linewidth', 2);
h(3)=plot([t(3) t(3)], v([3 4]),'r', 'linewidth', 2); h(4)=plot([t(4) t(4)], v([3 4]), 'r', 'linewidth', 2);
xlabel('Time'), ylabel('Amplitude (\muV)')


boundNames={'B1 ', 'B2', 'B3', 'B4'};
InstructionNames={'1. boundary (B1)','2. boundary (B2)','3. boundary (B3)','4. boundary (B4)'};

set(gca,'xtick',t, 'xticklabel', boundNames)
axDef=[0 t2 v(3:end)];
axis(axDef);


for i=1:length(t)
    set(h(i), 'linewidth', 2, 'color', 'c')
title({['Left-click to set ' InstructionNames{i} '.']; 'Rigth-click when ready.'})
[t_temp,~,bm]=ginput(1);

while bm==1
    delete(h(i))
    h(i)=plot([t_temp t_temp], v([3 4]), 'c', 'linewidth', 2);
    [~, it_temp]=min(abs(ts-t_temp));
    [t_temp,~,bm]=ginput(1);  
end
t(i)=ts(it_temp);
It(i)=it_temp;
set(gca,'xtick',t, 'xticklabel', boundNames)
if i==2 || i==4
    
    T=[t(i-1) t(i) t(i) t(i-1)];
    P=[v(3) v(3) v(4) v(4)];
    fill(T, P, 'c','facealpha', 0.3, 'edgealpha', 0)
    delete(h(i)), delete(h(i-1))
    
end
end
pause(0.1)
 
[~, it0]=min(abs(ts-(0)));

figure('units','normalized','outerposition',[0 0 1 1])

pause(2)
goodTrialsInds=find(goodTrials);
iNext=0;
im=1;

imMax=10;

    
    
    doFit =1;
    
    while iNext<length(goodTrialsInds)
        iNext=iNext+1;
        i=goodTrialsInds(iNext);
        
        figure(2)
        [yestim, ytrend]=fitExpDecay(Yest(:,i, EMG_chn)',[It(1):It(2) It(3):It(4)], It(1):It(4));
        
        YtrendF(It(1):It(4),i, EMG_chn)=ytrend;
        YestF(It(1):It(4),i, EMG_chn)=yestim;
        RMSE(iNext, EMG_chn)=...
            sqrt(mean((YtrendF([It(1):It(2) It(3):It(4)],i, EMG_chn)-Yest([It(1):It(2) It(3):It(4)],i, EMG_chn)).^2));
        
        
        
        AmpsM(iNext, EMG_chn)=range(YestF( It(2):It(3),i, EMG_chn)); 
        
        if im==1
            wd=max(range(Yest([It(1):It(4)],goodTrialsInds(iNext:min(iNext+imMax-1, length(goodTrialsInds))), EMG_chn)))/2;
        for ij=[2 4]
        T=[t(ij-1) t(ij) t(ij) t(ij-1)];
        P=[-1000 -1000 wd*imMax+1000 wd*imMax+1000];%P=[v(3) v(3) v(4) v(4)]+(im-1)*wd;
        fill(T, P, 'c','facealpha', 0.5, 'handlevisibility', 'off', 'edgealpha', 0)
        hold on
        end
        end
        plot(ts,Yest(:,i, EMG_chn)+(im-1)*wd, 'color', gc, 'linewidth', 1.5) 
        
        plot(ts(It(1):It(4)), ytrend+(im-1)*wd, '--b', 'linewidth', 1.5);
        plot(ts(It(1):It(4)),yestim+(im-1)*wd,'m', 'linewidth', 1.5)
        
        plot(axDef(1:2), [0 0]+(im-1)*wd, 'k')
        
        
        
        if im==imMax | iNext==length(goodTrialsInds)
            
            xlabel('Time (s)'), ylabel('Amplitude')
            
            axis([axDef(1:2) min(Yest([It(1):It(2) It(3):It(4)],goodTrialsInds(iNext-imMax+1), EMG_chn))-100 ...
                max(Yest([It(1):It(2) It(3):It(4)],i, EMG_chn))+100+(im-1)*wd])
            set(gca, 'ytick', [])          
            title({['Trials ' num2str(iNext-imMax+1) ' - ' num2str(iNext)]; ...
                [' max RMSE: ' num2str(max(RMSE((iNext-imMax+1):iNext, EMG_chn)))]; ...
                'Left-click to adjust a boundary.'; 'Right-click when ready.'})
            legend('Before fitting', 'Exponential fit', 'After eliminating the fit')
            [t_temp,~ ,bm]=ginput(1);
            doFit=bm==1;
            im=1;
            hold off
            if doFit
                [~, imin]=min(abs(t_temp-t));
                [~, it_temp]=min(abs(ts-t_temp));
                t(imin)=ts(it_temp);
                It(imin)=it_temp;
                iNext=iNext-imMax;
                           
            end
        else
            
            im=im+1;
            
        end
        
    end

end
disp('All done')
close all