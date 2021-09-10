
iimage =(1:20); %indexes of images that will be used

checkerboardSize=[0;0];
squaresize =0; % [mm]
ImageSet=true; %////FALSE -> imageSet from lab lecture 1 /// TRUE -> image set from Samsung S9+


for ii =1: length ( iimage )
    if (ImageSet)
        imageFileName = fullfile('CalibrationImages2',strcat(sprintf( '%03d', iimage(ii)),'.jpg'));
        checkerboardSize=[9;7];
        squaresize =19.3; % [mm]
    else
        imageFileName = fullfile('CalibrationImages1',strcat('Image',num2str(iimage(ii)),'.tif'));
        checkerboardSize=[13;12];
        squaresize =30;
    end
    imageData(ii).I = imread (imageFileName);
    warning('off');
    imageData(ii).XYpixel = detectCheckerboardPoints (imageData (ii).I);
    warning('on');
    
end


for ii =1: length(iimage)
    XYpixel = imageData(ii).XYpixel ;
    clear Xmm Ymm
    for jj =1: length (XYpixel)
        [row ,col]=ind2sub([checkerboardSize(2),checkerboardSize(1)],jj); % linear index to row ,col
        Xmm =(col-1)* squaresize ;
        Ymm =(row-1)* squaresize ;
        imageData(ii).XYmm(jj,:)=[Xmm Ymm];
    end
end

imageData=ZhangCalibration(imageData);
Kold=imageData(4).K;

imageIndex=4;

%--- --- --- --- --- PLOTTING REPROJECTED POINT AND TRUE ONES --- --- ---
hnd= figure ;
imshow ( imageData (imageIndex).I,'InitialMagnification' ,300)
hold on
for jj =1: size( imageData (imageIndex).XYpixel ,1)
    x_true_proj= imageData (imageIndex).XYpixel (jj ,1);
    y_true_proj= imageData (imageIndex).XYpixel (jj ,2);
    comp_proj_hom=imageData(imageIndex).P * transpose([imageData(imageIndex).XYmm(jj,:),0,1]);
    x_comp_proj=comp_proj_hom(1)/comp_proj_hom(3);
    y_comp_proj=comp_proj_hom(2)/comp_proj_hom(3);
    plot(x_true_proj, y_true_proj, '.r', 'MarkerSize',11);
    plot(x_comp_proj, y_comp_proj, '.b', 'MarkerSize',11);
    plot([x_true_proj, x_comp_proj],[y_true_proj,y_comp_proj]);
    hndtxt =text(x_true_proj,y_true_proj,num2str (jj));
    set(hndtxt ,'fontsize' ,9,'color','yellow');
end
pause (1)


%--- COMPUTE TOTAL MEAN REPROJ ERROR OF ALL POINTS OF ALL IMAGES--- --- ---
err=0;
for ii=1:size(imageData,2)
    err=err+imageData(ii).mean_reproj_error;
end
err=err/size(imageData,2);
disp(strcat("Average of the reprojection errors of the images:",num2str(err)));

%--- RADIAL DISTORTION COMPENSATION AND Z ORIENTATION --- --- --- --- ---
imageData=compRadialDistortion(imageData,2e-3);
imageData=SetZOrientation(imageData);


%--- COMPUTE TOTAL MEAN REPROJ ERROR OF ALL POINTS OF ALL IMAGES--- --- ---
err=0;
for ii=1:size(imageData,2)
    err=err+imageData(ii).dist_reproj_errors;
end
err=err/size(imageData,2);
disp(strcat("Average of the reprojection errors of the images(with radial dist. compensation):",num2str(err)));

%--- --- --- --- --- PLOTTING REPROJECTED POINT AND TRUE ONES --- --- ----
hnd= figure ;
imshow ( imageData (imageIndex).I,'InitialMagnification' ,300)
hold on
for jj =1: size( imageData (imageIndex).XYpixel ,1)
    x_true_proj= imageData (imageIndex).true_proj (jj ,1);
    y_true_proj= imageData (imageIndex).true_proj (jj ,2);
    comp_proj_hom=imageData(imageIndex).P * transpose([imageData(imageIndex).XYmm(jj,:),0,1]);
    x_comp_proj=comp_proj_hom(1)/comp_proj_hom(3);
    y_comp_proj=comp_proj_hom(2)/comp_proj_hom(3);
    xy_dist=imageData(imageIndex).distortionModel(x_comp_proj,y_comp_proj);
    x_comp_proj=xy_dist(1);
    y_comp_proj=xy_dist(2);
    plot(x_true_proj, y_true_proj, '.r', 'MarkerSize',11);
    plot(x_comp_proj, y_comp_proj, '.b', 'MarkerSize',11);
    plot([x_true_proj, x_comp_proj],[y_true_proj,y_comp_proj]);
    hndtxt =text(x_true_proj,y_true_proj, num2str (jj));
    set(hndtxt ,'fontsize' ,9,'color','yellow');
