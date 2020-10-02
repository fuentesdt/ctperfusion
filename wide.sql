.mode csv


.import  Processed/0001/PeakGradient3param/bat.csv        lstat
.import  Processed/0001/PeakGradient3param/bv.csv         lstat
.import  Processed/0002/PeakGradient3param/bat.csv        lstat
.import  Processed/0002/PeakGradient3param/bv.csv         lstat
.import  Processed/0003/PeakGradient3param/bat.csv        lstat
.import  Processed/0003/PeakGradient3param/bv.csv         lstat
.import  Processed/0004/PeakGradient3param/bat.csv        lstat
.import  Processed/0004/PeakGradient3param/bv.csv         lstat
.import  Processed/0001/ConstantBAT3param/diagnostics.csv lstat
.import  Processed/0002/ConstantBAT3param/diagnostics.csv lstat
.import  Processed/0003/ConstantBAT3param/diagnostics.csv lstat
.import  Processed/0004/ConstantBAT3param/diagnostics.csv lstat
.import  Processed/0001/ConstantBAT3param/ktrans.csv      lstat
.import  Processed/0001/ConstantBAT3param/fpv.csv         lstat
.import  Processed/0001/ConstantBAT3param/maxslope.csv    lstat
.import  Processed/0001/ConstantBAT3param/ve.csv          lstat
.import  Processed/0002/ConstantBAT3param/ktrans.csv      lstat
.import  Processed/0002/ConstantBAT3param/fpv.csv         lstat
.import  Processed/0002/ConstantBAT3param/maxslope.csv    lstat
.import  Processed/0002/ConstantBAT3param/ve.csv          lstat
.import  Processed/0003/ConstantBAT3param/ktrans.csv      lstat
.import  Processed/0003/ConstantBAT3param/fpv.csv         lstat
.import  Processed/0003/ConstantBAT3param/maxslope.csv    lstat
.import  Processed/0003/ConstantBAT3param/ve.csv          lstat
.import  Processed/0004/ConstantBAT3param/ktrans.csv      lstat
.import  Processed/0004/ConstantBAT3param/fpv.csv         lstat
.import  Processed/0004/ConstantBAT3param/maxslope.csv    lstat
.import  Processed/0004/ConstantBAT3param/ve.csv          lstat
.import  Processed/0001/meansolution.csv                  lstat
.import  Processed/0001/meanglobalid.csv                  lstat
.import  Processed/0002/meansolution.csv                  lstat
.import  Processed/0002/meanglobalid.csv                  lstat
.import  Processed/0003/meansolution.csv                  lstat
.import  Processed/0003/meanglobalid.csv                  lstat
.import  Processed/0004/meansolution.csv                  lstat
.import  Processed/0004/meanglobalid.csv                  lstat
.import  Processed/0001/G1C4anatomymaskbatsolution.csv    lstat
.import  Processed/0002/G1C4anatomymaskbatsolution.csv    lstat
.import  Processed/0003/G1C4anatomymaskbatsolution.csv    lstat
.import  Processed/0004/G1C4anatomymaskbatsolution.csv    lstat
.import  Processed/0001/G1C4anatomymasksolution.csv       lstat
.import  Processed/0001/G1C4anatomymaskglobalid.csv       lstat
.import  Processed/0001/G1C4anatomymasknccsolution.csv    lstat
.import  Processed/0001/G1C4anatomymasknccglobalid.csv    lstat
.import  Processed/0002/G1C4anatomymasksolution.csv       lstat
.import  Processed/0002/G1C4anatomymaskglobalid.csv       lstat
.import  Processed/0002/G1C4anatomymasknccsolution.csv    lstat
.import  Processed/0002/G1C4anatomymasknccglobalid.csv    lstat
.import  Processed/0003/G1C4anatomymasksolution.csv       lstat
.import  Processed/0003/G1C4anatomymaskglobalid.csv       lstat
.import  Processed/0003/G1C4anatomymasknccsolution.csv    lstat
.import  Processed/0003/G1C4anatomymasknccglobalid.csv    lstat
.import  Processed/0004/G1C4anatomymasksolution.csv       lstat
.import  Processed/0004/G1C4anatomymaskglobalid.csv       lstat
.import  Processed/0004/G1C4anatomymasknccsolution.csv    lstat
.import  Processed/0004/G1C4anatomymasknccglobalid.csv    lstat
.headers on


.output wideformat.csv 
select InstanceUID,LabelID,`Vol.mm.3`,
            max(CASE WHEN SegmentationID = 'ktrans'                            THEN Mean ELSE NULL END) ktrans,
            max(CASE WHEN SegmentationID = 'fpv'                               THEN Mean ELSE NULL END) fpv,
            max(CASE WHEN SegmentationID = 've'                                THEN Mean ELSE NULL END) ve,
            max(CASE WHEN SegmentationID = 'maxslope'                          THEN Mean ELSE NULL END) maxslope,
            max(CASE WHEN SegmentationID = 'diagnostics'                       THEN Mean ELSE NULL END) diagnostics,
            max(CASE WHEN SegmentationID = 'bat'                               THEN Mean ELSE NULL END) bat,
            max(CASE WHEN SegmentationID = 'bv'                                THEN Mean ELSE NULL END) bv,
            max(CASE WHEN SegmentationID = 'meansolution.nii.gz'               THEN Mean ELSE NULL END) meansolution,
            max(CASE WHEN SegmentationID = 'meanglobalid.nii.gz'               THEN Mean ELSE NULL END) meanglobalid,
            max(CASE WHEN SegmentationID = 'G1C4anatomymaskbatsolution.nii.gz' THEN Mean ELSE NULL END) batsolution,
            max(CASE WHEN SegmentationID = 'G1C4anatomymasksolution.nii.gz'    THEN Mean ELSE NULL END) solution,
            max(CASE WHEN SegmentationID = 'G1C4anatomymaskglobalid.nii.gz'    THEN Mean ELSE NULL END) globalid,
            max(CASE WHEN SegmentationID = 'G1C4anatomymasknccsolution.nii.gz' THEN Mean ELSE NULL END) nccsolution,
            max(CASE WHEN SegmentationID = 'G1C4anatomymasknccglobalid.nii.gz' THEN Mean ELSE NULL END) nccglobalid
from lstat
where InstanceUID != 'InstanceUID'
GROUP BY    InstanceUID,LabelID;

.quit
