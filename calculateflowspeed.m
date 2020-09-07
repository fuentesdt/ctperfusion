clear all
close all

% vglrun itksnap -g Processed/0004/dynamicG1C4anatomymasksub.nii.gz -s Processed/0004/hepaticarterycenterline.nii.gz -o Processed/0004/hepaticarterydistance.nii.gz
% c3d  Processed/0004/hepaticarterydistance.nii.gz Processed/0004/hepaticarterycenterline.nii.gz -lstat
volimage    = niftiread('Processed/0004/dynamicG1C4anatomymasksub.nii.gz');
volimage    = squeeze(volimage);
labimage    = niftiread('Processed/0004/hepaticarterycenterline.nii.gz');
disimage    = niftiread('Processed/0004/hepaticarterydistance.nii.gz');



%% extract radius info
radiuslist  = disimage(find(labimage == 1 ));
figure(1)
hist(radiuslist,20)
[mean(radiuslist) std(radiuslist)]

%% extract centerline info
[xroicenter,yroicenter,zroicenter] = ind2sub(size(labimage), find(labimage == 3 ));
centerline  = zeros(size(volimage,4),length(xroicenter));
for jjj =1:length(xroicenter)
  disp([xroicenter(jjj),yroicenter(jjj),zroicenter(jjj)]);
  centerline(:,jjj) = volimage(xroicenter(jjj),yroicenter(jjj),zroicenter(jjj),:);
end


figure(2)
plot(centerline(:,1)); hold;
for iii=2:100:size(centerline,2)
plot(centerline(:,iii));
end

% plot(rawdce(:,278,69,7 )); hold;  plot( rawdce(:,280,57,9)); plot(rawdce(:,251,63,12));

