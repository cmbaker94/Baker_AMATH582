% Quantify the short-crestedness of waves from stereo reconstructions and
% LiDAR imagery. This code will pick a cross-shore location to compute the
% alongshore spectra of sea-surface elevation at each data timesample and
% average for the data span.

% Set up paths and clear workspace
clear all
close all
clc
addpath(genpath('C:\Users\cmbaker9\Documents\MATLAB\MTOOLS'))
addpath(genpath('E:\code\cameras'))

%%%%%%%%%%%%%%%%% USER MANIPULATED SECTION BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%

% % WC comparison
calc_spread = [0; 20; 40]; % 20 needs to be seperate?
calc_xshore = [30];

%%%%%%%%%%%%%%%%% USER MANIPULATED SECTION ABOVE %%%%%%%%%%%%%%%%%%%%%%%%%%

for cs = 1:length(calc_spread)
    spread = calc_spread(cs);
for cx = 1:length(calc_xshore)
    xshore = calc_xshore(cx);
    
    %% STEP 0: Given user input find file information
    
    if spread == 0
        % Lidar (LI)
        lidarfile = '2018-09-01-22-13-48_Velodyne-HDL-32-Data_gridded';
        % Stereo Reconstructions (SR)
        Tcam.cam.tstart         = '09-01-2018-2214UTC';      % time starting collection based on spreadsheet
        Tcam.cam.tdate          = '09-01-2018-2155UTC';      % trial date and time - format ex: 09-01-2018-2155UTC
    elseif spread == 20
        % Lidar (LI)
        lidarfile = '2018-08-30-22-22-39_Velodyne-HDL-32-Data_gridded';
        % Stereo Reconstructions (SR)
        Tcam.cam.tstart  = '08-30-2018-2222UTC';                   % time starting collection based on spreadsheet
        Tcam.cam.tdate   = '08-30-2018-2216UTC';      % trial date and time - format ex: 09-01-2018-2155UTC
    elseif spread == 30
        % Lidar (LI)
        lidarfile = '';
        % Stereo Reconstructions (SR)
        Tcam.cam.tstart  = '08-29-2018-2255UTC';                   % time starting collection based on spreadsheet
        Tcam.cam.tdate   = '08-29-2018-2236UTC';      % trial date and time - format ex: 09-01-2018-2155UTC
    elseif spread == 40
        % Lidar (LI)
        lidarfile = '2018-08-30-21-29-26_Velodyne-HDL-32-Data_gridded';
        % Stereo Reconstructions (SR)
        Tcam.cam.tstart  = '08-30-2018-2129UTC';                   % time starting collection based on spreadsheet
        Tcam.cam.tdate   = '08-30-2018-2119UTC';      % trial date and time - format ex: 09-01-2018-2155UTC
    end
    
    %% STEP 1: Create paths and load files
    
    % general path and names
    datapath    = 'E:/';
    
    % Stereo Reconstructions
    Tcam        = TRC_camera_info(Tcam);
    transect    = load([Tcam.datafolder,'dem_transect_x',num2str(xshore),'m_xavg5cm.mat']);
    
    %% STEP 2: Create figure folders
    
    % figure folder
    fssubfolder = datestr(date,'yy-mm-dd');
    figfolder   = [datapath,'figures/meas_comp/',Tcam.trialname,'/',Tcam.trimname,fssubfolder,'/'];
    
    % make figure folders
    eval(['!mkdir ',datapath,'figures/meas_comp/',Tcam.trialname]);
    eval(['!mkdir ',datapath,'figures/meas_comp/',Tcam.trialname,'/',Tcam.trimname]);
    eval(['!mkdir ',figfolder])
    
    %% STEP 4: Choose cross-shore location
    
    % Let's choose the location based on the bathymetry and the location with
    % maximum points
    
    
    %% STEP 5: Choose cross-shore location and extract sea-surface elevation
    
    eval(['dy          = transect.y',num2str(xshore),'(2,1)-transect.y',num2str(xshore),'(1,1);'])
    eval(['z = squeeze(transect.z',num2str(xshore),'(:,:));'])
    eval(['x = nanmean(transect.x',num2str(xshore),',1)'';'])

    %% STEP 6: Compute spectra

    order = 3;
    framelen = 39;
    
    dx = 0;
    
    count = 0
    for i = 6:size(z,2)-5
        count = 1+count;
        ztemp = squeeze(z(:,i-dx:i+dx));
        ztemp = double(nanmean(ztemp,2));
        ztemp(ztemp>1.35)=NaN;
        ztemp(ztemp<0.95)=NaN;
        eval(['ytemp = transect.y',num2str(xshore),'(:,',num2str(i),');'])
        ztemp(ytemp>13)=NaN;
        ztemp(ytemp<-13)=NaN;
        
        zfittemp = movmean(ztemp,11,'omitnan','EndPoints','fill');
        filt = [nanmean(zfittemp)-(2.5*nanstd(zfittemp)) nanmean(zfittemp)+(4*nanstd(zfittemp))];
        zfittemp(zfittemp<filt(1))=NaN;
        zfittemp(zfittemp>filt(2))=NaN;
        zfit(:,count)=zfittemp;
    end
    
    %%
    figure('units','inches','position',[1 1 7 7],'Color','w');
    count = 1;
    for i = 1:size(zfit,2)
        count = count+1;
        ztemp = zfit(:,i);
        % remove nans and interpolate
        nanz            = isnan(ztemp);             % find location of NaNs
        nant            = [1:numel(ztemp)]';       % make strings for interp
        nanratio        = sum(nanz)/length(nant); % find ratio of NaNs
        ztemp(nanz)     = interp1(nant(~nanz),ztemp(~nanz),nant(nanz)); % interpolate between the NaNs
        zcutnan         = ztemp(~isnan(ztemp)); % if nans still at the beginning or end of list, just remove these points
        eta             = zcutnan-nanmean(zcutnan);
        eta             = detrend(eta,1);% detrending
        
        if length(eta)>2350
