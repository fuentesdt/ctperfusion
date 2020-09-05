SHELL := /bin/bash
ITK_DIR=/rsrch1/ip/dtfuentes/github/ITK/InsightToolkit-5.0.1-install/lib/cmake/ITK-5.1
ITK_SOURCE=/rsrch1/ip/dtfuentes/github/ITK/InsightToolkit-5.0.1
ATROPOSCMD=/opt/apps/ANTsR/dev//ANTsR_src/ANTsR/src/ANTS/ANTS-build//bin/Atropos -d 3 -c [3,0.0] 
SLICER=vglrun /opt/apps/slicer/Slicer-4.4.0-linux-amd64/Slicer
DYNAMICDATA =  0001 0002 0003 0004 0005
setup: $(addprefix Processed/,$(addsuffix /setup,$(DYNAMICDATA))) 
slic: $(addprefix Processed/,$(addsuffix /slic.nii.gz,$(DYNAMICDATA))) 
roi: $(addprefix Processed/,$(addsuffix /roi.nii.gz,$(DYNAMICDATA))) 
anatomymask: $(addprefix Processed/,$(addsuffix /anatomymask.nii.gz,$(DYNAMICDATA))) 
dynamicmean: $(addprefix Processed/,$(addsuffix /dynamicmean.nrrd,$(DYNAMICDATA))) 
neighborreg: $(addprefix Processed/,$(addsuffix /dynamicG1C4inc.0000.nii.gz,$(DYNAMICDATA))) 
neighborsum: $(addprefix Processed/,$(addsuffix /dynamicG1C4incsum.0000.nii.gz,$(DYNAMICDATA))) 
reg: $(addprefix Processed/,$(addsuffix /dynamicG1C4.nhdr,$(DYNAMICDATA))) 
SOLUTIONLIST =  solution globalid meansolution meanglobalid
lstat: $(foreach idfile,$(SOLUTIONLIST), $(addprefix Processed/,$(addsuffix /$(idfile).csv,$(DYNAMICDATA))) ) 

all: Makefile
	make -f Makefile
Makefile: 
	cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_VERBOSE_MAKEFILE=ON -DITK_DIR=$(ITK_DIR)
clean:
	rm -rf CMakeCache.txt Makefile CMakeFiles/ ITKFactoryRegistration/ cmake_install.cmake  
tags:
	ctags -R --langmap=c++:+.txx --langmap=c++:+.cl $(ITK_SOURCE) .

.PHONY: tags
# https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
# https://www.gnu.org/software/make/manual/html_node/Chained-Rules.html#Chained-Rules
.SECONDARY: 

Processed/0001/table.nii.gz: 
	c3d -verbose $(@D)/dynamic.0000.nii.gz -cmv -pop -thresh 100 465 1 0  -o $(@D)/table.nii.gz
Processed/0002/table.nii.gz: 
	c3d -verbose $(@D)/dynamic.0000.nii.gz -cmv -pop -thresh 100 460 1 0  -o $(@D)/table.nii.gz
Processed/0003/table.nii.gz: 
	c3d -verbose $(@D)/dynamic.0000.nii.gz -cmv -pop -thresh 100 400 1 0  -o $(@D)/table.nii.gz
Processed/0004/table.nii.gz: 
	c3d -verbose $(@D)/dynamic.0000.nii.gz -cmv -pop -thresh 100 360 1 0  -o $(@D)/table.nii.gz
Processed/0005/table.nii.gz: 
	c3d -verbose $(@D)/dynamic.0000.nii.gz -cmv -pop -thresh 100 385 1 0  -o $(@D)/table.nii.gz
Processed/%/anatomymask.nii.gz: Processed/%/table.nii.gz
	c3d -verbose $(@D)/dynamic.0000.nii.gz -thresh -900 inf 1 0  $(@D)/dynamic.0033.nii.gz  -thresh -900 inf 1 0 -add -binarize -erode 1 10x10x10vox -dilate 1 20x20x20vox  $(@D)/table.nii.gz -multiply -type uchar -o $@
	c3d $@ -comp -thresh 1 1 1 0 -type uchar -o  $@
	echo vglrun itksnap -g $(@D)/dynamic.nrrd -s $@

Processed/%/roi.nii.gz: Processed/%/mask.nii.gz
	c3d $< -binarize  -dilate 1 20x20x20vox -type uchar -o $@
