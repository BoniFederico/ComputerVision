function imageData=SetZOrientation(imageData)
for ii=1:size(imageData,2)
     
    if(norm([180;150;400]+imageData(ii).t)<norm([180;150;-400]+imageData(ii).t))

         imageData(ii).R=[imageData(ii).R(:,1),imageData(ii).R(:,2),-imageData(ii).R(:,3)];
         imageData(ii).P= imageData(ii).K*[imageData(ii).R,imageData(ii).t];
         imageData(ii).P=imageData(ii).P/norm([imageData(20).P(1,1),imageData(20).P(2,1),imageData(20).P(3,1)]);
    end
end