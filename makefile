ITK_DIR=/rsrch1/ip/dtfuentes/github/ITK/InsightToolkit-5.0.1-install/lib/cmake/ITK-5.1
ITK_SOURCE=/rsrch1/ip/dtfuentes/github/ITK/InsightToolkit-5.0.1

all: Makefile
	make -f Makefile
Makefile: 
	cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_VERBOSE_MAKEFILE=ON -DITK_DIR=$(ITK_DIR)
clean:
	rm -rf CMakeCache.txt Makefile CMakeFiles/ ITKFactoryRegistration/ cmake_install.cmake  
tags:
	ctags -R --langmap=c++:+.txx --langmap=c++:+.cl $(ITK_SOURCE) .

.PHONY: tags


Processed/0001/label.nii.gz:
	c3d -verbose /mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40\ DynMulti4D\ \ 1.5\ \ B20f\ 23_3-region\ ?-label.nrrd -accum -add -endaccum -o $@
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/40 DynMulti4D  1.5  B20f 23_3-region 3-label.nrrd'

Processed/0001/dynamic.nrrd:
	mkdir -p $(@D)
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' $@

Processed/0001/dynamic.nhdr:
	mkdir -p $(@D)
	./ImageReadWrite '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' $@
	echo c3d -verbose -mcs '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr' -omc  $@
	#cp '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.raw.gz'  $(basename $@).raw.gz
	#cp '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.29.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'  $@

Processed/0002/dynamic.nhdr:
	mkdir -p $(@D)
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L016_Processed/10.30.2019-Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.31.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L018_Processed/11.19.2019_Processed/DynMulti4D  1.5  B20f 34 - as a 34 frames MultiVolume by ImagePositionPatientAcquisitionTime.nhdr'
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
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 0-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 1-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 2-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 3-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 4-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 5-label.nrrd'
	ls '/mnt/FUS4/data2/ethompson/CT_Perfusion/ZPAF19L017_Processed/10.30.2019_Processed/35 DynMulti4D  1.5  B20f 17_1-region 6-label.nrrd'
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
