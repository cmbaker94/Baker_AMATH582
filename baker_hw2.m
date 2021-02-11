clear all
close all
clc

addpath(genpath('/Users/cmbaker9/Documents/MTOOLS'))

%% STEP 0: Locate and load data

datapath    = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW2/';
figfolder   = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW2/figures/';
musicfiles  = {'GNR.m4a','Floyd.m4a'};
playsong    = 0; % 1 if play song, 0 if not play song

note.glet  = {'C_4','C_4^#----','D_4','D_4^#----','E_4','F_4','F_4^#----','G_4','G_4^#----',...
    'A_4','A_4^#----','B_4','C_5','C_5^#----','D_5','D_5^#','E_5','F_5','F_5^#','G_5','G_5^#'};
note.gHz = [261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.25, 698.46, 739.99, 783.99, 830.61]; 

note.blet  = {'C_2','C_2^#','D_2','D_2^#','E_2','F_2','F_2^#','G_2','G_2^#',...
    'A_2','A_2^#','B_2','C_3','C_3^#','D_3','D_3^#','E_3','F_3','F_3^#','G_3',...
    'G_3^#','A_3','A_3^#','B_3'};
note.bHz = [65.41, 69.3, 73.42, 77.78, 82.41, 87.31, 92.5, 98, 103.83, 110, 116.54, ...
    123.74, 130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185, 196, 207.65, 220, 233.08, 246.94];

%% STEP 1: Read and filter Guns N' Roses to find guitar notes

[y, Fs]     = audioread([datapath,musicfiles{1}]);
S           = y';
playsong    = 0;

if playsong == 1
    p8 = audioplayer(S,Fs); 
	playblocking(p8);
end

width   = 500;
dt      = 0.1;
pltfig  = 0;
filtbound = [250, 800];
[GNR.Sgt_spec,GNR.ks,GNR.tslide] = gabor_filt(S,Fs,dt,width,filtbound,pltfig);

% clean overtones
GNR.Sgt_thresh = GNR.Sgt_spec;
GNR.Sgt_thresh(GNR.Sgt_thresh < 7) = 0; % equivalent to 0.25

clear S y Fs

%% STEP 2: Read Pink Floyd 

[y, Fs]     = audioread([datapath,musicfiles{2}]);
S           = y(1:length(y)-1)';
playsong    = 0;

if playsong == 1
    p8 = audioplayer(S,Fs); 
	playblocking(p8);
end

%% STEP 2a: Filter Pink Floyd to find bass notes

width   = 100;
dt      = 0.5;
pltfig  = 0;
filtbound = [0, 250];

[PFb.Sgt_spec,PFb.ks,PFb.tslide] = gabor_filt(S,Fs,dt,width,filtbound,pltfig);

% clean overtones
PFb.Sgt_thresh = PFb.Sgt_spec/max(PFb.Sgt_spec,[],'all');
% Sgt_bassthresh(Sgt_bassthresh < 40) = 0;
PFb.Sgt_thresh(PFb.Sgt_thresh < 0.24) = 0;

%% STEP 2a: Filter Pink Floyd to find guitar notes

width   = 50;
dt      = 0.5;
pltfig  = 0;
filtbound = [250, 800];

[PFg.Sgt_spec,PFg.ks,PFg.tslide] = gabor_filt(S,Fs,dt,width,filtbound,pltfig);
clear S y Fs

PFg.Sgt_thresh = PFg.Sgt_spec/max(PFg.Sgt_spec,[],'all');
% Sgt_bassthresh(Sgt_bassthresh < 40) = 0;
PFg.Sgt_thresh(PFg.Sgt_thresh < 0.2) = 0;

%% STEP 3: Plot GNR