Processed/%/viewroi: Processed/%/roi.nii.gz
	vglrun itksnap -g $(@D)/dynamic.nrrd -s $<
Processed/%/aif.nii.gz: Processed/%/mask.nii.gz
	if [ ! -f $@  ] ; then c3d $< -scale 0 -type uchar $@ ; fi
Processed/%/viewmask: Processed/%/mask.nii.gz
	vglrun itksnap -g $(@D)/dynamic.nrrd -s $<
Processed/%/viewslic: 
	vglrun itksnap -g $(@D)/dynamic.nrrd -s $(@D)/slicmask.nii.gz -o $(@D)/sdt.nii.gz
Processed/%/viewsoln: 
	vglrun itksnap -g $(@D)/dynamic.nrrd -s $(@D)/slicmask.nii.gz -o $(@D)/sdt.nii.gz $(@D)/globalid.nii.gz $(@D)/solution.nii.gz $(@D)/residual.nii.gz  $(@D)/meanglobalid.nii.gz $(@D)/meansolution.nii.gz $(@D)/meanresidual.nii.gz $(@D)/slicmask.nii.gz 
Processed/%/viewaif: Processed/%/aif.nii.gz
	$(SLICER)  --python-code 'slicer.util.loadVolume("$(@D)/dynamic.nrrd");slicer.util.loadVolume("$(@D)/dynamicmean.nhdr");slicer.util.loadLabelVolume( "$<")' 
	echo vglrun itksnap -g $(@D)/dynamic.nrrd -s $<
Processed/%/slic.nii.gz:
	./itkSLICImageFilter $(@D)/dynamic.0033.nii.gz $@ 20 1
Processed/%/sdt.nii.gz: Processed/%/vesselmask.nii.gz
	c3d -verbose $<  -threshold 1 1 1 0 -sdt -o $@
Processed/%/dynamicmean.nhdr: 
	for idfile in $$(seq -f "%04g" 0 33); do  echo python slicnormalization.py --imagefile=$(@D)/dynamic.$$idfile.nii.gz; python slicnormalization.py --imagefile=$(@D)/dynamic.$$idfile.nii.gz;done
	c3d $(@D)/meandynamic.*.nii.gz -omc $@
Processed/%/dynamicSY.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.SY  -n 0 -s MI -t SY -m 60x150x40 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.SY  -n 0 -s MI -t SY -m 60x150x40 > dynamicSY.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

tuning: Processed/0004/dynamicG1C3.nhdr  Processed/0004/dynamicG1C7.nhdr  Processed/0004/dynamicGRC3.nhdr  Processed/0004/dynamicGRC7.nhdr  Processed/0004/dynamicGRCC.nhdr  Processed/0004/dynamicG4C3.nhdr  Processed/0004/dynamicG4C7.nhdr  Processed/0004/dynamicG4CC.nhdr  

