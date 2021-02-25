function [x,y] = get_xy_thresh(cam,thresh,ROI,trim,pltfig,ffcam)
% Extract the x y vectors of positions from the images
% INPUT: 
% cam: camera 4d matrix
% thresh: threshold value
% ROI: region of interest
% trim: number of images to trip to
% pltfig: flag if plotting
% ffcam: fig folder camera, test
% OUTPUT:
% x: x plane vector
% y: y plane vector

if pltfig == 1
    figure('units','inches','position',[1 1 8 12],'Color','w');
    eval(['!mkdir ',ffcam])
end

[height width rgb num_frames] = size(cam);

for j=1:trim
    X=cam(:,:,:,j); % extract camera image at each times step
    Xbw = double(rgb2gray(X)); % convert to bw
    Xback = Xbw/max(Xbw,[],'all'); % store normalized image
    Xnorm = Xbw/max(Xbw,[],'all'); % create normalized image to max
    Xnorm(Xnorm<thresh)=0; % threshold image
    xmask = zeros(size(Xnorm)); % create mask matrix
    xmask(ROI(1):ROI(2),ROI(3):ROI(4)) = 1; % create mask
    Xnorm = Xnorm.*xmask; % multiply by mask
    props = regionprops(true(size(Xnorm)), Xnorm, 'WeightedCentroid'); % find centroid
    x(j)  = props.WeightedCentroid(1);
    y(j) = props.WeightedCentroid(2);
    if j < trim
        if pltfig == 1
            subplot(2,1,1)
            pcolor(Xback); shading interp; colorbar;
            hold on
            plot([ROI(3) ROI(3) ROI(4) ROI(4) ROI(3)],[ROI(1) ROI(2) ROI(2) ROI(1) ROI(1)],'b','LineWidth',2,'LineStyle',':')
            scatter(props.WeightedCentroid(1),props.WeightedCentroid(2),20,'r','fill');
            colormap('gray')
            set(gca, 'YDir','reverse')
            text(0,-25,'(a) Normalized Pixel Intensity','interpreter','latex','fontsize',20,'Color',[0 0 0]);
            xlabel('X (pixels)','interpreter','latex','fontsize',20)
            ylabel('Y (pixels)','interpreter','latex','fontsize',20)
            grid on
            box on
            h1=gca;
            set(h1,'fontsize',20);
            set(h1,'tickdir','out','xminortick','on','yminortick','on');
            set(h1,'ticklength',1*get(h1,'ticklength'));
            
            subplot(2,1,2)
            pcolor(Xnorm); shading interp; colorbar;
            hold on
            plot([ROI(3) ROI(3) ROI(4) ROI(4) ROI(3)],[ROI(1) ROI(2) ROI(2) ROI(1) ROI(1)],'b','LineWidth',2,'LineStyle',':')
            scatter(props.WeightedCentroid(1),props.WeightedCentroid(2),20,'r','fill');
            colormap('gray')
            set(gca, 'YDir','reverse')
            set(gca, 'YDir','reverse')
            text(0,-25,'(b) Thresheld Image','interpreter','latex','fontsize',20,'Color',[0 0 0]);
            xlabel('X (pixels)','interpreter','latex','fontsize',20)
            ylabel('Y (pixels)','interpreter','latex','fontsize',20)
            grid on
            box on
            h1=gca;
            set(h1,'fontsize',20);
            set(h1,'tickdir','out','xminortick','on','yminortick','on');
            set(h1,'ticklength',1*get(h1,'ticklength'));
            drawnow
            Sname = [ffcam,'/example_',num2str(j)];
            print(Sname,'-dpng')
            clf
        end
    end
end

end