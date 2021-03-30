function badTr=findBadTr2(noise, x, rmch)
% .........................................................................
% 29 March 2021 : Johanna Metsomaa, BNP, University of Tübingen  
% .........................................................................
noiseRem=noise(setdiff(1:size(noise,1),find(rmch)),:,:);
xRem=x(setdiff(1:size(noise,1),find(rmch)),:,:);
[sTr2, iMax]=max(squeeze(range(noiseRem,2)),[],1);
scalingF=median(sTr2);
th=2;
sTr2=sTr2/scalingF;
b=1;
[sTr2sort, isort]=sort(sTr2, 'ascend');
iMax=iMax(isort);
noiseRem=noiseRem(:,:,isort);
xRem=xRem(:,:,isort);
figure('units','normalized','outerposition',[0 0 1 1])
while b==1
    
    
    indTh=sum(sTr2sort<th);
    indsRel=[1:10];
    rangeLow=zeros(10, size(noise,2));
    xLow=zeros(10, size(noise,2));
    for indR=1:10
        try
            rangeLow(10-indR+1,:)=noiseRem(iMax(indTh-indsRel(indR)+1),:, indTh-indsRel(indR)+1);
            xLow(10-indR+1,:)=xRem(iMax(indTh-indsRel(indR)+1),:, indTh-indsRel(indR)+1);
        catch
        end
    end
    
    rangeHigh=zeros(10, size(noise,2));
    xHigh=zeros(10, size(noise,2));
    for indR=1:10 
        try
            rangeHigh(indR,:)=noiseRem(iMax(indTh+indsRel(indR)),:, indTh+indsRel(indR));
            xHigh(indR,:)=xRem(iMax(indTh+indsRel(indR)),:, indTh+indsRel(indR));
        catch
        end
    end
    
    
    subplot(1,3,3)
    hold off
    delta=max(median(range(xHigh,2)), median(range(xLow,2)));%250;
    plot((rangeLow+repmat(delta*(1:10)', 1, size(noise,2)))', 'b')
    hold on
    plot((rangeHigh+repmat(delta*(11:20)', 1, size(noise,2)))', 'r')
    axis([0 size(noise,2) .5*delta 20.5*delta])
    title({'Noise estimates. Red: examples of rejected.', 'Blue: examples of accepted.'})
    set(gca, 'ytick', [])
    
   subplot(1,3,2)
    hold off
    plot((xLow+repmat(delta*(1:10)', 1, size(noise,2)))', 'b')
    hold on
    plot((xHigh+repmat(delta*(11:20)', 1, size(noise,2)))', 'r')
    axis([0 size(noise,2) .5*delta 20.5*delta])
    title({'Original signals. Red: examples of rejected.', 'Blue: examples of accepted.'})
    set(gca, 'ytick', [])
    
    subplot(1,3,1)
    hold off
    bar([sTr2]), hold on, hb=plot([0 length(sTr2)],...
        [ th th]); 
    xlabel('Trial'), ylabel('Maximum noise range (relative to median)')
    badTr=sTr2>th;
    title({[num2str(sum(badTr)) ' trials rejected'], 'Left-click to adjust the threshold. Right-click to finalize the selection.'})
    set(gca, 'ytick', sort([1 th 5:5:max(sTr2)], 'ascend'))
    [~, th, b]=ginput(1);
    if b==1
        delete(hb)
    end
end