%             WL = length(eta);
%             OL = 0;
            L = 13; % spatial domain
            n = length(eta); % Fourier modes
            ktemp = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);
            Stemp = fftshift(fft(eta));
%             [Stemp,ktemp,Sc(count,:,:)]   = pwelch(eta,WL,OL,[],1/dy,'ConfidenceLevel',0.95); % compute spectra
            [val,id] = min(abs(ktemp-1));
            filter = zeros(size(ktemp));
            filter(1:id-1) = 1;
            filter(id:id+2) = [0.7089 0.2363 0.0225];
            S(count,:) = Stemp.*filter;
            k(count,:) = ktemp;
        else
            S(count,:) = NaN(size(S(count-1,:)));
            k(count,:) = NaN(size(k(count-1,:)));
            Sc(count,:,:) = NaN(size(Sc(count-1,:,:)));
        end
        
        if i<20
            clf
            semilogy(k(count,:),S(count,:),'k','LineWidth',2)
            xlabel('$L^{-1}$ (m$^{-1}$)','interpreter','latex','fontsize',20);
            ylabel('$S_{\eta\eta}$ (m$^2$/Hz)','interpreter','latex','fontsize',20);
            h1=gca;
            set(h1, 'YScale', 'log')
            set(h1,'tickdir','in','xminortick','on','yminortick','on');
            set(h1,'ticklength',1*get(h1,'ticklength'));
            set(h1,'fontsize',15);
            ylim([10^-6 10^-3])
            title(['x = ',num2str(xshore),'m , t = ',num2str(i/Tcam.Hz)],'interpreter','latex','fontsize',20);
            pause(0.2)
        end
    end
    
    
    %% Prep data
    Savg=nanmean(S,1);
    Scavg = nanmean(Sc,1);
    
    y = ytemp;
    x = nanmean(x);
    
    
    subname = '';%'onewindow_11movmean_detrended';
    psname = [Tcam.datafolder,'AMATH/dem_transect_wavecrest_length_x',num2str(xshore),'_',subname,'.mat'];
    eval(['save -v7.3 ',psname,' S',' k',' Sc',' Savg',' Scavg',' y',' x',' zfit']);

close all
clear zfit
end
end

