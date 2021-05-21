function [yestim, ytrend]=fitExpDecay(y,ts, ts2)
% input:
%
% y: the signal where the exp decay is fitted
% ts: the time axis of the fit i.e. vector of indices to be used for
% fitting (out of y). This should exclude the indices of MEP
% ts2: the time axis where the exponential decay is defined, i.e., the 
% all the indices where the decay is present. This should
% include the MEP indices!
%
% output:
%
% yestim: the signal from which the exp decay is removed
% ytrend: the exp decay trendline
%
refInd=0;
%t0=t0-refInd; t1=t1-refInd; t2=t2-refInd; t3=t3-refInd;
y2=double(y);
inds2=[ts-refInd];% t2:t3];

expF=@(param) sum((y2(inds2)-((param(1)-param(4))*exp(-(inds2-param(3))*param(2))+param(4))).^2);

param=[y2(inds2(1)) .1 inds2(1) y2(inds2(end))];
[~ , itemp]=min(abs((y2(inds2)-param(4))-(param(1)-param(4))/exp(1)));
param(2)=1/(inds2(itemp)-param(3));


[pEst]=fminsearch(expF, param);%[-150 .1 1020 -20])

ytrend=(pEst(1)-pEst(4))*exp(-((ts2-refInd)-pEst(3))*pEst(2))+pEst(4);
yestim=y(ts2)-ytrend;
