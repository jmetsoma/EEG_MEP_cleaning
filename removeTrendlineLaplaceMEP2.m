function [yestim, ytrend]=removeTrendlineLaplaceMEP2(y, t1, t2, exclude, lambda)



ymod=[y fliplr(y)];

deltat=t2-t1+2;
nt1=mod(t1-1-1,deltat)+1;
nt2=length(ymod)-mod(length(ymod)-(t2+1),deltat);
if exclude


temp=interpft(ymod(nt1:deltat:end),(deltat)*(length(ymod(nt1:deltat:end))));

ymod(t1:t2)=temp(-(nt1-1)+(t1:t2));

end
ymod=ymod(:,1:size(ymod,2)/2);
[~, ytrend]=removeTrendlineLaplacePenalty2(lambda,double(ymod),1:length(y),[], 0);

yestim=y-ytrend;

function [Xtr3d, xtrend]=removeTrendlineLaplacePenalty2(lambda,Xtr3, timeAxis,baselineRange, plotting)

[~,Nt, Nr]=size(Xtr3);
I = speye(Nt);
D2 = spdiags(ones(Nt-2,1)*[1 -2 1],[0:2],Nt-2,Nt);


for i=1:Nr
trend = ((I+lambda^2*D2'*D2)\squeeze(Xtr3(:,:,i))')';
Xtr3d(:,:,i)=Xtr3(:,:,i)-trend;
xtrend(:,:,i)=trend;
end
if baselineRange
Xtr3d=baselineData(Xtr3d,timeAxis, baselineRange(1), baselineRange(2));
end
if plotting
try
for j=1:size(Xtr3d,3)
    for k=1:size(Xtr3d,1)
        hold off
        plot(timeAxis,Xtr3(k,:,j))
        hold on
        plot(timeAxis, xtrend(k,:,j), 'linewidth', 2)
        ginput(1);
    end
end


    catch
end
end

end
end