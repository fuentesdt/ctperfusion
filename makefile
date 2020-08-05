SHELL := /bin/bash
ITK_DIR=/rsrch1/ip/dtfuentes/github/ITK/InsightToolkit-5.0.1-install/lib/cmake/ITK-5.1
ITK_SOURCE=/rsrch1/ip/dtfuentes/github/ITK/InsightToolkit-5.0.1
ATROPOSCMD=/opt/apps/ANTsR/dev//ANTsR_src/ANTsR/src/ANTS/ANTS-build//bin/Atropos -d 3 -c [3,0.0] 
SLICER=vglrun /opt/apps/slicer/Slicer-4.4.0-linux-amd64/Slicer
DYNAMICDATA =  0001 0002 0003 0004 0005
setup: $(addprefix Processed/,$(addsuffix /setup,$(DYNAMICDATA))) 
slic: $(addprefix Processed/,$(addsuffix /slic.nii.gz,$(DYNAMICDATA))) 
dynamicmean: $(addprefix Processed/,$(addsuffix /dynamicmean.nrrd,$(DYNAMICDATA))) 
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
Processed/%/dynamicreg.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 32); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.antsintro  -n 0 -s MI -t GR -m 30x90x20 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.antsintro  -n 0 -s MI -t GR -m 30x90x20 > dynamic.$$idfile.log 2>&1;  done
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
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nhdr
	c3d -verbose -mcs  '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' -oo $(@D)/dynamic.%04d.nii.gz
	c3d -verbose /mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40\ DynMulti4D\ \ 1.5\ \ B20f\ 23_3-region\ ?-label.nrrd -accum -add -endaccum -o $(@D)/label.nii.gz
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
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $(@D)/dynamic.nrrd
	c3d -verbose -mcs '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' -foreach -region 140x150x50vox 250x200x45 -endfor -omc  $(@D)/dynamic.nhdr -oo $(@D)/dynamic.%04d.nii.gz 
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
