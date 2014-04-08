# DOCKER-VERSION 0.3.4
FROM    centos

MAINTAINER Charles Nguyen <ctn@umn.edu>

# Install updates and tools
RUN		yum install -y gcc make bison autoconf automake pkgconfig libtool elfutils gcc-c++ flex swig gcc-gfortran tk tk-devel

# Set paths for all software        
# We are setting these early on to reduce the number of layers created. Update these as you update software.
# It does not hurt to specify these too early.

ENV     PATH    /tools/anaconda/bin:$PATH:/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5/bin                                                                      
ENV     LD_LIBRARY_PATH $LD_LIBRARY_PATH:/tools/jpeg-9a/lib:/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5/lib                                                                        

# Install Anaconda Python distribution
# This will build the base director /tools for all following software

# Need to reduce bulk, uninstall all un-needed

RUN		wget http://repo.continuum.io/miniconda/Miniconda-3.3.0-Linux-x86_64.sh && sh Miniconda-3.3.0-Linux-x86_64.sh -b -p /tools/anaconda && rm -f Miniconda-3.3.0-Linux-x86_64.sh
RUN		echo y | conda install numpy scipy bzip2 cmake freeglut freetype pandas psycopg2 readline sqlite sqlalchemy swig zlib
#RUN		wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.1-Linux-x86_64.sh && sh Anaconda-1.9.1-Linux-x86_64.sh -b -p /tools/anaconda && rm -f Anaconda-1.9.1-Linux-x86_64.sh

# Install JPEG-9 libraries
RUN		wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz && tar xvfz jpegsrc.v9a.tar.gz && cd jpeg-9a && ./configure --prefix=/tools/jpeg-9a && make && make install && cd / && rm -rf /jpeg-9a /jpegsrc.v9a.tar.gz

# Install Python Imaging Library
RUN		wget http://effbot.org/downloads/Imaging-1.1.7.tar.gz && tar xvfz Imaging-1.1.7.tar.gz && cd Imaging-1.1.7 && sed -i 's/JPEG_ROOT = None/JPEG_ROOT = \("\/tools\/jpeg-9a"\)/g' setup.py && python setup.py build && python setup.py install && cd / && rm -rf Imaging-1.1.7 Imaging-1.1.7.tar.gz

# Python EPSG
# CFITSIO
# GEOS
# PROJ
# OPENJPEG
# FileGDB
# GDAL
# SET GDAL_DATA PATH

# Install Ames Stereo Pipeline
RUN     wget http://byss.ndc.nasa.gov/stereopipeline/binaries/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && tar xvfj StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && rm StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2

# Exeute test
#ENTRYPOINT	["/STHbench.sh"]