figure('units','inches','position',[1 1 10 16],'Color','w');
axes1 = axes('Position',[0.1 0.51 0.85 0.39]);
pcolor(GNR.tslide,GNR.ks,log(abs(GNR.Sgt_spec)+1).')
hold on
for i = 1:length(note.gHz)
    plot(GNR.tslide,repmat(note.gHz(i),[1, length(GNR.tslide)]),'k')
end
plot(GNR.tslide,repmat(250,[1, length(GNR.tslide)]),'k')
plot(GNR.tslide,repmat(775,[1, length(GNR.tslide)]),'k')
shading flat
colormap(flipud(cmocean('grey')))
% box on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
set(h1,'fontsize',12);
ylabel('Musical Note','interpreter','latex','fontsize',20);
set(h1,'ytick',note.gHz,'yticklabel',note.glet);
set(h1,'xtick',[0:2:14],'xticklabel',{''});
xlim([min(GNR.tslide) max(GNR.tslide)])
ylim([250 775])
text(0,805,'(a) Guitar Spectrogram','interpreter','latex','fontsize',20);

axes2 = axes('Position',[0.1 0.06 0.85 0.39]);
pcolor(GNR.tslide,GNR.ks,log(abs(GNR.Sgt_thresh)+1).')
hold on
shading flat
for i = 1:length(note.gHz)
    plot(GNR.tslide,repmat(note.gHz(i),[1, length(GNR.tslide)]),'k')
end
plot(GNR.tslide,repmat(250,[1, length(GNR.tslide)]),'k')
plot(GNR.tslide,repmat(775,[1, length(GNR.tslide)]),'k')
colormap(flipud(cmocean('grey')))
cb = colorbar('Position', [0.1 0.95 0.7 0.02],'Location','north');
% box on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
set(h1,'fontsize',12);
xlabel('time (sec)','interpreter','latex','fontsize',20);
ylabel('Musical Note','interpreter','latex','fontsize',20);
set(h1,'ytick',note.gHz,'yticklabel',note.glet);
set(h1,'xtick',[0:2:14],'xticklabel',{'0' '2' '4' '6' '8' '10' '12' '14'});
text(11.5,1458,'$\log(|s|+1)$','interpreter','latex','fontsize',20);
text(0,805,'(b) Cleaned Guitar Spectrogram','interpreter','latex','fontsize',20);
ylim([250 775])
Sname1 = [figfolder,'spectogram_GNR'];
print(Sname1,'-dpng')

%% STEP 4: Plot PF before filter

figure('units','inches','position',[1 1 10 16],'Color','w');
axes1 = axes('Position',[0.1 0.51 0.85 0.39]);
pcolor(PFg.tslide,PFg.ks,log(abs(PFg.Sgt_spec)+1).')
hold on
for i = 1:length(note.gHz)
    plot(PFg.tslide,repmat(note.gHz(i),[1, length(PFg.tslide)]),'k')
end
plot(PFg.tslide,repmat(250,[1, length(PFg.tslide)]),'k')
plot(PFg.tslide,repmat(775,[1, length(PFg.tslide)]),'k')
shading flat
colormap(flipud(cmocean('grey')))
% box on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
set(h1,'fontsize',14);
ylabel('Musical Note','interpreter','latex','fontsize',20);
set(h1,'ytick',note.gHz,'yticklabel',note.glet);
set(h1,'xtick',[0:10:60],'xticklabel',{''});
xlim([min(PFg.tslide) max(PFg.tslide)])
ylim([250 800])
text(50,880,'$\log(|s|+1)$','interpreter','latex','fontsize',20);
text(0,830,'(a) Guitar Spectrogram','interpreter','latex','fontsize',20);

axes2 = axes('Position',[0.1 0.06 0.85 0.39]);
pcolor(PFb.tslide,PFb.ks,log(abs(PFb.Sgt_spec)+1).')
hold on
shading flat
for i = 1:length(note.bHz)
    plot(PFb.tslide,repmat(note.bHz(i),[1, length(PFb.tslide)]),'k')
end
plot(PFb.tslide,repmat(250,[1, length(PFb.tslide)]),'k')
plot(PFb.tslide,repmat(775,[1, length(PFb.tslide)]),'k')
colormap(flipud(cmocean('grey')))
cb = colorbar('Position', [0.1 0.95 0.7 0.02],'Location','north');
% box on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
set(h1,'fontsize',14);
xlabel('time (sec)','interpreter','latex','fontsize',20);
ylabel('Musical Note','interpreter','latex','fontsize',20);
set(h1,'ytick',note.bHz,'yticklabel',note.blet);
set(h1,'xtick',[0:10:60],'xticklabel',{'0' '10' '20' '30' '40' '50' '60'});
text(0,144,'(b) Bass Spectrogram','interpreter','latex','fontsize',20);
ylim([65 140])
Sname1 = [figfolder,'spectogram_PF'];
print(Sname1,'-dpng')


%% STEP 5: Filtered

figure('units','inches','position',[1 1 10 16],'Color','w');
axes1 = axes('Position',[0.1 0.51 0.85 0.39]);
pcolor(PFg.tslide,PFg.ks,log(abs(PFg.Sgt_thresh)+1).')
hold on
for i = 1:length(note.gHz)
    plot(PFg.tslide,repmat(note.gHz(i),[1, length(PFg.tslide)]),'k')
end
plot(PFg.tslide,repmat(250,[1, length(PFg.tslide)]),'k')
plot(PFg.tslide,repmat(775,[1, length(PFg.tslide)]),'k')
shading flat
colormap(flipud(cmocean('grey')))
% box on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
set(h1,'fontsize',14);
ylabel('Musical Note','interpreter','latex','fontsize',20);
set(h1,'ytick',note.gHz,'yticklabel',note.glet);
set(h1,'xtick',[0:10:60],'xticklabel',{''});
xlim([min(PFg.tslide) max(PFg.tslide)])
ylim([250 800])
% text(50,850,'$\log(|s|+1)$','interpreter','latex','fontsize',20);
text(0,830,'(a) Cleaned Guitar Spectrogram','interpreter','latex','fontsize',20);
caxis([0 .2])

axes2 = axes('Position',[0.1 0.06 0.85 0.39]);
pcolor(PFb.tslide,PFb.ks,log(abs(PFb.Sgt_thresh)+1).')
hold on
shading flat
for i = 1:length(note.bHz)
    plot(PFb.tslide,repmat(note.bHz(i),[1, length(PFb.tslide)]),'k')
end
plot(PFb.tslide,repmat(250,[1, length(PFb.tslide)]),'k')
plot(PFb.tslide,repmat(775,[1, length(PFb.tslide)]),'k')
colormap(flipud(cmocean('grey')))
% cb = colorbar('Position', [0.1 0.95 0.7 0.02],'Location','north');
% box on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
set(h1,'fontsize',14);
xlabel('time (sec)','interpreter','latex','fontsize',20);
ylabel('Musical Note','interpreter','latex','fontsize',20);
set(h1,'ytick',note.bHz,'yticklabel',note.blet);
set(h1,'xtick',[0:10:60],'xticklabel',{'0' '10' '20' '30' '40' '50' '60'});
text(0,144,'(b) Cleaned Bass Spectrogram','interpreter','latex','fontsize',20);
ylim([65 140])
caxis([0 .2])
Sname1 = [figfolder,'spectogram_PF_cleaned'];
print(Sname1,'-dpng')

%% Example gabor transform spectra

[y, Fs]     = audioread([datapath,musicfiles{1}]);
S           = y';
playsong    = 0;

figure('units','inches','position',[1 1 10 14],'Color','w');
L       = length(S)/Fs; % record time in seconds
n       = length(S);
t2      = linspace(0,L,n+1); 
t       = t2(1:n); 
k       = (1/L)*[0:n/2-1 -n/2:-1]; 
ks      = fftshift(k);
tslide  = 0:dt:L;
width   = 10;
g       = exp(-width*(t-L/2).^2); 
Sg      = g.*S; 
Sgt     = fft(Sg);

subplot(3,1,1)
plot(t,S,'k')
hold on 
plot(t,g,'k','Linewidth',[2]) 
set(gca,'Fontsize',14)
ylabel('$S(t), g(t)$','interpreter','latex','fontsize',20)
xlabel('time (t)','interpreter','latex','fontsize',20)
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
text(0.2,0.9,'(a) Timeseries, Gabor Window','interpreter','latex','fontsize',18);

subplot(3,1,2)
plot(t,Sg,'k') 
set(gca,'Fontsize',14) 
ylabel('$S(t)g(t)$','interpreter','latex','fontsize',20)
xlabel('time (t)','interpreter','latex','fontsize',20)
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
text(0.2,0.032,'(b) Filtered Data','interpreter','latex','fontsize',18);

subplot(3,1,3)
plot(ks,abs(fftshift(Sgt))/max(abs(Sgt)),'k') 
% axis([-50 50 0 1])
set(gca,'Fontsize',14)
ylabel('FFT($Sg$)','interpreter','latex','fontsize',20)
xlabel('frequency ($\omega$)','interpreter','latex','fontsize',20)
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','off');
set(h1,'ticklength',1.2*get(h1,'ticklength'));
text(-2.4*10^4,0.9,'(c) Spectra of Gabor Window','interpreter','latex','fontsize',18);

Sname1 = [figfolder,'gabor_ex'];
print(Sname1,'-dpng')
