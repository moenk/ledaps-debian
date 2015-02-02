#!/bin/bash

#
#	file: ledaps-machine.sh
#
#	purpose: do batch processing for landsat scenes on san drive
#
#	coder: moenkemt@geo.hu-berlin.de
#

function do_fmask() {
	export ESUN='/opt/cfmask/src/'
	cfmask --xml=$1.xml --prob=1.0 --cldpix=3 --sdpix=3
}

function do_ldcm() {
	rootdir=$1
	case=$2
	mtlfile=`ls $rootdir$case/*.txt`
	touch .lock
	echo 0 >ldcm.inp
	ls $rootdir$case/*_B?.TIF >>ldcm.inp
	ls $rootdir$case/*_B1?.TIF >>ldcm.inp
	ls $rootdir$case/*_BQA.TIF >>ldcm.inp
	thisyear=`echo $case | cut -c 10-13`
	yearday=`echo $case | cut -c 10-16`
	echo $yearday
	fileanc=`ls /opt/ldcm/LANDSATANC/$thisyear/L8ANC$yearday.hdf_fused`
	echo $fileanc >>ldcm.inp
	mtlfile=`ls $rootdir$case/*.txt`
	rnl=`grep REFLECTIVE_LINES $mtlfile | awk '{print $3}'`
	rnc=`grep REFLECTIVE_SAMPLES $mtlfile | awk '{print $3}'`
	pnl=`grep  PANCHROMATIC_LINES $mtlfile | awk '{print $3}'`
	pnc=`grep PANCHROMATIC_SAMPLES $mtlfile | awk '{print $3}'`
	echo $rnl $rnc $pnl $pnc >>ldcm.inp
	ts=`grep SUN_ELEVATION $mtlfile | awk '{print 90.-$3}'`
	fs=`grep SUN_AZIMUTH $mtlfile | awk '{print $3}'`
	echo $ts $fs >>ldcm.inp
	utmzone=`grep  "UTM_ZONE" $mtlfile | awk '{print $3}'`
	x0=`grep  "CORNER_UL_PROJECTION_X_PRODUCT" $mtlfile | awk '{print $3}'`
	y0=`grep  "CORNER_UL_PROJECTION_Y_PRODUCT" $mtlfile | awk '{print $3}'`
	echo $utmzone 1 1 $y0 $x0 >>ldcm.inp
	cd /opt/ldcm/LDCMDELIVERV1.3/
	./LDCMSR-v1.3 <$rootdir$case/ldcm.inp
	mv correcteddata.hdf $rootdir$case/lndsr.$case.hdf
	cd $rootdir$case
	mv ldcm.inp lndsr.$case.txt
	do_fmask $case
	rm .lock
}

function do_ledaps() {
	export LEDAPS_AUX_DIR="/opt/ledaps/ledapsAnc"
	meta_file=$1
	mtl_ext="_MTL.txt"
	echo "Processing scene $meta_file..."
	touch .lock
	convert_lpgs_to_espa --mtl $meta_file$mtl_ext --xml $meta_file.xml
	lndpm $meta_file.xml
	lndcal lndcal.$meta_file.txt
	lndsr lndsr.$meta_file.txt
	lndsrbm.ksh lndsr.$meta_file.txt
	do_fmask $meta_file
	rm .lock README.GTF LogReport
}

function do_all_archives() {
	cd /home/ledaps
	for landsat in $(ls L*.tar.gz); do
		# unzip first, from now on we are just dealing with .tar
		gunzip $landsat
	done
	for landsat in $(ls L*.tar); do
		echo "Processing scene $landsat..."
		landsatdir=`basename $landsat .tar`
		# untar if not exist
		if [ ! -d $landsatdir ]; then
	    		echo "Creating scene $landsatdir..."
			mkdir $landsatdir
			cd $landsatdir
			tar -xof ../$landsat
			cd ..
		fi
		cd $landsatdir
		# start ledaps if not locked
		ls_prefix=`echo $landsatdir | cut -c 1-3`
		if [ ! -f .lock ]; then
			case "$ls_prefix" in
				# new LC8 with ldcm
        			LC8) do_ldcm /home/ledaps/ $landsatdir &
        			;;
        			# old Landsat with ledaps
                                *) do_ledaps $landsatdir &
                                ;;
                        esac
		fi
		cd ..
	done
}

function get_some_files() {
	cd /home/ledaps
	for landsat in $(ls -tr /san/incoming/L*.tar.gz | head -n $1); do
		echo Getting file $landsat...
		mv $landsat .
	done
}

function store_files() {
	cd /home/ledaps
	for landsatdir in $(find . -name "L*" -type d | cut -c 3-) ; do
		echo "Storing scene $landsatdir..."
		donefile=$landsatdir/lndsr.$landsatdir.hdf.hdr
		ls_path=`echo $landsatdir | cut -c 4-6`
		ls_row=`echo $landsatdir | cut -c 7-9`
		ls_target=/san/outgoing/$ls_path"_"$ls_row		
		if [ ! -f $landsatdir/.lock ]; then
			rm $landsatdir/*.TIF
			rm $landsatdir/lndcal.*
			if [ ! -d $ls_target ]; then
				echo Creating $ls_target...
				mkdir $ls_target
			fi
			echo Moving to $ls_target...
			if [ -d $ls_target/$landsatdir ]; then
				rm $ls_target/$landsatdir -r
			fi
			mkdir $ls_target/$landsatdir
			cp $landsatdir/* $ls_target/$landsatdir/
			rm $landsatdir -r
			rm $landsatdir.tar
		fi		
	done
}


# main

# work dir: /home/ledaps
# input dir: /san/incoming
# output dir: /san/outgoing

#get_some_files 1
#do_all_archives
#store_files
#exit

for ((i=1; i<=64738; i++)); do
	store_files
	numfiles=`ls -tr /home/ledaps/L*.tar | wc -l`
	echo $numfiles "files in process..."
	if [ "$numfiles" -lt "4" ]
	then
		echo "Start..."
		get_some_files 4
		do_all_archives
	fi
	echo "Idle..."
	sleep 180
done
