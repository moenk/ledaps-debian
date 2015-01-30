#!/bin/bash
apt-get install ksh gcc wget automake gfortran make subversion bison flex
apt-get install python python-numpy python-scipy
apt-get install libtiff5-dev libgeotiff-dev libopenjpeg-dev libxml2-dev libhdf5-dev libcurl4-gnutls-dev

cd /opt
wget http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/hdf-4.2.10.tar.gz
tar -xvzf hdf-4.2.10.tar.gz
rm hdf-4.2.10.tar.gz
cd hdf-4.2.10
unset CC
./configure --disable-netcdf
make
make install
cd /opt/hdf-4.2.10/hdf4/include/
cp netcdf.h hdf4_netcdf.h

cd /opt
wget ftp://edhs1.gsfc.nasa.gov/edhs/hdfeos/latest_release/HDF-EOS2.19v1.00.tar.Z
tar -xvzf HDF-EOS2.19v1.00.tar.Z
rm HDF-EOS2.19v1.00.tar.Z
cd hdfeos
export CC=/opt/hdf-4.2.10/hdf4/bin/h4cc
./configure
make
make install

cd /opt
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz
tar -xvzf netcdf-4.3.2.tar.gz
rm netcdf-4.3.2.tar.gz
cd netcdf-4.3.2
unset CC
./configure
make
make install

cd /opt
svn checkout http://espa-common.googlecode.com/svn/releases/version_1.3.1 espa-common
cd espa-common
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
export ESPAINC="/opt/espa-common/src/raw_binary/include/"
export ESPALIB="/opt/espa-common/src/raw_binary/lib/"
export BIN="/usr/bin/"
make
make install
