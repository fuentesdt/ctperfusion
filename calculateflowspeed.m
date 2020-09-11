clear all
close all

% 
%  ha = hepatic artery
%  pv = portal vein
% 
             
idfig = 1;
%for iddata = [1,4]
for iddata = [1]
   disp(sprintf('iddata = %d',iddata));
   [ tmpvol metadata ] =  nrrdread(sprintf('Processed/%04d/dynamicG1C4anatomymask.nrrd',iddata));
   volimage{iddata} = tmpvol;
   hadimage{iddata} = niftiread(sprintf('Processed/%04d/hepaticartery.distance.nii.gz',iddata));
   halimage{iddata} = niftiread(sprintf('Processed/%04d/hepaticartery.centerline.nii.gz',iddata));
   pvdimage{iddata} = niftiread(sprintf('Processed/%04d/portalvein.distance.nii.gz',iddata));
   pvlimage{iddata} = niftiread(sprintf('Processed/%04d/portalvein.centerline.nii.gz',iddata));
   jsonData{iddata} = jsondecode(fileread(sprintf('Processed/%04d/arclength.json',iddata)));

   %% Get Timing Info
   jsonData{iddata}.rawtiming = eval(['[',metadata.multivolumeframelabels,']']);
   if metadata.multivolumeframeidentifyingdicomtagunits == 'ms'
     timing = jsonData{iddata}.rawtiming * 1.e-3;   % convert to seconds 
   end
   
   %% variable spacing
   deltat =  [ timing(2) - timing(1), timing(2:length(timing)) - timing(1:length(timing)-1)];
   
   deltatmean   =  mean(deltat)
   deltatmedian =  median(deltat)
   % HACK - use median time as constant spacing
   % if (deltatmean   > 1.5 * deltatmedian )
   %    disp('timing error?? \n ');
   %    timing = deltatmedian *[0:length(timing)-1]
   %    deltat = deltatmedian *ones(1,length(timing))
   % end

   %% extract pv radius info
   pvradiuslist  = pvdimage{iddata}(find(pvlimage{iddata} == 1 ));
   figure(idfig);idfig=idfig+1;
   hist(pvradiuslist,20)
   
   %% extract ha radius info
   haradiuslist  = hadimage{iddata}(find(halimage{iddata} == 1 ));
   figure(idfig);idfig=idfig+1;
   hist(haradiuslist,20)
   
   %% extract pv centerline info
   [pvxroicenter,pvyroicenter,pvzroicenter] = ind2sub(size(pvlimage{iddata}), find(pvlimage{iddata} == 3 ));
   centerline  = zeros(size(volimage{iddata},1),length(pvxroicenter));
   for jjj =1:length(pvxroicenter)
     % disp([pvxroicenter(jjj),pvyroicenter(jjj),pvzroicenter(jjj)]);
     pvcenterline(:,jjj) = volimage{iddata}(:,pvxroicenter(jjj),pvyroicenter(jjj),pvzroicenter(jjj));
   end
   
   %% extract ha centerline info
   [haxroicenter,hayroicenter,hazroicenter] = ind2sub(size(halimage{iddata}), find(halimage{iddata} == 3 ));
   centerline  = zeros(size(volimage{iddata},1),length(haxroicenter));
   for jjj =1:length(haxroicenter)
     % disp([haxroicenter(jjj),hayroicenter(jjj),hazroicenter(jjj)]);
     hacenterline(:,jjj) = volimage{iddata}(:,haxroicenter(jjj),hayroicenter(jjj),hazroicenter(jjj));
   end
   
   figure(idfig);idfig=idfig+1;
   plot(timing,pvcenterline(:,1),'b'); hold;
   for iii=2:100:size(pvcenterline,2)
   plot(timing,pvcenterline(:,iii),'b');
   end
   for iii=1:100:size(hacenterline,2)
   plot(timing,hacenterline(:,iii),'r');
   end

   % compute velocities
   pvstart = volimage{iddata}(:,jsonData{iddata}.pvstart(1),jsonData{iddata}.pvstart(2),jsonData{iddata}.pvstart(3));
   pvend   = volimage{iddata}(:,jsonData{iddata}.pvend(1),jsonData{iddata}.pvend(2),jsonData{iddata}.pvend(3))      ;
   hastart = volimage{iddata}(:,jsonData{iddata}.hastart(1),jsonData{iddata}.hastart(2),jsonData{iddata}.hastart(3));
   haend   = volimage{iddata}(:,jsonData{iddata}.haend(1),jsonData{iddata}.haend(2),jsonData{iddata}.haend(3))      ;

   [ pvmaxstart pvidmaxstart ]  = max (pvstart);
   [ pvmaxend   pvidmaxend   ]  = max (pvend  );
   [ hamaxstart haidmaxstart ]  = max (hastart);
   [ hamaxend   haidmaxend   ]  = max (haend  );
   
   pvspeed = jsonData{iddata}.pvarclength * 1.e-3/(timing(pvidmaxend )-timing(pvidmaxstart ))  ; % m/s
   haspeed = jsonData{iddata}.haarclength * 1.e-3/(timing(haidmaxend )-timing(haidmaxstart ))  ; % m/s



   figure(idfig);idfig=idfig+1;
   plot(timing,pvstart,'b-'); hold
   plot(timing,pvend  ,'b--');
   plot(timing,hastart,'r-');
   plot(timing,haend  ,'r--');
   xlabel('time [sec]')
   legend('pvstart','pvend','hastart','haend')

   % http://brennen.caltech.edu/fluidbook/basicfluiddynamics/Navierstokesexactsolutions/poiseuilleflow.pdf
   %   avg velocity =  radius^2 /8 / viscosity * dp/dx
   viscosity = 8.9e-4; % Pa.s = N /m/m * s = kg * m /s /s / m / m  * s = kg / m / s
   % convert radius from mm to meter
   %  Pa /m = m/s * Pa * s / m /m
   %  Pa /m * 1mmHg/133.322 Pa * 1m/1e3 mm
   pvdpdx =  pvspeed * 8. *viscosity   * (1.e-3 * pvradiuslist  ).^-2 * 1.e-3/133.322; % mmHg /mm
   hadpdx =  haspeed * 8. *viscosity   * (1.e-3 * haradiuslist  ).^-2 * 1.e-3/133.322; % mmHg /mm
   pvdp   =  jsonData{iddata}.haarclength * 1.e-3* pvspeed * 8. *viscosity   * (1.e-3 * pvradiuslist  ).^-2 * 1./133.322; % mmHg 
   hadp   =  jsonData{iddata}.pvarclength * 1.e-3* haspeed * 8. *viscosity   * (1.e-3 * haradiuslist  ).^-2 * 1./133.322; % mmHg 
   
   figure(idfig);idfig=idfig+1; hist(pvdpdx,20); hold; hist(hadpdx,20)
   figure(idfig);idfig=idfig+1; plot(pvradiuslist, pvdpdx , 'b.' ); hold;  plot(haradiuslist, hadpdx , 'r.' )
   xlabel('radius [mm]')
   
   mindpdx = [ min(pvdpdx); min(hadpdx)];
   maxdpdx = [ max(pvdpdx); max(hadpdx)];
   meandpdx= [ mean(pvdpdx); mean(hadpdx)];
   stddpdx = [ std(pvdpdx); std(hadpdx)];
   mindp   = [ min(pvdp  ); min(hadp  )];
   maxdp   = [ max(pvdp  ); max(hadp  )];
   meandp  = [ mean(pvdp  ); mean(hadp  )];
   stddp   = [ std(pvdp  ); std(hadp  )];

   vessel  = {'portal vein'; 'hepatic artery' };
   minradius = [min(pvradiuslist); min(haradiuslist)];
   maxradius = [max(pvradiuslist); max(haradiuslist)];
   meanradius= [mean(pvradiuslist);mean(haradiuslist)];
   stdradius = [std(pvradiuslist); std(haradiuslist)];
   table(vessel , minradius ,mindpdx ,mindp, maxradius ,maxdpdx ,maxdp )

   arclength = [jsonData{iddata}.pvarclength; jsonData{iddata}.haarclength  ];
   bolustraveltime = [ (timing(pvidmaxend )-timing(pvidmaxstart )) ; (timing(haidmaxend )-timing(haidmaxstart )) ];
   vesselspeed = [pvspeed; haspeed];
   table(vessel ,arclength, bolustraveltime, vesselspeed, meanradius ,meandpdx ,meandp, stdradius ,stddpdx ,stddp  )

end