Processed/%/dynamicantsreg.nhdr: 
	cd $(@D); ../../antsRegistrationSyN.sh -d 3 -f dynamic.0000.nii.gz  -m dynamic.0033.nii.gz -o antsreg > antsreg.log 2>&1;
	echo /opt/apps/ANTS/dev/install/bin//antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [ antsreg,antsregWarped.nii.gz,antsregInverseWarped.nii.gz ] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] --initial-moving-transform [ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1 ] --transform Rigid[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform SyN[ 0.1,3,0 ] --metric CC[ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1,4 ] --convergence [ 100x70x50x20,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox
	cd $(@D); echo /opt/apps/ANTS/dev/install/bin/antsMotionCorr -v 1 -d 3 -o [motcorr,motcorr.nii.gz] -m gc[ dynamic.0000.nii.gz , dynamic.nrrd , 1 , 1 , Random, 0.05  ] -t Affine[ 0.005 ] -i 20 -u 1 -e 1 -s 0 -f 1  -m CC[  dynamic.0000.nii.gz , dynamic.nrrd , 1 , 2 ] -t GaussianDisplacementField[0.15,3,0.5] -i 20 -u 1 -e 1 -s 0 -f 1 -n 34
	cd $(@D); /opt/apps/ANTS/dev/install/bin/antsMotionCorr -v 1 -d 3 -o [motcorrgcgd,motcorrgcgd.nii.gz,motcorrgcgdavg.nii.gz] -m gc[ dynamic.0000.nii.gz , dynamicc4d.nii.gz , 1 , 1 , Random, 0.05  ] -t Affine[ 0.01 ] -u 1 -i 20 -e 1 -s 0 -f 1  -m CC[  dynamic.0000.nii.gz , dynamicc4d.nii.gz , 1 , 4 ] -t GaussianDisplacementField[0.15,3,0.5] -u 1 -i 20 -e 1 -s 0 -f 1 > origantsmotioncorr.log 2>&1;
	cd $(@D); /opt/apps/ANTS/dev/install/bin/antsMotionCorr -v 1 -d 3 --use-histogram-matching 1 -o [motcorr,motcorr.nii.gz] --transform Rigid[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamicc4d.nii.gz,1,32,Regular,0.25 ] --iterations  500x250x100 -u 1 -e 1 --shrinkFactors 4x2x1 --smoothingSigmas 2x1x0 --transform Affine[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamicc4d.nii.gz,1,32,Regular,0.25 ] --iterations 500x250x100 -u 1 -e 1 --shrinkFactors 4x2x1 --smoothingSigmas 2x1x0 --transform SyN[ 0.3,3,0 ] --metric CC[ dynamic.0000.nii.gz,dynamicc4d.nii.gz,1,4 ] --iterations 70x50x20 -u 1 -e 1 --shrinkFactors 4x2x1 --smoothingSigmas 2x1x0 > antsmotioncorr.log 2>&1;
Processed/%/dynamicG1C3.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C3  -n 0 -s C3 -t G1 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C3  -n 0 -s C3 -t G1 -m 40x100x30 > dynamicG1C3.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicG1C7.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C7  -n 0 -s C7 -t G1 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C7  -n 0 -s C7 -t G1 -m 40x100x30 > dynamicG1C7.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