end
pause (1)


if(ImageSet)
    %--- --- --- SUPERIMPOSING THE PYRAMID (IMAGESET 2)--- --- --- --- --- ---
    for ii =1: length ( iimage )
        figure
        imshow ( imageData (ii).I,'InitialMagnification' ,200)
        hold on
        for jj=0:6
            rec = transpose([   30+jj*squaresize/8,     30+jj*squaresize/8,   -5*jj,     1
                30+jj*squaresize/8,    90-jj*squaresize/8,   -5*jj,     1
                90-jj*squaresize/8,   90-jj*squaresize/8,   -5*jj,     1
                90-jj*squaresize/8,    30+jj*squaresize/8,   -5*jj,     1]);
            proj_rec_hom = imageData (ii).P* rec ;
            proj_rec =[ proj_rec_hom(1,:)./proj_rec_hom(3,:); proj_rec_hom(2 ,:) ./ proj_rec_hom(3,:)];
            proj_rec(:,1)=transpose(imageData(ii).distortionModel(proj_rec(1,1),proj_rec(2,1)));
            proj_rec(:,2)=transpose(imageData(ii).distortionModel(proj_rec(1,2),proj_rec(2,2)));
            proj_rec(:,3)=transpose(imageData(ii).distortionModel(proj_rec(1,3),proj_rec(2,3)));
            proj_rec(:,4)=transpose(imageData(ii).distortionModel(proj_rec(1,4),proj_rec(2,4)));
            proj_rec (:, end +1)=proj_rec (: ,1);
            if (jj~=6)
                plot(proj_rec (1 ,:) ,proj_rec (2 ,:),'Color' ,[0.3+jj*0.12 0 0],'LineWidth' ,5);
            else
                plot(proj_rec (1 ,:) ,proj_rec (2 ,:),'y','LineWidth' ,5);
            end
            
            pause (0.3)
        end
    end
else
    %--- --- --- SUPERIMPOSING THE PYRAMID (IMAGESET 1)--- --- --- --- --- ---
    for ii =1: length ( iimage )
        figure
        imshow ( imageData (ii).I,'InitialMagnification' ,200)
        hold on
        for jj=0:6
            rec = transpose([   30+jj*squaresize/4,     30+jj*squaresize/4,   -10*jj,     1
                30+jj*squaresize/4,    180-jj*squaresize/4,   -10*jj,     1
                180-jj*squaresize/4,   180-jj*squaresize/4,   -10*jj,     1
                180-jj*squaresize/4,    30+jj*squaresize/4,   -10*jj,     1]);
            proj_rec_hom = imageData (ii).P* rec ;
            proj_rec =[ proj_rec_hom(1,:)./proj_rec_hom(3,:); proj_rec_hom(2 ,:) ./ proj_rec_hom(3,:)];
            proj_rec(:,1)=transpose(imageData(ii).distortionModel(proj_rec(1,1),proj_rec(2,1)));
            proj_rec(:,2)=transpose(imageData(ii).distortionModel(proj_rec(1,2),proj_rec(2,2)));
            proj_rec(:,3)=transpose(imageData(ii).distortionModel(proj_rec(1,3),proj_rec(2,3)));
            proj_rec(:,4)=transpose(imageData(ii).distortionModel(proj_rec(1,4),proj_rec(2,4)));
            proj_rec (:, end +1)=proj_rec (: ,1);
            if (jj~=6)
                plot(proj_rec (1 ,:) ,proj_rec (2 ,:),'Color' ,[0.3+jj*0.12 0 0],'LineWidth' ,5);
            else
                plot(proj_rec (1 ,:) ,proj_rec (2 ,:),'y','LineWidth' ,5);
            end
            
            pause (0.3)
        end
    end
end






