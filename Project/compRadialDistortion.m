function imageData=compRadialDistortion(imageData,threshold)
    for ii=1:size(imageData,2)
       imageData(ii).true_proj=imageData(ii).XYpixel;
    end
   
    imageData=compRadialDistortionRecursive(imageData,threshold,[inf,inf]);
end


function imageData = compRadialDistortionRecursive(imageData, threshold,kold)



% ------------------COMPUTE K1,K2-----------------------------------------
A=[];
b=[];
for ii=1:size(imageData,2)
    for jj=1:size(imageData(ii).XYpixel,1)
        u0=imageData(ii).K(1,3);
        v0=imageData(ii).K(2,3);
        
        u_=imageData(ii).true_proj(jj,1);
        v_=imageData(ii).true_proj(jj,2);
        
        
        comp_proj_hom=imageData(ii).P*transpose([imageData(ii).XYmm(jj,:),0,1]);
        u=comp_proj_hom(1)/comp_proj_hom(3);
        v=comp_proj_hom(2)/comp_proj_hom(3);
        skew=acotd(imageData(ii).K(1,2)/imageData(ii).K(1,1));
        alpha_u=imageData(ii).K(1,1);
        alpha_v=imageData(ii).K(2,2)*sin(skew);
        Rd2=((u-u0)/alpha_u)^2+((v-v0)/alpha_v)^2;
        A=[ A
            (u-u0)*Rd2, (u-u0)*Rd2^2
            (v-v0)*Rd2,  (v-v0)*Rd2^2 ];
        b= [ b; (u_ -u) ; (v_ -v) ];
        
    end
end
k=inv((transpose(A)*A))*transpose(A)*b; %using least squares
disp(k);
%------------------BREAK IF K1,K2 < THRESHOLD-----------------------------
if (norm(k-kold)<threshold)
    for ii=1:size(imageData,2)
        imageData(ii).k=k;
        computeRd2 = @(u,v) ((u-u0)/alpha_u)^2+((v-v0)/alpha_v)^2;
        imageData(ii).distortionModel=@(u,v) [(u-u0)*(1+k(1)*computeRd2(u,v)+k(2)*computeRd2(u,v)^2)+u0, (v-v0)*(1+k(1)*computeRd2(u,v)+k(2)*computeRd2(u,v)^2)+v0];
        dist_reproj_errors=[];
        for jj=1:size(imageData(ii).XYpixel,1)
            true_proj=imageData(ii).true_proj(jj,:);  
            comp_proj_hom=imageData(ii).P * transpose([imageData(ii).XYmm(jj,:),0,1]);
            comp_proj=[comp_proj_hom(1)/comp_proj_hom(3);comp_proj_hom(2)/comp_proj_hom(3)];
            comp_proj=imageData(ii).distortionModel(comp_proj(1),comp_proj(2));
            dist_reproj_errors=[dist_reproj_errors;norm(true_proj-comp_proj)];
            
        end
        imageData(ii).dist_reproj_errors=mean(dist_reproj_errors);
        
    end
    
    
    return;
end

%-------------------COMPUTE NEW COORDINATES U,V----------------------------

for ii=1:size(imageData,2)
    
    for jj=1:size(imageData(ii).XYpixel,1)
        u0=imageData(ii).K(1,3);
        v0=imageData(ii).K(2,3);
        
        u_=imageData(ii).true_proj(jj,1);
        v_=imageData(ii).true_proj(jj,2);
        
        
        
        alpha_u=imageData(ii).K(1,1);
        alpha_v=imageData(ii).K(2,2)/sin(skew);
        x_=(u_ -u0)/alpha_u;
        y_=(v_ -v0)/alpha_v;
        f=@(x) [x(1)*(1+k(1)*(x(1)^2+x(2)^2)+k(2)*(x(1)^4+2*x(1)^2*x(2)^2+x(2)^4))-x_,x(2)*((1+k(1)*(x(1)^2+x(2)^2)+k(2)*(x(1)^4+2*x(1)^2*x(2)^2+x(2)^4)))-y_];
        options = optimset('Display','off');
        res=fsolve(f,[x_,y_],options);
 
        imageData(ii).XYpixel(jj,1)=res(1)*alpha_u+u0;
        imageData(ii).XYpixel(jj,2)=res(2)*alpha_v+v0;
    end
end

%-----------------RICOMPUTE ZHANG ----------------------------------------
imageData=ZhangCalibration(imageData);

%---------------------BACK TO STEP 1------------------------------
imageData=compRadialDistortionRecursive(imageData, threshold,k);


end
