import subprocess
import os

# setup command line parser to control execution
from optparse import OptionParser
parser = OptionParser()
parser.add_option( "--imagefile",
                  action="store", dest="imagefile", default=None,
                  help="FILE containing image info", metavar="FILE")
parser.add_option( "--outfile",
                  action="store", dest="outfile", default=None,
                  help="FILE containing image info", metavar="FILE")
(options, args) = parser.parse_args()


if (options.imagefile != None ):
  rootdir   = '/'.join(options.imagefile.split('/')[0:-1])
  filename  = options.imagefile.split('/').pop()
  # get mean super pixel values
  getHeaderCmd = 'c3d -verbose  %s -split -foreach -pca -endfor' % (options.imagefile)
  print getHeaderCmd
  headerProcess = subprocess.Popen(getHeaderCmd ,shell=True,stdout=subprocess.PIPE )
  while ( headerProcess.poll() == None ):
     pass
  rawinfo = [lines.strip('\n') for lines in headerProcess.stdout.readlines()]
  rawlabels  = [x.split("Mapping range [")[1].split(",")[0] for x in rawinfo  if "Mapping range [" in x  ]
  rawevector = [x.split("Mode 2 eigenvector: ")[1].split(" ") for x in rawinfo  if "Mode 2 eigenvector: " in x  ]
  replacex = ' -replace '
  replacey = ' -replace '
  replacez = ' -replace '
  for idlabel,evectorcomp in zip(rawlabels[1:],rawevector[1:]   ):
      replacex = replacex + '%s %s ' % (idlabel,evectorcomp[0])
      replacey = replacey + '%s %s ' % (idlabel,evectorcomp[1])
      replacez = replacez + '%s %s ' % (idlabel,evectorcomp[2])
  getevectorCMD = 'c3d -verbose  %s %s  %s %s  %s %s -omc %s ' % (options.imagefile,replacex ,options.imagefile,replacey ,options.imagefile,replacez ,options.outfile)
  print getevectorCMD 
  os.system(getevectorCMD )
      
      
else:
  parser.print_help()
  print options
 
