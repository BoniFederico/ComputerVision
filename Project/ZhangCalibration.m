
function imageData= ZhangCalibration(imageData)

%------------------------ESTIMATING H MATRIX-------------------------------
for ii =1: size(imageData,2)
    XYpixel = imageData (ii). XYpixel ;
    XYmm= imageData (ii).XYmm;
    A=[];
    b=[];
    for jj =1: length ( XYpixel )
        Xpixel = XYpixel (jj ,1);
        Ypixel = XYpixel (jj ,2);
        Xmm=XYmm(jj ,1);
        Ymm=XYmm(jj ,2);
        m=[ Xmm; Ymm; 1];
        O =[0;0;0];
        A=[A; m' O' -Xpixel *m';O' m' -Ypixel *m'];
        b=[b ;0;0];
    end
    [U,S,V]= svd(A);
    h=V(:, end); %right singular vector of the smallest singular value
    imageData (ii).H= reshape (h ,[3 3])';
end

%-------------------ESTIMATING CALIBRATION MATRIX K------------------------


%Obtaining V matrix and b vector ---
clear V;
V=[];
for ii=1:size(imageData,2)
    V=[V; fromHtoVij(imageData(ii).H,1,2); fromHtoVij(imageData(ii).H,1,1)-fromHtoVij(imageData(ii).H,2,2)];
end
[U,S,C]=svd(V);
b= C(:,end);
B=[b(1),b(2),b(4);b(2),b(3),b(5);b(4),b(5),b(6)];


% Obtaining K (formulas can be found in the relation, in accordance with 
% "A flexible new technique for camera calibration" APPENDIX B - Zhang)

v0=(b(2)*b(4)-b(1)*b(5))/(b(1)*b(3)-b(2)^2);
lambda = b(6)-( b(4)^2+v0*(b(2)*b(4)-b(1)*b(5)))/b(1);
alpha = sqrt(lambda/b(1));
beta = sqrt(lambda*b(1)/(b(1)*b(3)-b(2)^2));
gamma = -b(2)*alpha^2*beta/lambda;
u0 = gamma*v0/beta-b(4)*alpha^2/lambda;

K = [ alpha   gamma  u0
       0      beta   v0
       0      0      1   ];
   
for ii=1:length(imageData)
    imageData(ii).K=K;
end

%-----------------ESTIMATING-R-AND-t-(extrinsic parameters)---------------
for ii=1:size(imageData,2)
    Kinv=inv(K);
    %taking the mean of |h1| and |h2| , because due to errors |h1|!=|h2|
    lambda = (1/norm(Kinv*imageData(ii).H(:,1))+1/norm(Kinv*imageData(ii).H(:,1)))/2;
    imageData(ii).R = [ lambda*Kinv*imageData(ii).H(:,1), lambda*Kinv*(imageData(ii).H(:,2))];
    r3=cross(imageData(ii).R(:,1),imageData(ii).R(:,2));
    imageData(ii).R=[imageData(ii).R,r3];
    [U,S,V]=svd(imageData(ii).R);
    imageData(ii).R=U*V';
    imageData(ii).t=lambda*Kinv*imageData(ii).H(:,3);
    imageData(ii).P= K*[imageData(ii).R,imageData(ii).t];
end


%----------COMPUTE PERSPECTIVE PROJECTION MATRIX P-------------------------
for ii=1:length(imageData)
    imageData(ii).P= K*[imageData(ii).R,imageData(ii).t];
    imageData(ii).P=imageData(ii).P/norm([imageData(ii).P(1,1),imageData(ii).P(2,1),imageData(ii).P(3,1)]);
end


%------------------  REPROJECTION ERRORS ----------------------------------

for jj=1:size(imageData,2)
 
    reproj_errors=0;
    for  ii=1:size( imageData (jj).XYpixel ,1)
        x_true_proj=imageData(jj).XYpixel(ii,1); %actually NOT the ideal TRUE one, but the one obtained with detectedCheckerboardPoints
        y_true_proj=imageData(jj).XYpixel(ii,2);
        comp_proj_hom=imageData(jj).P * transpose([imageData(jj).XYmm(ii,:),0,1]);
        x_comp_proj=comp_proj_hom(1)/comp_proj_hom(3);
        y_comp_proj=comp_proj_hom(2)/comp_proj_hom(3);
        reproj_errors=reproj_errors+norm([x_true_proj,y_true_proj]-[x_comp_proj,y_comp_proj]);
    end
    
    imageData(jj).mean_reproj_error=reproj_errors/size( imageData (jj).XYpixel,1);
end


end



function Vij = fromHtoVij(H,i,j)
Vij=[H(1,i)*H(1,j),H(1,i)*H(2,j)+H(2,i)*H(1,j),H(2,i)*H(2,j),H(3,i)*H(1,j)+H(1,i)*H(3,j), H(3,i)*H(2,j)+H(2,i)*H(3,j),H(3,i)*H(3,j)];
end
