#!/bin/bash

# where our libs are?
export HDFEOS_GCTPINC="/opt/hdfeos/gctp/include/"
export HDFEOS_GCTPLIB="/opt/hdfeos/gctp/src/.libs/"
export TIFFINC="/usr/include/"
export TIFFLIB="/usr/lib/"
export JPEGINC="/usr/include/"
export JPEGLIB="/usr/lib/"
export GEOTIFF_INC="/usr/include/geotiff/"
export GEOTIFF_LIB="/usr/lib/"
export HDFINC="/opt/hdf-4.2.10/hdf4/include/"
export HDFLIB="/opt/hdf-4.2.10/hdf4/lib/"
export HDFEOS_INC="/opt/hdfeos/include/"
export HDFEOS_LIB="/opt/hdfeos/hdfeos2/lib/"
export XML2INC="/usr/include/libxml2/"
export XML2LIB="/usr/lib/"
export NCDF4INC="/opt/netcdf-4.3.2/include/"
export NCDF4LIB=" /opt/netcdf-4.3.2/lib/"
export ESPAINC="/opt/espa-common/src/raw_binary/include/"
export ESPALIB="/opt/espa-common/src/raw_binary/lib/"
export ESUN="/opt/cfmask/src/"
export BIN="/usr/bin/"

# get ledaps code from google
cd /opt
svn checkout http://ledaps.googlecode.com/svn/releases/version_2.2.1 ledaps
cd ledaps/ledapsSrc/src
make
make install

# get cfmask code and compile
export ESUN="/opt/cfmask/src/"
cd /opt
svn checkout http://cfmask.googlecode.com/svn/cfmask/releases/version_1.4.1 cfmask
cd cfmask/src
make
make install

# get the correction data & tools
export HDF5INC="/opt/hdf-4.2.10/hdf/src/"
cd /opt/ledaps/ledapsAncSrc
make
make install

# update anc data
export LEDAPS_AUX_DIR="/opt/ledaps/ledapsAnc/"
mkdir /opt/ledaps/ledapsAncSrc/
cd /opt/ledaps/ledapsAncSrc/
wget http://espa.cr.usgs.gov/validations/ledaps_auxiliary/ledaps_aux.1978-2014.tar.gz
tar -xvzf ledaps_aux.1978-2014.tar.gz
wget https://ledaps.googlecode.com/files/CMGDEM.hdf.gz
gunzip CMGDEM.hdf.gz
./updatetoms.py --quarterly
./updatencep.py --quarterly

