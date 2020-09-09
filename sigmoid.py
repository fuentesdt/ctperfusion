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
  getHeaderCmd = 'c3d -verbose %s -threshold -inf 95%% 1 0  ' % options.imagefile
  print getHeaderCmd
  headerProcess = subprocess.Popen(getHeaderCmd ,shell=True,stdout=subprocess.PIPE )
  while ( headerProcess.poll() == None ):
     pass
  rawthreshinfo = [lines.strip('\n') for lines in headerProcess.stdout.readlines()]
  print rawthreshinfo 
  ninetyfivepercentile = rawthreshinfo[1].split('to')[1]
  getSigmoidCmd = 'c3d  %s -scale -1 -shift %s -scale 1 -exp -shift 1. -reciprocal -o %s ' % (options.imagefile, ninetyfivepercentile , options.outfile)
  print  getSigmoidCmd 
  os.system( getSigmoidCmd )
      
else:
  parser.print_help()
  print options
 
