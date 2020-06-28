import subprocess
import os

# setup command line parser to control execution
from optparse import OptionParser
parser = OptionParser()
parser.add_option( "--imagefile",
                  action="store", dest="imagefile", default=None,
                  help="FILE containing image info", metavar="FILE")
(options, args) = parser.parse_args()


if (options.imagefile != None ):
  rootdir   = '/'.join(options.imagefile.split('/')[0:-1])
  filename  = options.imagefile.split('/').pop()
  slicimage = '%s/slicmask.nii.gz' % rootdir
  getHeaderCmd = 'c3d %s/%s %s/slicmask.nii.gz -lstat  ' % (rootdir ,filename  ,rootdir )
  print getHeaderCmd
  headerProcess = subprocess.Popen(getHeaderCmd ,shell=True,stdout=subprocess.PIPE )
  while ( headerProcess.poll() == None ):
     pass
  rawlstatheader = filter(len,headerProcess.stdout.readline().strip('\n').split(" "))
  rawlstatinfo = [filter(len,lines.strip('\n').split(" ")) for lines in headerProcess.stdout.readlines()]
  labeldictionary =  dict([(int(line[0]),dict(zip(rawlstatheader[1:-1],map(float,line[1:-3])))) for line in rawlstatinfo ])
  replacecmd = 'c3d  %s/slicmask.nii.gz  -replace ' % (rootdir)
  for key, values in labeldictionary.items() :
      print key, values 
      replacecmd = replacecmd + ' %d %f' % (key,values['Mean'])
  replacecmd = replacecmd + ' -o %s/mean%s ' % (rootdir,filename)
  print  replacecmd
  os.system( replacecmd )
      
else:
  parser.print_help()
  print options
 
