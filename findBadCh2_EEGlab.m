function badCh=findBadCh2_EEGlab(noise, chanlocs, X)

% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
sigma3=squeeze(mean(noise.^2,2));
noisePlot=reshape(permute(noise,[1 3 2]),size(noise,1)*size(noise,3),[]);
X=reshape(permute(X,[1 3 2]),size(noise,1)*size(noise,3),[]);
sigma31=sigma3(:);
[ss, iss]=sort(sigma31(:), 'ascend');
noisePlot=noisePlot(iss,:);
X=X(iss,:);
indEnd=round(length(ss)*.98);
ssRest=ss(1:indEnd);
scalingF=median(ssRest);
ths=10;
noisePlot=noisePlot/sqrt(scalingF);
X=X/sqrt(scalingF);
ssRest=ssRest/scalingF;

b=1;
figure('units','normalized','outerposition',[0 0 1 1])
while b==1
    badChPercent=mean(sigma3>ths*scalingF,2)*100;
    badChPercent(badChPercent>10)=10;
    badCh=badChPercent==10;
    ha=subplot(2,3,4);
   topoplot(badChPercent, chanlocs, 'conv', 'off', 'style', 'map');
   
   topoplot(zeros(length(badCh),1), chanlocs(badCh), 'electrodes', 'labels', 'style', 'blank','conv', 'off');
    colorbar
    colormap('parula')
    caxis([0 10])
    title({[num2str(sum(badCh)) ' channels rejected'], 'Bad channels in yellow'})
    indThs=sum(ssRest<=ths);
    
    subplot(1,3,3)
    hold off
    indsRel=[1:10 ];
    %indsRel=fliplr(round(logspace(0, log10(indThs/4), 10)))-1
    noiseLow=noisePlot(indThs-indsRel+1,:);
    XLow=X(indThs-indsRel+1,:);

    %indsRel=round(logspace(0, log10(length(ss)-indThs), 10))
    noiseHigh=noisePlot(indThs+indsRel,:);
    XHigh=X(indThs+indsRel,:);
    delta=median(range(XHigh,2));%250;
    plot(([noiseLow]+repmat((1:10)'*delta,1,size(noisePlot,2)))', 'b') 
    hold on
    plot(([noiseHigh]+repmat((11:20)'*delta,1,size(noisePlot,2)))', 'r') 
    plot([0 size(noisePlot,2)], [delta*10.5 delta*10.5], 'k--', 'linewidth', 1.5)
    axis([0 size(noisePlot,2) 0.5*delta delta*20.5])
    set(gca, 'ytick', [])
    title({'Estimated noise. Red: examples of rejected.', 'Blue: examples of accepted.'})
    
    subplot(1,3,2)
    hold off
    plot(([XLow]+repmat((1:10)'*delta,1,size(noisePlot,2)))', 'b') 
    hold on
    plot(([XHigh]+repmat((11:20)'*delta,1,size(noisePlot,2)))', 'r') 
    plot([0 size(noisePlot,2)], [delta*10.5 delta*10.5], 'k--', 'linewidth', 1.5)
    axis([0 size(noisePlot,2) 0.5*delta delta*20.5])
    set(gca, 'ytick', [])
    title({'Original signals. Red: examples of rejected.', 'Blue: examples of accepted.'})
    
    subplot(2,3,1)
    hold off
    hist(ssRest, 40) 
    xlabel('noise standard deviation (x median of stds)')
    v=axis;
    ylabel('count'), hold on, hl=plot([ths ths], [0 v(4)], 'r','linewidth', 2);
    %axis([0 40 v(3:4)]);
    title({['Threshold: ' num2str(ths) ' times the median noise variance'],...
        'Left-click to set the threshold. Right-click to finalize the selection.'})
    [ths, ~, b]=ginput(1);
    if b==1
        delete(hl)
        delete(ha.Children)
        
    end
    
end




 