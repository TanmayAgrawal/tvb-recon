#!/bin/bash

#FLIRT co-registration of volumes with DWI

# Parcellations to co-register should be provided as arguments.
vols=aparc+aseg

pushd $DMR

for vol in $vols
do

    #Not really necessary if we have already created .nii.gz files  with good orientation at the end recon-all:
    #mri_convert $MRI/$vol.mgz $MRI/$vol.nii.gz --out_orientation RAS -rt nearest
    #fslreorient2std $MRI/$vol.nii.gz $MRI/$vol-reo.nii.gz
    #mv $MRI/$vol-reo.nii.gz $MRI/$vol.nii.gz

    if [ "$COREG_USE" = "flirt" ]
    then
        #Apply the transform from T1 to DWI for the volumes
        flirt -applyxfm -in $MRI/$vol.nii.gz -ref ./b0.nii.gz -out ./$vol-in-d.nii.gz -init ./t2d.mat -interp nearestneighbour
    else
        #Apply the transform from T1 to DWI for the volumes
        mri_vol2vol --mov $MRI/$vol.mgz --targ ./b0.nii.gz --o ./$vol-in-d.nii.gz --reg ./t2d.reg --nearest
    fi

    #Visual check (interactive):
    #-mode 2 is the view, you need & to allow more windows to open
    mrview ./b0.nii.gz -overlay.load ./$vol-in-d.nii.gz -overlay.opacity 0.3 -mode 2 &

    #Visual check (screenshot):
    #source $CODE/snapshot.sh use_freeview 2vols ./b0.nii.gz ./$vol-in-d.nii.gz
    python -m $SNAPSHOT --snapshot_name b0-$vol-in_d --ras_transform 2vols ./b0.nii.gz ./$vol-in-d.nii.gz
    #freeview -v ./T1-in-d.nii.gz ./b0.nii.gz:colormap=heat ./$vol-in-d.nii.gz:colormap=jet -ss $FIGS/t1-$vol-in-d.png
    #source $CODE/snapshot.sh use_freeview 3vols ./t1-in-d.nii.gz ./b0.nii.gz ./$vol-in-d.nii.gz
    python -m $SNAPSHOT --snapshot_name b0_t1-$vol-in_d --ras_transform 3vols ./t1-in-d.nii.gz ./b0.nii.gz ./$vol-in-d.nii.gz
done

popd
