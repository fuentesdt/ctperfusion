clear all
close all

% vglrun itksnap -g Processed/0004/dynamicG1C4anatomymasksub.nii.gz -s Processed/0004/hepaticarterycenterline.nii.gz -o Processed/0004/hepaticarterydistance.nii.gz
% vglrun itksnap -g Processed/0004/dynamicG1C4anatomymasksubtract.nii.gz -s Processed/0004/hepaticartery.nii.gz
% c3d  Processed/0004/hepaticarterydistance.nii.gz Processed/0004/hepaticarterycenterline.nii.gz -lstat
             
volimage{1} = nrrdread('Processed/0001/dynamicG1C4anatomymask.nrrd');
volimage{2} = nrrdread('Processed/0002/dynamicG1C4anatomymask.nrrd');
volimage{3} = nrrdread('Processed/0003/dynamicG1C4anatomymask.nrrd');
volimage{4} = nrrdread('Processed/0004/dynamicG1C4anatomymask.nrrd');
disimage{1} = nrrdread('Processed/0001/vesseldistance.nii.gz');
disimage{2} = nrrdread('Processed/0002/vesseldistance.nii.gz');
disimage{3} = nrrdread('Processed/0003/vesseldistance.nii.gz');
disimage{4} = nrrdread('Processed/0004/vesseldistance.nii.gz');
labimage{1} = nrrdread('Processed/0001/vesselcenterline.nii.gz');
labimage{2} = nrrdread('Processed/0002/vesselcenterline.nii.gz');
labimage{3} = nrrdread('Processed/0003/vesselcenterline.nii.gz');
labimage{4} = nrrdread('Processed/0004/vesselcenterline.nii.gz');

jsonText = fileread(jsonFilename);
jsonData = jsondecode(jsonText)


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

% close(2); figure(2); plot(squeeze(volimage(272,262,72,: )));  hold; plot(squeeze(volimage(193,277,23,: ))); plot(squeeze(volimage(174,251,12,: )));plot(squeeze(volimage(259,188,67,: )));

