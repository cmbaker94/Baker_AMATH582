clear all
close all
clc

addpath(genpath('/Users/cmbaker9/Documents/MTOOLS'))

%% STEP 0: Locate and load data

datapath    = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW3/data/';
figfolder   = '/Users/cmbaker9/Documents/UW_Classes/AMATH_Data_Analysis/HW3/figures/';

%% Test 1: Ideal Case

numcam = 3;
matchcam = 1;
% load data
load([datapath,'cam1_1.mat']);
load([datapath,'cam2_1.mat']);
load([datapath,'cam3_1.mat']);

A = [];
pltfig = 0; % 1 if plot theshold figure

thresh = [0.9 0.94 0.84]; % threshold value for each camera
ROI = [100 420 250 450;...
    50 435 200 390;...
    200 350 200 500]; % region of interest for each camera [ymin ymax xmin xmax]

if matchcam == 1
    vidFrames2_1 = squeeze(vidFrames2_1(:,:,:,19:end));
    vidFrames3_1 = squeeze(vidFrames3_1(:,:,:,10:end));
    trim = size(vidFrames3_1,4); % minimum number of frames to trim to
else
    trim = size(vidFrames1_1,4); % minimum number of frames to trim to
end


for i = 1:numcam
    eval(['cam = vidFrames',num2str(i),'_1;']) % camera of interest
    ffcam = [figfolder,'T1C',num2str(i)];
    [x,y] = get_xy_thresh(cam,thresh(i),ROI(i,:),trim,pltfig,ffcam); % extract xy
    A = [A; x; y];
end

[Y1,svd1] = calc_pcp(A); % compute prinicipal component projection with svd

if matchcam == 1
    figure('Color','w')
    plot(Y1(1,:),'Color','k','LineWidth',2)
    hold on
    plot(Y1(2,:),'Color','r','LineWidth',2)
    plot(Y1(3,:),'Color','b','LineWidth',2)
    ylabel('Pixels','interpreter','latex','fontsize',20)
    xlabel('Image No.','interpreter','latex','fontsize',20)
    grid on
    box on
    h1=gca;
    set(h1,'fontsize',20);
    set(h1,'tickdir','out','xminortick','on','yminortick','on');
    set(h1,'ticklength',1*get(h1,'ticklength'));
    
    Sname = [figfolder,'match_cam_T1'];
    print(Sname,'-dpng')
end

clear vidFrames* cam ROI tresh A

%% Test 2: Noisy Case
% see comments in test 1

numcam = 3;
load([datapath,'cam1_2.mat']);
load([datapath,'cam2_2.mat']);
load([datapath,'cam3_2.mat']);

A = [];
pltfig = 0;

thresh = [0.92 0.94 0.9];
ROI = [150 400 250 450;...
    50 435 200 420;...
    200 350 200 500];
trim = size(vidFrames1_2,4);

for i = 1:numcam
    eval(['cam = vidFrames',num2str(i),'_2;'])
    ffcam = [figfolder,'T2C',num2str(i)];
    [x,y] = get_xy_thresh(cam,thresh(i),ROI(i,:),trim,pltfig,ffcam);
    A = [A; x; y];
end

[Y2,svd2] = calc_pcp(A);

clear vidFrames* cam ROI tresh A

%% Test 3: Horizontal Displacement
% see comments in test 1

numcam = 3;
load([datapath,'cam1_3.mat']);
load([datapath,'cam2_3.mat']);
load([datapath,'cam3_3.mat']);

A = [];
pltfig =0;

thresh = [0.92 0.94 0.9];
ROI = [150 400 250 450;...
    175 445 100 500;...
    200 350 200 500];
trim = size(vidFrames3_3,4);

for i = 1:numcam
    eval(['cam = vidFrames',num2str(i),'_3;'])
    ffcam = [figfolder,'T3C',num2str(i)];
    [x,y] = get_xy_thresh(cam,thresh(i),ROI(i,:),trim,pltfig,ffcam);
    A = [A; x; y];
end

[Y3,svd3] = calc_pcp(A);

clear vidFrames* cam ROI tresh A

%% Test 4: Horizontal Displacement and Rotation
% see comments in test 1

numcam = 3;
load([datapath,'cam1_4.mat']);
load([datapath,'cam2_4.mat']);
load([datapath,'cam3_4.mat']);

A = [];
pltfig = 0;

thresh = [0.92 0.96 0.9];
ROI = [150 400 250 500;...
    50 435 200 500;...
    100 350 200 500];
trim = size(vidFrames1_4,4);

for i = 1:numcam
    eval(['cam = vidFrames',num2str(i),'_4;'])
    ffcam = [figfolder,'T4C',num2str(i)];
    [x,y] = get_xy_thresh(cam,thresh(i),ROI(i,:),trim,pltfig,ffcam);
    A = [A; x; y];
end

