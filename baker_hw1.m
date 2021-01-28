clear all
close all
clc

addpath(genpath('/Users/cmbaker9/Documents/MTOOLS'))

%% STEP 0: Locate and load data

datapath = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW1/subdata/';
load([datapath,'subdata.mat']) % Imports the data as the 262144x49 (space by time) matrix called subdata 5

figfolder ='/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW1/figures/';

%% STEP 1: Define spatial and fft domain

L = 10; % spatial domain
n = 64; % Fourier modes
N = 3; % number of dimensions
x2 = linspace(-L,L,n+1); x = x2(1:n); y =x; z = x;
k = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);

[X,Y,Z]=meshgrid(x,y,z); % create meshgird of cartesian coordinates
[Kx,Ky,Kz]=meshgrid(ks,ks,ks); % create meshgrid of wavenumber space
ave = zeros(64,64,64); % create matrix of zeros

%% STEP 2: Loop through data to identify peak frequencies

for j=1:length(subdata(1,:))
    Un              = reshape(subdata(:,j),n,n,n); % reshape data at each time step
    S               = fftn(Un); % compute fft
    S4d(:,:,:,j)    = S; % storing spectrum
    Un4d(:,:,:,j)   = Un; % storing reshaped data
    ave             = ave+S; % summing spectra
end

%% STEP 3: Find peak frequencies

Savg    = abs(fftshift(ave))/size(S4d,4); % compute time-averaged spectra
Ms      = max(Savg,[],'all'); % find max variance

[val,id] = max(Savg(:)); % find max of spectra index in array
[Sr,Sc,Sp] = ind2sub(size(Savg),id); % find index of max in matrix
maxfreq = [Kx(Sr,Sc,Sp), Ky(Sr,Sc,Sp), Kz(Sr,Sc,Sp)]; % pick max frequencies

% generate isosurface figure of maximum frequency valeus
figure('units','inches','position',[1 1 10 6],'Color','w');
isosurface(Kx,Ky,Kz,Savg/Ms,.5)
hold on
quiver3(maxfreq(1),maxfreq(2),maxfreq(3)+3,0,0,-2,'AutoScale','off','LineWidth',2,'MaxHeadSize',6,'Color','k')
axis([-10 10 -10 10 -10 10])
grid on
text(maxfreq(1),maxfreq(2)+2,maxfreq(3)+6,'max freq:','interpreter','latex','fontsize',20);
text(maxfreq(1),maxfreq(2)+2,maxfreq(3)+3.5,['(',num2str(round(maxfreq(1),2)),', ',num2str(round(maxfreq(2),2)),', ',num2str(round(maxfreq(3),2)),')'],'interpreter','latex','fontsize',20);
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','on','zminortick','on');
set(h1,'ticklength',2*get(h1,'ticklength'));
set(h1,'fontsize',26);
xlabel('$K_x$ (2$\pi$ /L)','interpreter','latex','fontsize',26);
ylabel('$K_y$ (2$\pi$ /L)','interpreter','latex','fontsize',26);
zlabel('$K_z$ (2$\pi$ /L)','interpreter','latex','fontsize',26);
title('Normalized Time-Averaged 3D Spectra, Values $>$ 0.5','interpreter','latex','fontsize',20);
Sname1 = [figfolder,'Savg_isosurface'];
print(Sname1,'-dpng')

%% STEP 4: Generate filter at peak frequencies

alpha = 0.2; % width of filter
filter = exp(-alpha*((Kx-maxfreq(1)).^2+(Ky-maxfreq(2)).^2+(Kz-maxfreq(3)).^2)); % generate Gaussian filter

% %% STEP 4.5: Test Filter
% Savgtest= Savg.*filter;
% test2d = nanmean(Savg,3);
% test2dfilt = nanmean(Savgtest,3);
% figure
% pcolor(Kx(:,:,1),Ky(:,:,1),test2d); shading interp; colorbar
% figure
% pcolor(Kx(:,:,1),Ky(:,:,1),test2dfilt); shading interp; colorbar

