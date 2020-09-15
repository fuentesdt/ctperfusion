clear all
close all

velocitydata{1} = readtable('Processed/0001/velocity.csv')


labellistha = [1:10]
labellistpv = [101:110]

figure(1); hold
for idlabel = labellistha
  xxx = velocitydata{1}(velocitydata{1}.LabelID == idlabel ,:);
  plot(xxx.FeatureID, xxx.Mean)
end 


figure(2); hold
for idlabel = labellistpv
  xxx = velocitydata{1}(velocitydata{1}.LabelID == idlabel ,:);
  plot(xxx.FeatureID, xxx.Mean)
end 

