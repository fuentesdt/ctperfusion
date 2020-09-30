.mode csv
.import  Processed/0001/ConstantBAT3param/ktrans.csv    lstat
.import  Processed/0001/ConstantBAT3param/fpv.csv       lstat
.import  Processed/0001/ConstantBAT3param/maxslope.csv  lstat
.import  Processed/0001/ConstantBAT3param/ve.csv        lstat
.import  Processed/0002/ConstantBAT3param/ktrans.csv    lstat
.import  Processed/0002/ConstantBAT3param/fpv.csv       lstat
.import  Processed/0002/ConstantBAT3param/maxslope.csv  lstat
.import  Processed/0002/ConstantBAT3param/ve.csv        lstat
.import  Processed/0003/ConstantBAT3param/ktrans.csv    lstat
.import  Processed/0003/ConstantBAT3param/fpv.csv       lstat
.import  Processed/0003/ConstantBAT3param/maxslope.csv  lstat
.import  Processed/0003/ConstantBAT3param/ve.csv        lstat
.import  Processed/0004/ConstantBAT3param/ktrans.csv    lstat
.import  Processed/0004/ConstantBAT3param/fpv.csv       lstat
.import  Processed/0004/ConstantBAT3param/maxslope.csv  lstat
.import  Processed/0004/ConstantBAT3param/ve.csv        lstat
.import  Processed/0001/globalid.csv                    lstat
.import  Processed/0001/meanglobalid.csv                lstat
.import  Processed/0001/meansolution.csv                lstat
.import  Processed/0001/solution.csv                    lstat
.headers on


.output wideformat.csv 
select InstanceUID,LabelID,`Vol.mm.3`,
            max(CASE WHEN SegmentationID = 'ktrans'              THEN Mean ELSE NULL END) ktrans,
            max(CASE WHEN SegmentationID = 'fpv'                 THEN Mean ELSE NULL END) fpv,
            max(CASE WHEN SegmentationID = 've'                  THEN Mean ELSE NULL END) ve,
            max(CASE WHEN SegmentationID = 'maxslope'            THEN Mean ELSE NULL END) maxslope,
            max(CASE WHEN SegmentationID = 'globalid.nii.gz'     THEN Mean ELSE NULL END) globalid,
            max(CASE WHEN SegmentationID = 'meanglobalid.nii.gz' THEN Mean ELSE NULL END) meanglobalid,
            max(CASE WHEN SegmentationID = 'meansolution.nii.gz' THEN Mean ELSE NULL END) meansolution,
            max(CASE WHEN SegmentationID = 'solution.nii.gz'     THEN Mean ELSE NULL END) solution
from lstat
GROUP BY    InstanceUID,LabelID;

.quit
