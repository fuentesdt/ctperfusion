import vtk
import math
import subprocess

outputimage =  'test.nii.gz'
getPointsCmd = './PathExtraction %s Processed/0004/hepaticarteryspeed2.nii.gz 272 262 72 174 251 12 2 1 | grep MeshPoints ' % outputimage 
print getPointsCmd 
pointsProcess = subprocess.Popen(getPointsCmd ,shell=True,stdout=subprocess.PIPE )
while ( pointsProcess.poll() == None ):
   pass
rawpoints = [eval(lines.strip('\n').split("MeshPoints:")[1]) for lines in pointsProcess.stdout.readlines()]
numpoints = len(rawpoints)
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
OutputFileName = 'pttest.vtk'
polydatawriter = vtk.vtkDataSetWriter()
polydatawriter.SetFileName(OutputFileName)
polydatawriter.SetInputData(polydata)
polydatawriter.Update()

setupconfig = {'arclength':arclength ,'outputimage ':outputimage } 
setupprereq    = 'setup.json'
with open(setupprereq, 'w') as json_file:
           json.dump(setupconfig , json_file)
