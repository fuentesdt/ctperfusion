import vtk
import subprocess
# write vtk points file
def WriteVTKPoints(vtkpoints,OutputFileName):
   # loop over points an store in vtk data structure
   vertices= vtk.vtkCellArray()
   for idpoint in range(vtkpoints.GetNumberOfPoints()-1):
       line = vtk.vtkLine()
       line.GetPointIds().SetId(0, idpoint)
       line.GetPointIds().SetId(1, idpoint+1)
       vertices.InsertNextCell( line ) 

   # set polydata
   polydata = vtk.vtkPolyData()
   polydata.SetPoints(vtkpoints)
   polydata.SetLines( vertices )

   # write to file
   polydatawriter = vtk.vtkDataSetWriter()
   polydatawriter.SetFileName(OutputFileName)
   polydatawriter.SetInputData(polydata)
   polydatawriter.Update()

getPointsCmd = './PathExtraction test.nii.gz Processed/0004/skeleton.nii.gz  272 262 72 174 251 12 | grep MeshPoints '
pointsProcess = subprocess.Popen(getPointsCmd ,shell=True,stdout=subprocess.PIPE )
while ( pointsProcess.poll() == None ):
   pass
rawpoints = [eval(lines.strip('\n').split("MeshPoints:")[1]) for lines in pointsProcess.stdout.readlines()]
numpoints = len(rawpoints)
slicerOrientation   = vtk.vtkPoints()
slicerOrientation.SetNumberOfPoints(numpoints)
for idpoint in range(numpoints):
  slicerOrientation.SetPoint(idpoint,rawpoints[idpoint][   0],rawpoints[idpoint][   1],rawpoints[idpoint][   2] )

WriteVTKPoints(slicerOrientation,'pttest.vtk')
