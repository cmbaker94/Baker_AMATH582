% Set up paths and clear workspace
clear all
close all
clc

%%%%%%%%%%%%%%%%% USER MANIPULATED SECTION BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%

% WC comparison
xshore = 30;
sprd = [0 20 40];

%%%%%%%%%%%%%%%%% USER MANIPULATED SECTION ABOVE %%%%%%%%%%%%%%%%%%%%%%%%%%

%% STEP 1: Create paths and load files 

% general path and names
datapath    = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/project/';

subname = '_';
for i = 1:length(sprd)
    eval(['spec',num2str(sprd(i)),'.image    = load([datapath,num2str(sprd(i)),''deg/image_transect_wavecrest_length_x'',num2str(xshore),subname,''.mat'']);'])
    eval(['spec',num2str(sprd(i)),'.stereo    = load([datapath,num2str(sprd(i)),''deg/dem_transect_wavecrest_length_x'',num2str(xshore),subname,''.mat'']);'])
end

figfolder   = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/project/';

%% Plot figure

figure('units','inches','position',[1 1 16 5],'Color','w');
ax1 = axes('Position',[0.075 0.15 0.275 0.75])
plot(spec40.stereo.k(20,:),spec40.stereo.Savg,'k','LineWidth',2,'LineStyle','-')
hold on
plot(spec20.stereo.k(20,:),spec20.stereo.Savg,'k','LineWidth',2,'LineStyle','--')
plot(spec0.stereo.k(20,:),spec0.stereo.Savg,'k','LineWidth',2,'LineStyle',':')
text(10^-1.57,10^-1.88,'(a) Stereo Reconstructions','interpreter','latex','fontsize',20);
box on
h1=gca;
set(h1, 'YScale', 'log')
set(h1, 'XScale', 'log')
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',2*get(h1,'ticklength'));
set(h1,'ytick',[10^(-4) 10^(-3) 10^(-2) 10^(-1)],'yticklabel',{'10^{-4}' '10^{-3}' '10^{-2}' '10^{-1}'});
set(h1,'xtick',[10^(-2) 10^(-1) 10^(0) 10^(1)],'xticklabel',{'10^{-2}' '10^{-1}' '10^{0}' '10^{1}'});
set(h1,'fontsize',15);
xlabel('$L^{-1}$ (m$^{-1}$)','interpreter','latex','fontsize',20);
ylabel('$S_{\eta\eta}$ (m$^3$)','interpreter','latex','fontsize',20);
ylim([10^-4.1 10^-2])
xlim([nanmin(spec40.stereo.k(20,2)) 1])
h2 = legend('$\sigma_{\theta} = 40^{\circ}$','$\sigma_{\theta} = 20^{\circ}$','$\sigma_{\theta} = 0^{\circ}$')
set(h2,'interpreter','latex','fontsize',18,'orientation','vertical','Location','northeast');


ax2 = axes('Position',[0.440 0.15 0.275 0.75])
plot(spec40.image.k(20,:),spec40.image.Savg,'k','LineWidth',2,'LineStyle','-')
hold on
plot(spec20.image.k(20,:),spec20.image.Savg,'k','LineWidth',2,'LineStyle','--')
plot(spec0.image.k(20,:),spec0.image.Savg,'k','LineWidth',2,'LineStyle',':')
box on
h1=gca;
set(h1, 'YScale', 'log')
set(h1, 'XScale', 'log')
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',2*get(h1,'ticklength'));
set(h1,'ytick',[10^(-4) 10^(-3) 10^(-2) 10^(-1) 10^(0)],'yticklabel',{'10^{-4}' '10^{-3}' '10^{-2}' '10^{-1}' '10^{0}'});
set(h1,'xtick',[10^(-2) 10^(-1) 10^(0) 10^(1)],'xticklabel',{'10^{-2}' '10^{-1}' '10^{0}' '10^{1}'});
set(h1,'fontsize',15);
ylabel('$S_{\mathrm{image}}$ (m)','interpreter','latex','fontsize',20);
xlabel('$L^{-1}$ (m$^{-1}$)','interpreter','latex','fontsize',20);
text(10^-1.57,10^-0.3,'(b) Images','interpreter','latex','fontsize',20);
ylim([10^-2 10^-0.4])
xlim([nanmin(spec40.image.k(20,2)) 1])

extra = '';
Sname1 = [figfolder,'comparison_sprd0and40_x',num2str(xshore(1)),'-',num2str(xshore(end)),'m',extra];
print(Sname1,'-dpng')
