

timing{1} = load('Rabbit VX2 CT Perfusion Image Timing/19L016_10292019.mat');
timing{2} = load('Rabbit VX2 CT Perfusion Image Timing/19L017_10312019.mat');
timing{3} = load('Rabbit VX2 CT Perfusion Image Timing/19L017_10302019.mat');
timing{4} = load('Rabbit VX2 CT Perfusion Image Timing/19L018_11192019.mat');


deltadt{1} = timing{1}.times19L016_10292019(49,2:34) -timing{1}.times19L016_10292019(49,1:33);
deltadt{2} = timing{2}.times19L017_10312019(49,2:34) -timing{2}.times19L017_10312019(49,1:33);
deltadt{3} = timing{3}.times19L017_10302019(49,2:34) -timing{3}.times19L017_10302019(49,1:33);
deltadt{4} = timing{4}.times19L018_11192019(49,2:34) -timing{4}.times19L018_11192019(49,1:33);

deltadt{:}
mean(deltadt{1})
mean(deltadt{2})
mean(deltadt{3})
mean(deltadt{4})
timing = 1.5e3*[0:33]

