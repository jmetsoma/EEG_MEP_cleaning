function [Xcleaned, A2, W2, S2, badComps]=bnp_detectBadICs_EEGlab(Xremoved,chanlocs, badCh,fs)

% computing fastICA for given 3D data. Showing components and allowing to
% choose the bad components in a graphical interface
% fastica toolbox required
%
% selection
%
% Input:
% Xremoved: 3D data channels X time points X chanlocs
% chalocs: struct EEG.chanlocs from EEGlab struct
% badCh: bad channels
% fs: sampling frequency
%
% output:
% 
% Xleaned: selected components removed
% A2: ICA mixing matrix
% W2: ICA demixing matrix
% S2: ICA waveforms
% badComps: components indices
%
% Xremoved ~= A2*S2
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
[Nc, Nt, Nr]=size(Xremoved);
dataIca=reshape(Xremoved,Nc,[]) ; 
[S2,A2, W2]=fastica(dataIca, 'approach', 'symm', 'g', 'tanh', 'interactivepca', 'on');

Ncomp=size(A2,2); 
S2=reshape(S2, [Ncomp, Nt, Nr]);
[~, isort]=sort(sum(A2.^2), 'descend');
A2=A2(:,isort);
S2=S2(isort,:,:);
W2=W2(isort,:);
figure('units','normalized','outerposition',[0 0 1 1])

i=1;
badComps=false(1,Ncomp);
f=5:35;
psd=computePSDforMultiEpochs(S2, Nt, 0, f, fs);

while i<=Ncomp
    
sa=subplot(2,2,2);

topoplot(A2(:,i), chanlocs(~ badCh), 'conv', 'off', 'style', 'map');
colorbar
title({['Topography of component: ' num2str(i)]; 'Press space to reject';...
    'Press right mouse button to go backwards'; 'Otherwise press left mouse button'})

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
Xcleaned=reshape(dataIca-A2(:,badComps)*W2(badComps,:)*dataIca, [Nc, Nt, Nr]);
