% This code will plot rectified images using code from
% D_gridGenExpampleRect.m in the CIRN-Quantitative-Coastal-Imaging-Toolbox


% Set up paths and clear workspace
clear all
close all
clc
addpath(genpath('C:\Users\cmbaker9\Documents\MATLAB\MTOOLS'))
addpath(genpath('E:\code\cameras'))
addpath(genpath('E:\code\insitu'))
addpath(genpath('E:\code\CIRN-Quantitative-Coastal-Imaging-Toolbox\X_CoreFunctions/'))
%%%%%%%%%%%%%%%%%%%%% USER MANIPULATED SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Trial info
    Tinfo.Hs = 0.30;
    Tinfo.Tp = 2;
    Tinfo.tide = 1.07;
    Tinfo.spread = 20;

if Tinfo.spread == 0
    % In situ
    sz.Tdate = '09-01-2018-2213UTC';
    is.Tdate = '09-06-2018-1559UTC';
    % Lidar (LI)
    lidarfile = '2018-09-01-22-13-48_Velodyne-HDL-32-Data_gridded';
    % Stereo Reconstructions (SR)
    Tcam.tstart         = '09-01-2018-2214UTC';                   % time starting collection based on spreadsheet
    Tcam.tdate          = '09-01-2018-2155UTC';      % trial date and time - format ex: 09-01-2018-2155UTC
    offsets             = [-487;-69];% [-588; -70]; % index offset relative to camera [in situ, lidar]
elseif Tinfo.spread == 20
    % In situ
    sz.Tdate = '08-30-2018-2222UTC';
    is.Tdate = '09-06-2018-1655UTC';
    % Lidar (LI)
    lidarfile = '2018-08-30-22-22-39_Velodyne-HDL-32-Data_gridded';
    % Stereo Reconstructions (SR)
    Tcam.tstart  = '08-30-2018-2226UTC';                   % time starting collection based on spreadsheet
    Tcam.tdate   = '08-30-2018-2216UTC';      % trial date and time - format ex: 09-01-2018-2155UTC 
elseif Tinfo.spread == 40
    % In situ
    sz.Tdate = '08-30-2018-2129UTC'; % 2119+20 min
    is.Tdate = '09-06-2018-1841UTC';
    % Lidar (LI)
    lidarfile = '2018-08-30-21-29-26_Velodyne-HDL-32-Data_gridded';
    % Stereo Reconstructions (SR)
    Tcam.tstart  = '08-30-2018-2129UTC';                   % time starting collection based on spreadsheet
    Tcam.tdate   = '08-30-2018-2119UTC';      % trial date and time - format ex: 09-01-2018-2155UTC 
end

%% STEP 1: Create paths, files and naming

% general path and names
datapath    = 'E:\';

% Stereo Reconstructions
Tcam.camerasys   = 'TRM';                     % camera setup - e.g., TRM (offshore) or TRC (onshore)
Tcam.scene       = '1';                       % scene number of trial - typ 1
Tcam.imagestart  = 0;                      % images number of first frame on file                
Tcam.dx          = 0.05;
Tcam.dy          = 0.05;
Tcam.regx        = [25:Tcam.dx:37];
Tcam.regy        = [-13:Tcam.dy:13];
Tcam.Hz           = 8;

