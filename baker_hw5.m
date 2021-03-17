clear all
close all
clc

addpath(genpath('/Users/cmbaker9/Documents/MTOOLS'))

%% STEP 0: Locate and load data

datapath    = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW5/data/';
figfolder   = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW5/figures/';

%% Load data

vid = 'mon';

if vid == 'ski'
    vname = 'ski_drop_low';
    trim = [234 726 44 533];
    rank = 1; % below 1% covariance (2nd is 0.1%)
elseif vid == 'mon'
    vname = 'monte_carlo_low';
    trim = [1 960 1 540];
    rank = 2; % below 1% covariance (3rd is just below 1%)
end

videofile = [datapath,vname,'.mp4'];
[frames, framerate] = prep_video(videofile,trim);

%% run svd on data

[resx, resy] = size(frames,1:2);
nim = size(frames,3);

f = double(reshape(frames,resx*resy,nim))';

[u,s,v]=svd(f','econ');

% covariance
lambda=diag(s).^2;

figure('units','inches','position',[1 1 10 6],'Color','w');
mode = 1:length(lambda);
scatter(mode,lambda/sum(lambda)*100,100,'k','fill')
% plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
hold on
% title('(a) Ski Drop Video','interpreter','latex','fontsize',20);
title('(b) Monte Carlo Video','interpreter','latex','fontsize',20,'Color',[0 0 0]);
xlim([0 20])
xlabel('Mode','interpreter','latex','fontsize',20)
ylabel('percent $\sigma^2 (\%)$','interpreter','latex','fontsize',20)
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
Sname1 = [figfolder,vid,'_covariance'];
print(Sname1,'-dpng')

[u_dmd] = calc_dmd(f,rank);

%% Seperate sections of image

Xlr = abs(reshape(u_dmd,resx,resy,nim));
Xsparse = double(frames)-abs(Xlr);
% Xsparse = abs(double(frames)-abs(Xlr));

R = Xsparse;
R(R<0) = 0;
Xsparse = Xsparse-R;
Xlr = abs(Xlr)+R;

%% Create Plot

figure('units','inches','position',[1 1 8 20],'Color','w');
% timeplot = 10;
for timeplot = 100:10:200    
    subplot(2,1,1)
    pcolor(Xlr(:,:,timeplot)); shading interp; colorbar
    hold on
    colormap('gray')
    caxis([0 256])
    set(gca, 'YDir','reverse')
    text(0,-25,'(a) Low-Rank Reconstruction','interpreter','latex','fontsize',20,'Color',[0 0 0]);
    xlabel('x (pixels)','interpreter','latex','fontsize',20)
    ylabel('y (pixels)','interpreter','latex','fontsize',20)
    grid on
    box on
    axis equal
    xlim([0 resy])
    ylim([0 resx])
    h1=gca;
    set(h1,'fontsize',20);
    set(h1,'tickdir','out','xminortick','on','yminortick','on');
    set(h1,'ticklength',1*get(h1,'ticklength'));
    
    subplot(2,1,2)
    
    pcolor(Xsparse(:,:,timeplot)); shading interp; colorbar;
    hold on
    colormap(flipud('gray'))
    caxis([0 150])
    set(gca, 'YDir','reverse')
    text(0,-25,'(b) Sparse Reconstruction','interpreter','latex','fontsize',20,'Color',[0 0 0]);
    xlabel('x (pixels)','interpreter','latex','fontsize',20)
    ylabel('y (pixels)','interpreter','latex','fontsize',20)
    grid on
    box on
    axis equal
    xlim([0 resy])
    ylim([0 resx])
    h1=gca;
    set(h1,'fontsize',20);
    set(h1,'tickdir','out','xminortick','on','yminortick','on');
    set(h1,'ticklength',1*get(h1,'ticklength'));
    drawnow
    Sname = [figfolder,'/',vname,'_',num2str(timeplot)];
    print(Sname,'-dpng')
end

figure('units','inches','position',[1 1 8 8],'Color','w');
for timeplot = 100:10:200
    pcolor(double(frames(:,:,timeplot))); shading interp; colorbar
    hold on
    colormap('gray')
    caxis([0 256])
    set(gca, 'YDir','reverse')
    text(0,-25,'(b) Monte Carlo Video','interpreter','latex','fontsize',20,'Color',[0 0 0]);
    xlabel('x (pixels)','interpreter','latex','fontsize',20)
    ylabel('y (pixels)','interpreter','latex','fontsize',20)
    grid on
    box on
    axis equal
    h1=gca;
    set(h1,'fontsize',20);
    set(h1,'tickdir','out','xminortick','on','yminortick','on');
    set(h1,'ticklength',1*get(h1,'ticklength'));
    xlim([0 resy])
    ylim([0 resx])
    Sname = [figfolder,'/',vname,'_orig_',num2str(timeplot)];
    print(Sname,'-dpng')
end