[Y4,svd4] = calc_pcp(A);

clear vidFrames* cam ROI tresh A

%% Create Plot
xreg = [0 392];
yreg = [-150 150];

figure('units','inches','position',[1 1 16 16],'Color','w');

clf

ax1 = axes('Position',[0.12 0.77 0.8 0.18]);
tvec = 1:size(Y1,2);
plot(ax1,tvec,Y1(1,:),'Color','k','LineWidth',2)
hold on
plot(ax1,tvec,Y1(2,:),'Color','r','LineWidth',2)
plot(ax1,tvec,Y1(3,:),'Color','b','LineWidth',2)
plot(ax1,tvec,Y1(4,:),'Color','g','LineWidth',2)
text(3,120,'(a) Test 1','interpreter','latex','fontsize',20,'Color',[0 0 0]);
ylabel('Pixels','interpreter','latex','fontsize',20)
xlim(xreg)
ylim([-150 150])
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
set(h1,'xtick',[0:50:400],'xticklabel',{'' '' '' ''});
h2 = legend('Mode 1','Mode 2','Mode 3','Mode 4');
set(h2,'interpreter','latex','fontsize',20,'orientation','vertical','Location','northeast');

ax2 = axes('Position',[0.12 0.54 0.8 0.18]);
tvec = 1:size(Y2,2);
plot(ax2,tvec,Y2(1,:),'Color','k','LineWidth',2)
hold on
plot(ax2,tvec,Y2(2,:),'Color','r','LineWidth',2)
plot(ax2,tvec,Y2(3,:),'Color','b','LineWidth',2)
plot(ax2,tvec,Y2(4,:),'Color','g','LineWidth',2)
text(3,120,'(b) Test 2','interpreter','latex','fontsize',20,'Color',[0 0 0]);
ylabel('Pixels','interpreter','latex','fontsize',20)
xlim(xreg)
ylim([-150 150])
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
set(h1,'xtick',[0:50:400],'xticklabel',{'' '' '' ''});


ax3 = axes('Position',[0.12 0.31 0.8 0.18]);
tvec = 1:size(Y3,2);
plot(ax3,tvec,Y3(1,:),'Color','k','LineWidth',2)
hold on
plot(ax3,tvec,Y3(2,:),'Color','r','LineWidth',2)
plot(ax3,tvec,Y3(3,:),'Color','b','LineWidth',2)
plot(ax3,tvec,Y3(4,:),'Color','g','LineWidth',2)
text(3,120,'(c) Test 3','interpreter','latex','fontsize',20,'Color',[0 0 0]);
ylabel('Pixels','interpreter','latex','fontsize',20)
xlim(xreg)
ylim(yreg)
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
set(h1,'xtick',[0:50:400],'xticklabel',{'' '' '' ''});

ax4 = axes('Position',[0.12 0.08 0.8 0.18]);
tvec = 1:size(Y4,2);
plot(ax4,tvec,Y4(1,:),'Color','k','LineWidth',2)
hold on
plot(ax4,tvec,Y4(2,:),'Color','r','LineWidth',2)
plot(ax4,tvec,Y4(3,:),'Color','b','LineWidth',2)
plot(ax4,tvec,Y4(4,:),'Color','g','LineWidth',2)
text(3,120,'(d) Test 4','interpreter','latex','fontsize',20,'Color',[0 0 0]);
ylabel('Pixels','interpreter','latex','fontsize',20)
xlabel('Image No.','interpreter','latex','fontsize',20)
xlim(xreg)
ylim(yreg)
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
set(h1,'xtick',[0:50:400],'xticklabel',{'0' '50' '100' '150' '200' '250' '300' '350' '400'});

Sname = [figfolder,'results'];
print(Sname,'-dpng')

%% Scatter

figure('units','inches','position',[1 1 10 6],'Color','w');
mode = 1:6;
scatter(mode,svd1.lambda,100,'k','fill')
hold on
scatter(mode,svd2.lambda,100,'r','x')
scatter(mode,svd3.lambda,100,'g','sq','fill')
scatter(mode,svd4.lambda,100,'b','*')
% text(3,120,'(a) Test 1','interpreter','latex','fontsize',20,'Color',[0 0 0]);
xlabel('Mode','interpreter','latex','fontsize',20)
ylabel('$\sigma^2$ (pix$^2$)','interpreter','latex','fontsize',20)
xlim([1 6])
% ylim(yreg)
grid on
box on
h1=gca;
set(h1,'fontsize',20);
set(h1,'tickdir','out','xminortick','on','yminortick','on');
set(h1,'ticklength',1*get(h1,'ticklength'));
h2 = legend('Test 1','Test 2','Test 3','Test 4');
set(h2,'interpreter','latex','fontsize',20,'orientation','vertical','Location','northeast');

Sname = [figfolder,'variance'];
print(Sname,'-dpng')

