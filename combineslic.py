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
  getHeaderCmd = 'c3d -verbose %s -split -foreach -centroid -endfor -merge -dup -lstat' % (options.imagefile)
  print getHeaderCmd
  headerProcess = subprocess.Popen(getHeaderCmd ,shell=True,stdout=subprocess.PIPE )
  while ( headerProcess.poll() == None ):
     pass
  rawinfo = [lines.strip('\n') for lines in headerProcess.stdout.readlines()]
  centroidvox = [eval(x.split("CENTROID_VOX")[1]) for x in rawinfo if "CENTROID_VOX" in x]
  headerindex = [i for i,s in enumerate(rawinfo) if 'LabelID' in s ]
  rawlstatheader = filter(len,rawinfo[headerindex[0]] .split(" "))
  rawlstatinfo = [filter(len,lines.split(" ")) for lines in rawinfo[headerindex[0]+1:] ]
  labeldictionary =  dict([(int(line[0]),dict(zip(rawlstatheader[1:-1],map(float,line[1:-3])))) for line in rawlstatinfo ])
  centroiddictionary =  dict([(int(line[0]),mycen) for line,mycen in zip(rawlstatinfo,centroidvox) ])

  labelscentroidlist  = [] 
  for idlabel,labeldata in labeldictionary.items(): 
      if labeldata['Count'] > 100 and idlabel > 0:
         labelscentroidlist.append(  idlabel)
      
      
else:
  parser.print_help()
  print options
 
