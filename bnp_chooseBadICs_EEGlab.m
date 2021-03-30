function [Xcleaned,S2, badComps]=bnp_chooseBadICs_EEGlab(Xremoved,chanlocs, badCh,fs, A2, W2, badComps)

% Showing components and allowing to rechoose the components
%
% 
%
% Input:
% Xremoved: 3D data channels X time points X chanlocs
% chalocs: struct EEG.chanlocs from EEGlab struct
% badCh: bad channels
% fs: sampling frequency
% A2: mixing matrix
% W2 demixing matrix
% badComps: predefined indices of bad components
%
% output:
% 
% Xleaned: selected components removed
% S2: ICA waveforms
% badComps: components indices
% 
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
[Nc, Nt, Nr]=size(Xremoved);

S2= W2*reshape(Xremoved, Nc, []);
Ncomp=size(A2,2); 
S2=reshape(S2, [Ncomp, Nt, Nr]);

figure('units','normalized','outerposition',[0 0 1 1])

i=1;
badComps0=false(1,Ncomp);
badComps0(badComps)=true;
badComps=badComps0;
f=5:35;
psd=computePSDforMultiEpochs(S2, Nt, 0, f, fs);

while i<=Ncomp
    
sa=subplot(2,2,2);

topoplot(A2(:,i), chanlocs(~ badCh), 'conv', 'off', 'style', 'map');
colorbar
if badComps0(i)
title({['Topography of component: ' num2str(i)]; ['Originally removed' ]; 'Press space to reject';...
    'Press right mouse button to go backwards'; 'Otherwise press left mouse button'})
else
    title({['Topography of component: ' num2str(i)]; ['Originally kept' ]; 'Press space to reject';...
    'Press right mouse button to go backwards'; 'Otherwise press left mouse button'})
end
subplot(2,2,4)
imagesc(squeeze(S2(i,:,:))'), colorbar
title('Waveforms over all trials')
xlabel('Time sample')
ylabel('Trial index')
subplot(2,2,3)
hold off
plot((squeeze(S2(i,:,:))))
title('Waveforms over all trials')
xlabel('Time sample')
ylabel('Amplitude (AU)')

subplot(2,2,1)
plot(f,psd(i,:), 'linewidth', 2)
title('Power spectrum averaged over epochs')
xlabel('Frequency (Hz)')
ylabel('Power (AU)')

[~, ~, bb]=ginput(1);
if bb==32
    badComps(i)=true;
    i=i+1;
elseif bb==3
    i=i-1;
else
    badComps(i)=false;
    i=i+1;
end
delete(sa.Children)
end
badComps=find(badComps);
Xcleaned=Xremoved-reshape(A2(:,badComps)*W2(badComps,:)*reshape(Xremoved, Nc, []),...
    [Nc, Nt, Nr]);