imagepath = ['D:\TRC_Fall_Experiment\',Tcam.camerasys,'-',Tcam.tdate,'\',Tcam.camerasys,'-',Tcam.tdate,'_Scene1_JPEG\'];
Tcam.numframes   = length(dir([imagepath, '*.jpg']))-1;   % number of frames processed

Tcam.trialname   = [Tcam.camerasys,'-',Tcam.tdate];
Tcam.imagerange  = [num2str(Tcam.imagestart,'%05.f'),'-',num2str(Tcam.imagestart+(Tcam.numframes-1),'%05.f')];
Tcam.trimname    = ['frames_',Tcam.imagerange,'\'];  
Tcam.datafolder  = [datapath,'data\processed\cameras\',Tcam.trialname,'\',Tcam.trimname];


%% STEP 2: Create figure folders

% figure folder
fssubfolder = datestr(date,'yy-mm-dd');
figfolder   = [datapath,'figures\cameras\images\',Tcam.trialname,'\',Tcam.trimname,fssubfolder,'\'];

% make figure folders
eval(['!mkdir ',datapath,'figures\cameras\images\',Tcam.trialname]);
eval(['!mkdir ',datapath,'figures\cameras\images\',Tcam.trialname,'\',Tcam.trimname]);
eval(['!mkdir ',figfolder])

%% Establish timeseries range:

starttemp       = datenum(Tcam.tstart(1:end-3),'mm-dd-yyyy-HHMM')+datenum(0,0,0,0,0,Tcam.imagestart/Tcam.Hz);
endtemp         = datenum(Tcam.tstart(1:end-3),'mm-dd-yyyy-HHMM')+datenum(0,0,0,0,0,(Tcam.imagestart+Tcam.numframes-1)/Tcam.Hz);
camera.time        = starttemp:datenum(0,0,0,0,0,1/Tcam.Hz):endtemp;
clear *temp

%% Insitu

load([datapath,'data/processed/cameras/c2_intrinsics_extrinsics.mat']);

% extrinsics = [39.35 0.02 11.03 267.7*pi/180 32.82*pi/180 0.13*pi/180];
extrinsics(1) = extrinsics(1)+0.75;

%% Create matrix to rectify images
% see code: D_gridGenExampleRect.m

localOrigin = [0, 0]; % [ x y]
localAngle =[0]; % Degrees +CCW from Original World X
localFlagInput=1;

ixlim=[19 36];
iylim=[-14.5 14.5];
idxdy=0.01;

iz=0;

%  World Extrinsics, need to make into sell
Extrinsics{1}=extrinsics;
Intrinsics{1}=intrinsics;

% %  Local Extrinsics
% localExtrinsics{k} = localTransformExtrinsics(localOrigin,localAngle,1,xtrinsics{1});

%  Create Equidistant Input Grid
[iX iY]=meshgrid([ixlim(1):idxdy:ixlim(2)],[iylim(1):idxdy:iylim(2)]);

%  Make Elevation Input Grid
iZ=iX*0+iz;

% If entered as Local
if localFlagInput==1
    % Assign local Grid as Input Grid
    localX=iX;
    localY=iY;
    localZ=iZ;
    
    % Assign world Grid as Rotated local Grid
    [ X Y]=localTransformEquiGrid(localOrigin,localAngle,0,iX,iY);
    Z=X*.0+iz;
end

teachingMode = 0;

%% extract x = 28

%% plot
imageno =  7200:1:11999;

% figure('units','inches','position',[1 1 12 8],'color','w')
for i = 1:length(imageno) 


    %read image
    imagefile = [imagepath,getfield(dir([imagepath,'Movie1_Scene1_c2_',sprintf('%05d',imageno(i)),'_*.jpg']),'name')];
    IM{1} = imread(imagefile);
    
    % World Rectification
    [Ir]= imageRectifier(IM,Intrinsics,Extrinsics,X,Y,Z,teachingMode);
    
    [val,id] = min(abs(X(1,:)-28));
    Irtemp = double(rgb2gray(Ir));
    IMtran(i,:) = Irtemp(:,id)';
    IMy(i,:) = Y(:,1);
    dy = Y(2,1)-Y(1,1);
    
    WL = length(IMy(i,:));
    OL = 0;
    
    speccompute = (IMtran(i,:)-nanmean(IMtran(i,:)))/256;
    speccompute             = detrend(speccompute,1);% detrending
    %     [Stemp,ktemp]   = pwelch(speccompute,WL,OL,[],1/dy,'ConfidenceLevel',0.95); % compute spectra
    L = 13; % spatial domain
    n = length(IMtran(i,:)); % Fourier modes
    ktemp = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);
    Stemp = fftshift(fft(eta));
    [val,id] = min(abs(ktemp-1));
    filter = zeros(size(ktemp));
    filter(1:id-1) = 1;
    filter(id:id+2) = [0.7089 0.2363 0.0225];
    S(i,:) = Stemp.*filter;
    k(i,:) = ktemp;
    
end

%%
Savg=nanmean(S,1);
y = nanmean(IMy,1);
x = 30;

xshore = 30;
subname = '';%'onewindow_11movmean_detrended';
eval(['!mkdir ',Tcam.datafolder,'AMATH'])
psname = [Tcam.datafolder,'AMATH/image_values_transect_wavecrest_length_x',num2str(xshore),'_',subname,'.mat'];
eval(['save -v7.3 ',psname,' IMtran',' IMy',' x']);
psname = [Tcam.datafolder,'AMATH/image_transect_wavecrest_length_x',num2str(xshore),'_',subname,'.mat'];
eval(['save -v7.3 ',psname,' S',' k',' Savg',' y',' x']);
