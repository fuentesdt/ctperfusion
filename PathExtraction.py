import vtk
import math
import subprocess
import sys
import json
def writearclength(numpoints,rawpoints,outputVTK):
   slicerOrientation   = vtk.vtkPoints()
   slicerOrientation.SetNumberOfPoints(numpoints)
   for idpoint in range(numpoints):
     slicerOrientation.SetPoint(idpoint,rawpoints[idpoint][   0],rawpoints[idpoint][   1],rawpoints[idpoint][   2] )
   
   # loop over points an store in vtk data structure
   arclength = 0.0
   vertices= vtk.vtkCellArray()
   for idpoint in range(slicerOrientation.GetNumberOfPoints()-1):
       line = vtk.vtkLine()
       line.GetPointIds().SetId(0, idpoint)
       line.GetPointIds().SetId(1, idpoint+1)
       arclength = arclength + math.sqrt(vtk.vtkMath.Distance2BetweenPoints(rawpoints[idpoint],rawpoints[idpoint+1]))
       vertices.InsertNextCell( line ) 
   
   print "arclength =  ", arclength 
   
   # set polydata
   polydata = vtk.vtkPolyData()
   polydata.SetPoints(slicerOrientation)
   polydata.SetLines( vertices )
   
   # write to file
   polydatawriter = vtk.vtkDataSetWriter()
   polydatawriter.SetFileName(outputVTK)
   polydatawriter.SetInputData(polydata)
   polydatawriter.Update()
   return arclength


print "This is the name of the script: ", sys.argv[0]
outputjson = "%s.json" % sys.argv[1]
print "outputfile   " , outputjson 
print "Number of arguments: ", len(sys.argv)
print "The arguments are: " , sys.argv


getCentroidCmd = 'c3d %s -split -foreach -centroid -endfor' %  sys.argv[3]
print getCentroidCmd
centroidProcess = subprocess.Popen(getCentroidCmd ,shell=True,stdout=subprocess.PIPE )
while ( centroidProcess.poll() == None ):
   pass
rawcentroid = [lines.strip('\n') for lines in centroidProcess.stdout.readlines()]
centroidvox = [eval(x.split("CENTROID_VOX")[1]) for x in rawcentroid if "CENTROID_VOX" in x]
numcentroid = len(centroidvox)
# 4 label + background
assert (numcentroid  == 5)


getHAPointsCmd = './PathExtraction %sha.nii.gz  %s %d %d %d %d %d %d 2 1' %  (sys.argv[1],sys.argv[2], centroidvox[1][0], centroidvox[1][1], centroidvox[1][2], centroidvox[2][0], centroidvox[2][1], centroidvox[2][2])
print getHAPointsCmd 
haPointsProcess = subprocess.Popen(getHAPointsCmd ,shell=True,stdout=subprocess.PIPE )
while ( haPointsProcess.poll() == None ):
   pass
rawhadata   = [lines.strip('\n') for lines in haPointsProcess.stdout.readlines()]
rawhapoints = [eval(x.split("MeshPoints:")[1]) for x in rawhadata  if "MeshPoints:" in x  ]
rawhaidx    = [eval(x.split("IdxPoints:")[1]) for x in rawhadata  if "IdxPoints:" in x  ]
numhapoints = len(rawhapoints)
haarclength = writearclength(numhapoints ,rawhapoints ,"%sha.vtk" % sys.argv[1])


getPVPointsCmd = './PathExtraction %spv.nii.gz  %s %d %d %d %d %d %d 2 1' %  (sys.argv[1],sys.argv[2], centroidvox[3][0], centroidvox[3][1], centroidvox[3][2], centroidvox[4][0], centroidvox[4][1], centroidvox[4][2])
print getPVPointsCmd 
pvPointsProcess = subprocess.Popen(getPVPointsCmd ,shell=True,stdout=subprocess.PIPE )
while ( pvPointsProcess.poll() == None ):
   pass
rawpvdata   = [lines.strip('\n') for lines in pvPointsProcess.stdout.readlines()]
rawpvpoints = [eval(x.split("MeshPoints:")[1]) for x in rawpvdata  if "MeshPoints:" in x  ]
rawpvidx    = [eval(x.split("IdxPoints:")[1]) for x in rawpvdata  if "IdxPoints:" in x  ]
numpvpoints = len(rawpvpoints)
pvarclength = writearclength(numpvpoints ,rawpvpoints ,"%spv.vtk" % sys.argv[1])


setupconfig = {'haarclength':haarclength ,'pvarclength':pvarclength ,'outputimage ':sys.argv[1], 'hastart':centroidvox[1], 'haend':centroidvox[2], 'pvstart':centroidvox[3], 'pvend':centroidvox[4]} 
with open(outputjson , 'w') as json_file:
           json.dump(setupconfig , json_file)
