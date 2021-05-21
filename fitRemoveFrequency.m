function [yestim, trendline, cs]=fitRemoveFrequency(y, inds3, f, fs)


iMod=inds3*50/fs*2*pi;
U=[sin(iMod)'/norm(sin(iMod)) cos(iMod)'/norm(cos(iMod))];
indsFull=1:length(y);
iMod2=indsFull*f/fs*2*pi;
Ufull=[sin(iMod2)'/norm(sin(iMod)) cos(iMod2)'/norm(cos(iMod))];
cs=U'*y(inds3)';
trendline=(Ufull*cs)';
yestim=y-trendline;