CLUSTERDIR = /rsrch3/home/imag_phy-rsrch/dtfuentes/github/ctperfusion
Processed/%/dynamicG1C4dbg.0000.nii.gz:
	for idfile in $$(seq  -f "%04g"  32 -1 0 ); do if [ $$idfile -lt 0032 ] ; then  FIXEDTRANSFORM="-q [$(basename $(basename $(basename $@))).$$( printf  "%04d" $$( expr $$idfile + 1 ) )0GenericAffine.mat,1] " ; fi ;  /opt/apps/ANTS/dev/install/bin/antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [$(basename $(basename $(basename $@))).$$idfile,$(basename $(basename $(basename $@))).$$idfile.nii.gz] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] -x [$(@D)/anatomymask.nii.gz,$(@D)/anatomymask.nii.gz] $$FIXEDTRANSFORM --transform Rigid[ 0.1 ] --metric MI[ $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[ $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-5,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox >  $(basename $(basename $(basename $@))).$$idfile.log  2>&1 ; done
	echo vglrun itksnap -g $(@D)/dynamic.0033.nii.gz -s $(@D)/anatomymask.nii.gz -o $@

Processed/%/dynamicG1C4dbginc.0000.nii.gz:
	for idfile in $$(seq  -f "%04g"  32 -1 0 ); do /opt/apps/ANTS/dev/install/bin/antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [$(basename $(basename $(basename $@))).$$idfile,$(basename $(basename $(basename $@))).$$idfile.nii.gz] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] -x [$(@D)/anatomymask.nii.gz,$(@D)/anatomymask.nii.gz] --transform Rigid[ 0.1 ] --metric MI[ $(@D)/dynamic.$$( printf  "%04d" $$( expr $$idfile + 1 ) ).nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[ $(@D)/dynamic.$$( printf  "%04d" $$( expr $$idfile + 1 ) ).nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-5,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox >  $(basename $(basename $(basename $@))).$$idfile.log  2>&1 ; done

Processed/%/dynamicG1C4inc.0000.nii.gz:
	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=28; for idfile in $$(seq  -f "%04g"  32 -1 0 ); do bsub  -env "all" -J $(subst /,,$*)$$idfile -cwd $(CLUSTERDIR) -n 28 -W 01:25 -q short -M 128 -R rusage[mem=128] -o  $(basename $(basename $(basename $@))).$$idfile.log /risapps/rhel7/ANTs/20200622/bin/antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [$(basename $(basename $(basename $@))).$$idfile,$(basename $(basename $(basename $@))).$$idfile.nii.gz] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] -x [$(@D)/anatomymask.nii.gz,$(@D)/anatomymask.nii.gz] --transform Rigid[ 0.1 ] --metric MI[ $(@D)/dynamic.$$( printf  "%04d" $$( expr $$idfile + 1 ) ).nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[ $(@D)/dynamic.$$( printf  "%04d" $$( expr $$idfile + 1 ) ).nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-5,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform SyN[ 0.1,3,0 ] --metric CC[  $(@D)/dynamic.$$( printf  "%04d" $$( expr $$idfile + 1 ) ).nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,4 ] --convergence [ 100x70x50x30,1e-4,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox ; done
Processed/%/dynamicG1C4incsum.0000.nii.gz: Processed/%/dynamicG1C4inc.0000.nii.gz
	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=28; for idfile in $$(seq  0 31);do BUILDCMD=''; for idtransform in $$(seq  $$idfile 32);do BUILDCMD="-r $(basename $(basename $(basename $<))).$$( printf  "%04d" $$idtransform )1Warp.nii.gz -r $(basename $(basename $(basename $<))).$$( printf  "%04d" $$idtransform )0GenericAffine.mat  $$BUILDCMD "; done; bsub  -env "all" -J $(subst /,,$*)$$( printf "%04d" $$idfile) -cwd $(CLUSTERDIR) -n 28 -W 01:25 -q short -M 128 -R rusage[mem=128] -o  $(basename $(basename $(basename $@))).$$( printf "%04d" $$idfile).log /risapps/rhel7/ANTs/20200622/bin/antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [$(basename $(basename $(basename $@))).$$( printf "%04d" $$idfile),$(basename $(basename $(basename $@))).$$( printf "%04d" $$idfile).nii.gz] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] -x [$(@D)/anatomymask.nii.gz,$(@D)/anatomymask.nii.gz] $$BUILDCMD --transform SyN[ 0.1,3,0 ] --metric CC[  $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$( printf "%04d" $$idfile).nii.gz,1,4 ] --convergence [ 100x70x50x30,1e-4,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox ; done

Processed/%/dynamicG1C4anatomymask.0000.nii.gz:
	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=28; for idfile in $$(seq  -f "%04g"  32 -1 0 ); do if [ $$idfile -lt 0032 ] ; then  FIXEDTRANSFORM="-q [$(basename $(basename $(basename $@))).$$( printf  "%04d" $$( expr $$idfile + 1 ) )0GenericAffine.mat,1] -q $(basename $(basename $(basename $@))).$$( printf  "%04d" $$( expr $$idfile + 1 ) )1InverseWarp.nii.gz" ; fi ;  bsub  -Ip -env "all" -J $(subst /,,$*)$$idfile -cwd $(CLUSTERDIR) -n 28 -W 01:25 -q short -M 128 -R rusage[mem=128] -o  $(basename $(basename $(basename $@))).$$idfile.log /risapps/rhel7/ANTs/20200622/bin/antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [$(basename $(basename $(basename $@))).$$idfile,$(basename $(basename $(basename $@))).$$idfile.nii.gz] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] -x [$(@D)/anatomymask.nii.gz,$(@D)/anatomymask.nii.gz] $$FIXEDTRANSFORM --transform Rigid[ 0.1 ] --metric MI[ $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[ $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-5,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform SyN[ 0.1,3,0 ] --metric CC[  $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,4 ] --convergence [ 100x70x50x20,1e-4,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox ; done

Processed/%/dynamicG1C4anatomymaskmip.nii.gz: 
	c3d -verbose $(@D)/dynamicG1C4incsum.00??.nii.gz $(@D)/dynamicG1C4inc.0032.nii.gz $(@D)/dynamic.0033.nii.gz -accum -max -endaccum -o $@
	c3d -verbose $(@D)/dynamicG1C4incsum.00??.nii.gz $(@D)/dynamicG1C4inc.0032.nii.gz $(@D)/dynamic.0033.nii.gz -rank -oo $(@D)/rank.%04d.nii.gz
	BUILDCMD='';for idfile in $$(seq  0 33);do  BUILDCMD="$$BUILDCMD $(@D)/rank.$$(printf %04d $$idfile).nii.gz -thresh 1 1 $$idfile 0"; done; c3d -verbose $$BUILDCMD -accum -add -endaccum -o $(@D)/mipindex.nii.gz
	
Processed/%/dynamicG1C4anatomymasksubtract.nii.gz: Processed/%/dynamicG1C4anatomymaskmip.nii.gz
	c3d -verbose $<  $(@D)/dynamicG1C4incsum.0000.nii.gz -scale -1 -add -o $@
Processed/%/vesselness.1.nii.gz: Processed/%/dynamicG1C4anatomymasksubtract.nii.gz Processed/%/anatomymask.nii.gz Processed/%/otsu.2.nii.gz
	c2d -verbose $(@D)/slice*.nii.gz -foreach -hessobj 1 $(word 2,$(subst ., ,$(@F))) $(word 2,$(subst ., ,$(@F))) -endfor -oo $(@D)/vesselnessslice%04d.nii.gz
	c3d -verbose $(@D)/vesselnessslice*.nii.gz -tile z -o $@
	c3d -verbose $(word 2,$^) $@ -copy-transform $(word 2,$^) -multiply $(word 3,$^) -replace 1 0 0 1 -multiply -o $@
Processed/%/vesselness.2.nii.gz: Processed/%/dynamicG1C4anatomymasksubtract.nii.gz Processed/%/anatomymask.nii.gz
	c3d -verbose $<  -hessobj 1 $(word 2,$(subst ., ,$(@F))) $(word 2,$(subst ., ,$(@F))) $(word 2,$^) -multiply -o $@
	c3d -verbose $< -slice z 0:-1 -oo $(@D)/slice%04d.nii.gz
Processed/%/vesselness.3.nii.gz: Processed/%/dynamicG1C4anatomymasksubtract.nii.gz Processed/%/anatomymask.nii.gz Processed/%/otsu.2.nii.gz
	c2d -verbose $(@D)/slice*.nii.gz -foreach -hessobj 1 .$(word 2,$(subst ., ,$(@F))) .$(word 2,$(subst ., ,$(@F))) -endfor -oo $(@D)/vesselnessslice%04d.nii.gz
	c3d -verbose $(word 2,$^) $(@D)/vesselnessslice*.nii.gz -tile z -copy-transform $(word 2,$^) -multiply $(word 3,$^) -replace 1 0 0 1 -multiply -o $@
Processed/%/vesselness.5.nii.gz: Processed/%/dynamicG1C4anatomymasksubtract.nii.gz Processed/%/anatomymask.nii.gz Processed/%/otsu.2.nii.gz
	c2d -verbose $(@D)/slice*.nii.gz -foreach -hessobj 1 .$(word 2,$(subst ., ,$(@F))) .$(word 2,$(subst ., ,$(@F))) -endfor -oo $(@D)/vesselnessslice%04d.nii.gz
	c3d -verbose $(word 2,$^) $(@D)/vesselnessslice*.nii.gz -tile z -copy-transform $(word 2,$^) -multiply $(word 3,$^) -replace 1 0 0 1 -multiply -o $@
Processed/%/otsu.1.nii.gz: Processed/%/vesselness.1.nii.gz
	/rsrch1/ip/dtfuentes/github/ExLib/OtsuFilter/OtsuThresholdImageFilter $< $@ 1  0 
	c3d -verbose $@ $(@D)/mask.nii.gz -binarize -erode 1 2x2x2vox -multiply -o $@
Processed/%/otsu.2.nii.gz: Processed/%/vesselness.2.nii.gz
	/rsrch1/ip/dtfuentes/github/ExLib/OtsuFilter/OtsuThresholdImageFilter $< $@ 1  0 
Processed/%/otsu.3.nii.gz: Processed/%/vesselness.3.nii.gz
	/rsrch1/ip/dtfuentes/github/ExLib/OtsuFilter/OtsuThresholdImageFilter $< $@ 1  0 
Processed/%/otsu.5.nii.gz: Processed/%/vesselness.5.nii.gz
	/rsrch1/ip/dtfuentes/github/ExLib/OtsuFilter/OtsuThresholdImageFilter $< $@ 1  0 
#echo c3d -verbose $^  -accum -add -endaccum -binarize -comp -thresh 1 50 1 0  -dilate 1 2x2x2vox  -erode 1 2x2x2vox -comp -o $@
Processed/%/vessel.nii.gz: Processed/%/otsu.1.nii.gz Processed/%/otsu.2.nii.gz 
	c3d -verbose $^  -accum -add -endaccum -binarize -o $@
	vglrun itksnap -g $(@D)/dynamicG1C4anatomymaskmip.nii.gz -s $@  -o $(@D)/dynamicG1C4anatomymasksubtract.nii.gz $(@D)/vesselness.?.nii.gz  $(@D)/otsu.?.nii.gz 
Processed/%/dynamicG1C4anatomymask.nhdr: 
	c3d -verbose $(@D)/dynamicG1C4incsum.00??.nii.gz $(@D)/dynamicG1C4inc.0032.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@
	@echo vglrun itksnap -g $@ -s $(@D)/anatomymask.nii.gz
Processed/%/dynamicG1C4anatomymasksub.nhdr: 
	c3d -verbose $(@D)/dynamicG1C4incsum.0000.nii.gz -popas A $(@D)/dynamicG1C4incsum.00??.nii.gz $(@D)/dynamicG1C4inc.0032.nii.gz $(@D)/dynamic.0033.nii.gz  -foreach  -push A -scale -1 -add -endfor -omc $@
	@echo vglrun itksnap -g $@ -s $(@D)/anatomymask.nii.gz

Processed/%/dynamicG1C4.0032.G1C4deformed.nii.gz:
	export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=28; for idfile in $$(seq -f "%04g" 0 32); do bsub  -env "all" -J $(subst /,,$*)$$idfile -cwd $(CLUSTERDIR) -n 28 -W 01:25 -q short -M 128 -R rusage[mem=128] -o  $(basename $@).$$idfile.log /risapps/rhel7/ANTs/20200622/bin/antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [$(basename $@).$$idfile,$(@D)/dynamic.$$idfile.G1C4deformed.nii.gz] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] -x [$(@D)/roi.nii.gz,$(@D)/roi.nii.gz] -r [ $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1] --transform Rigid[ 0.1 ] --metric MI[ $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[  $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform SyN[ 0.1,3,0 ] --metric CC[  $(@D)/dynamic.0033.nii.gz,$(@D)/dynamic.$$idfile.nii.gz,1,4 ] --convergence [ 100x70x50x20,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox ;done 
Processed/%/dynamicG1C4.nhdr: 
	c3d -verbose $(@D)/dynamic.*.G1C4deformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@
	@echo vglrun itksnap -g $@ -s $(@D)/roi.nii.gz
Processed/%/dynamicGRC3.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.GRC3  -n 0 -s C3 -t GR -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.GRC3  -n 0 -s C3 -t GR -m 40x100x30 > dynamicGRC3.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicGRC7.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.GRC7  -n 0 -s C7 -t GR -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.GRC7  -n 0 -s C7 -t GR -m 40x100x30 > dynamicGRC7.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicGRCC.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.GRCC  -n 0 -s CC -t GR -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.GRCC  -n 0 -s CC -t GR -m 40x100x30 > dynamicGRCC.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicG4C3.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G4C3  -n 0 -s C3 -t G4 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G4C3  -n 0 -s C3 -t G4 -m 40x100x30 > dynamicG4C3.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicG4C7.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G4C7  -n 0 -s C7 -t G4 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G4C7  -n 0 -s C7 -t G4 -m 40x100x30 > dynamicG4C7.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicG4CC.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G4CC  -n 0 -s CC -t G4 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G4CC  -n 0 -s CC -t G4 -m 40x100x30 > dynamicGRCC.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicreg.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 32); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.antsintro  -n 0 -s MI -t GR -m 60x150x40 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.antsintro  -n 0 -s MI -t GR -m 60x150x40 > dynamic.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

#cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.0032.nii.gz    -o dynamic.0032.antsintro  -n 0 -s MI -t GR -m 30x90x20 > dynamic.0032.log 2>&1; 
#for idfile in $(seq -f "%04g" 0 32); do echo $$idfile; done

Processed/%/dynamicinc.nrrd: 
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0001.nii.gz -i dynamic.0000.nii.gz -o inc.0001.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0002.nii.gz -i dynamic.0001.nii.gz -o inc.0002.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0003.nii.gz -i dynamic.0002.nii.gz -o inc.0003.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0004.nii.gz -i dynamic.0003.nii.gz -o inc.0004.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0005.nii.gz -i dynamic.0004.nii.gz -o inc.0005.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0006.nii.gz -i dynamic.0005.nii.gz -o inc.0006.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0007.nii.gz -i dynamic.0006.nii.gz -o inc.0007.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0008.nii.gz -i dynamic.0007.nii.gz -o inc.0008.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0009.nii.gz -i dynamic.0008.nii.gz -o inc.0009.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0010.nii.gz -i dynamic.0009.nii.gz -o inc.0010.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0011.nii.gz -i dynamic.0010.nii.gz -o inc.0011.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0012.nii.gz -i dynamic.0011.nii.gz -o inc.0012.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0013.nii.gz -i dynamic.0012.nii.gz -o inc.0013.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0014.nii.gz -i dynamic.0013.nii.gz -o inc.0014.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0015.nii.gz -i dynamic.0014.nii.gz -o inc.0015.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0016.nii.gz -i dynamic.0015.nii.gz -o inc.0016.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0017.nii.gz -i dynamic.0016.nii.gz -o inc.0017.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0018.nii.gz -i dynamic.0017.nii.gz -o inc.0018.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0019.nii.gz -i dynamic.0018.nii.gz -o inc.0019.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0020.nii.gz -i dynamic.0019.nii.gz -o inc.0020.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0021.nii.gz -i dynamic.0020.nii.gz -o inc.0021.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0022.nii.gz -i dynamic.0021.nii.gz -o inc.0022.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0023.nii.gz -i dynamic.0022.nii.gz -o inc.0023.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0024.nii.gz -i dynamic.0023.nii.gz -o inc.0024.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0025.nii.gz -i dynamic.0024.nii.gz -o inc.0025.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0026.nii.gz -i dynamic.0025.nii.gz -o inc.0026.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0027.nii.gz -i dynamic.0026.nii.gz -o inc.0027.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0028.nii.gz -i dynamic.0027.nii.gz -o inc.0028.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0029.nii.gz -i dynamic.0028.nii.gz -o inc.0029.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0030.nii.gz -i dynamic.0029.nii.gz -o inc.0030.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0031.nii.gz -i dynamic.0030.nii.gz -o inc.0031.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0032.nii.gz -i dynamic.0031.nii.gz -o inc.0032.antsintro -n 0 -s MI -t GR -m 30x90x20
	cd $(@D); ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz -i dynamic.0032.nii.gz -o inc.0000.antsintro -n 0 -s MI -t GR -m 30x90x20
	for idfile in $$(seq  0 32);do BUILDCMD=''; for idtransform in $$(seq -f "%04g" $$(($$idfile+1)) 33);do BUILDCMD="inc.$$idtransform.antsintroWarp.nii.gz inc.$$idtransform.antsintroAffine.txt $$BUILDCMD "; done; echo /opt/apps/ANTS/dev/install/bin/WarpImageMultiTransform 3 dynamic.$$(printf %04d $$idfile).nii.gz inc.$$(printf %04d $$idfile).antsintrodeformed.nii.gz $$BUILDCMD -R dynamic.0033.nii.gz ; done
	@echo c3d $(@D)/inc.*.antsintro.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@


Processed/%.csv: Processed/%.nii.gz
	c3d $< $(@D)/slicmask.nii.gz -lstat > $(basename $@).txt &&  sed "s/^\s\+/$(firstword $(subst /, ,$*)),$(<F),slicmask.nii.gz,/g;s/\s\+/,/g;s/LabelID/InstanceUID,SegmentationID,FeatureID,LabelID/g;s/Vol(mm^3)/Vol.mm.3/g;s/Extent(Vox)/ExtentX,ExtentY,ExtentZ/g" $(basename $@).txt > $@

Processed/0001/velocity.nii.gz:
	c3d -verbose Processed/0001/sdt.nii.gz Processed/0001/globalid.nii.gz -scale 1.57 -reciprocal -multiply Processed/0001/slicmask.nii.gz -binarize -replace 0 inf -multiply -o Processed/0001/velocity.nii.gz

Processed/0001/vesselmask.nii.gz:
	c3d -verbose $(@D)/dynamic.0033.nii.gz  -thresh 245 inf 1 0 $(@D)/mask.nii.gz -as A -binarize -multiply -o $(@D)/livervessel.nii.gz
	c3d -verbose $(@D)/livervessel.nii.gz  -replace 1 0 0 1    $(@D)/mask.nii.gz -multiply  $(@D)/livervessel.nii.gz -add -o $@

Processed/0001/outline.nii.gz: 
	c3d -verbose Processed/0001/vesselmask.nii.gz -split -foreach -dup -dilate 0 1x1x0 -scale -1 -add -endfor -merge -type short -o $@

Processed/0001/slicmask.nii.gz: Processed/0001/slic.nii.gz Processed/0001/mask.nii.gz
	#c3d $^ -binarize  -multiply -replace 1685 1 1710 1 1034 1 1084 1 2286 1 1656 1 -o $@
	c3d $^ -binarize  -multiply  -o $@
Processed/0002/slicmask.nii.gz: Processed/0002/slic.nii.gz Processed/0002/mask.nii.gz
	c3d $^ -binarize  -multiply -replace 1710 1 1685 1 2286 1 1660 1 -o $@
Processed/0003/slicmask.nii.gz: Processed/0003/slic.nii.gz Processed/0003/mask.nii.gz
	c3d $^ -binarize  -multiply -replace 2852 1 1586  1 2213  1 2211 1 2212 1 -o $@
Processed/0004/slicmask.nii.gz: Processed/0004/slic.nii.gz Processed/0004/mask.nii.gz
	c3d $^ -binarize  -multiply -replace 3071 1 1586  1 -o $@
Processed/0005/slicmask.nii.gz: Processed/0005/slic.nii.gz Processed/0005/mask.nii.gz
	c3d $^ -binarize  -multiply -replace 986 1 2720 1 1612 1 1587 1 2680 1 -o $@

Processed/0001/gmmaif.nii.gz: Processed/0001/anatomygmm.nii.gz Processed/0001/mask.nii.gz
	c3d $^ -binarize  -add -o $@
Processed/0001/anatomygmm.nii.gz: Processed/0001/dynamic.0013.nii.gz Processed/0001/liver.nii.gz 
	$(ATROPOSCMD) -m [0.1,1x1x1] -i kmeans[10] -x $(word 2,$^) -a $<  -o $@
Processed/0001/liver.nii.gz: Processed/0001/mask.nii.gz
	c3d $< -thresh 2 2 1 0 -o $@
Processed/0001/slicgmm.nii.gz: Processed/0001/slic.nii.gz Processed/0001/anatomygmm.nii.gz
	c3d -verbose $< -as A  $(word 2,$^) -replace 1 0 -binarize  -multiply -push A -thresh 1685 1685 1 0 -add -o $@
Processed/0001/setup:
	mkdir -p $(@D)
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nrrd
	c3d -verbose -mcs  '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' -oo $(@D)/dynamic.%04d.nii.gz
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 3-label.nrrd'

Processed/0002/setup:
	mkdir -p $(@D)
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nrrd
	c3d -verbose -mcs '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' -oo $(@D)/dynamic.%04d.nii.gz 
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/42 DynMulti4D  1.5  B20f 25-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 3-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 4-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 5-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 6-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/43 DynMulti4D  1.5  B20f 26_1-region 8-label.nrrd'

Processed/0003/setup:
	mkdir -p $(@D)
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nrrd
	c3d -verbose -mcs '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' -oo $(@D)/dynamic.%04d.nii.gz 
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 3-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 4-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 5-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 6-label.nrrd'

Processed/0004/setup:
	mkdir -p $(@D)
	./ImageReadWrite   '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nrrd
	c3d -verbose -mcs  '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  -oo $(@D)/dynamic.%04d.nii.gz ; 
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 11-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 3-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 4-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 5-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 6-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/24 DynMulti4D  1.5  B20f 16_1-region 9-label.nrrd'

Processed/0005/setup:
	mkdir -p $(@D)
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nrrd
	c3d -verbose -mcs '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  -oo $(@D)/dynamic.%04d.nii.gz 
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 10-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 11-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 3-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 4-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 5-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 6-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 8-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/44 DynMulti4D  1.5  B20f 32_1-region 9-label.nrrd'