%% STEP 5: Apply filter and inverse fft data

for j=1:length(subdata(1,:))
    Un=reshape(subdata(:,j),n,n,n); % reshape data
    Sfilt = fftshift(fftn(Un)).*filter; % compute fft and multiply by filter
    iUn = ifftn(fftshift(Sfilt)); % comptue inverse fft
    iUn4d(:,:,:,j)=iUn; % store in 4D matrix
    [mfilt, id] = max(abs(iUn(:))); % find maximum value in array
    [pathx, pathy, pathz] = ind2sub(size(iUn), id); % find index of max value in matrix
    subxyz(:,j) = [X(pathx, pathy, pathz), Y(pathx, pathy, pathz), Z(pathx, pathy, pathz)]; % store path
end

%% STEP 6: Compare unfiltered and filtered data

% compare with raw data
uplot_orig = nanmean(abs(Un4d),4); % comptue average value, original
M_orig = max(uplot_orig,[],'all'); % store maximum
% filtered data
uplot_filt = nanmean(abs(iUn4d),4); % compute average value, filtered
M_filt = max(uplot_filt,[],'all'); % store maximum

% create figure of unfiltered data
figure('units','inches','position',[1 1 10 6],'Color','w');
isosurface(X,Y,Z,uplot_orig/M_orig,0.75)
axis([-10 10 -10 10 -10 10])
grid on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','on','zminortick','on');
set(h1,'ticklength',2*get(h1,'ticklength'));
set(h1,'fontsize',26);
xlabel('x (L)','interpreter','latex','fontsize',26);
ylabel('y (L)','interpreter','latex','fontsize',26);
zlabel('z (L)','interpreter','latex','fontsize',26);
title('Normalized Original Data, Values $>$ 0.75','interpreter','latex','fontsize',20);
Sname1 = [figfolder,'Un_orig'];
print(Sname1,'-dpng')

% create figure of filtered data
figure('units','inches','position',[1 1 10 6],'Color','w');
isosurface(X,Y,Z,uplot_filt/M_filt,0.75)
axis([-10 10 -10 10 -10 10])
grid on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','on','zminortick','on');
set(h1,'ticklength',2*get(h1,'ticklength'));
set(h1,'fontsize',26);
xlabel('x (L)','interpreter','latex','fontsize',26);
ylabel('y (L)','interpreter','latex','fontsize',26);
zlabel('z (L)','interpreter','latex','fontsize',26);
title('Normalized Filtered Data, Values $>$ 0.75','interpreter','latex','fontsize',20);
Sname1 = [figfolder,'Un_filtered'];
print(Sname1,'-dpng')

%% STEP 7: Generate figure showing x,y,z location

timevec = 0:0.5:24; % time array

% figure of the submarine path
figure('units','inches','position',[1 1 10 6],'Color','w');
axes1 = axes('Position',[0.13 0.14 0.68 0.78]);
scatter3(subxyz(1,:),subxyz(2,:),subxyz(3,:),100,timevec,'fill','MarkerEdgeColor','k')
colormap(cmocean('dense'));
cb = colorbar('Position', [0.9 0.1 0.02 0.7],'Location','east');
text(14.6, -7.3, 14.6,'time (hrs)','interpreter','latex','fontsize',20);
axis([-10 10 -10 10 -10 10])
grid on
h1=gca;
set(h1,'tickdir','out','xminortick','on','yminortick','on','zminortick','on');
set(h1,'ticklength',2*get(h1,'ticklength'));
set(h1,'fontsize',26);
xlabel('x (L)','interpreter','latex','fontsize',26);
ylabel('y (L)','interpreter','latex','fontsize',26);
zlabel('z (L)','interpreter','latex','fontsize',26);
title('Submarine Trajectory','interpreter','latex','fontsize',20);
Sname1 = [figfolder,'xyz_trajectory'];
print(Sname1,'-dpng')


