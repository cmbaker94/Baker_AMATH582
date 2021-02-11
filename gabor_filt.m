function [Sgt_spec,ks,tslide] = gabor_filt(S,Fs,dt,width,filtbound,pltfig)
% DESCRIPTION:
% This code will compute a spectrogram with a gabor window given a data
% timeseries and information about the gabor window. A boxcar filter is
% applied around the ranges of interest, where the spectrogram and
% wavenumbers are clipped around these regions to save memory.
% INPUT:
% S         = time series amplitude
% Fs        = frequency
% dt        = timestep of gabor transform
% width     = width of gabor window
% filtbound = low and high pass of boxcar filter
% pltfig    = indicator if plot should be created
% OUTPUT:
% Sgt       = spectogram
% ks        = frequencies
% tslide    = time gabor window centered on 

L   = length(S)/Fs; % record time in seconds
n   = length(S);
t2  = linspace(0,L,n+1); 
t   = t2(1:n); 
k   = (1/L)*[0:n/2-1 -n/2:-1]; 
ks  = fftshift(k);
tslide = 0:dt:L;

% filter region 
[val,id(1)] = min(abs(ks-filtbound(1)));
[val,id(2)] = min(abs(ks-filtbound(2)));
ks          = ks(id(1):id(2));

% prepare for transform
Sgt_spec=[];

if pltfig == 1
    figure
end

for j=1:length(tslide)
    g=exp(-width*(t-tslide(j)).^2); % Gabor 
    Sg=g.*S; 
    Sgt=fft(Sg);
    Sgtshift = abs(fftshift(Sgt));
    Sgt_spec=[Sgt_spec; Sgtshift(id(1):id(2))];
    if pltfig == 1
        subplot(3,1,1), plot(t,S,'k',t,g,'r')
        subplot(3,1,2), plot(t,Sg,'k')
        subplot(3,1,3), plot(ks,abs(fftshift(Sgt))/max(abs(Sgt)))
        drawnow
        pause(0.1)
    end
end