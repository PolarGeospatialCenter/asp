# DOCKER-VERSION 0.3.4
FROM    centos

MAINTAINER Charles Nguyen <ctn@umn.edu>

# Install updates and tools
RUN		yum install -y gcc make bison autoconf automake pkgconfig libtool elfutils gcc-c++ flex swig gcc-gfortran \ 
		tk tk-devel libSM  libXext

# Set paths for all software        
# We are setting these early on to reduce the number of layers created. Update these as you update software.
# It does not hurt to specify these too early.

ENV     PATH    /tools/anaconda/bin:/tools/gdal/bin:$PATH:/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5/bin                                                                      
ENV     LD_LIBRARY_PATH $LD_LIBRARY_PATH:/tools/jpeg-9a/lib:/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5/lib                                                                        

# Install MiniConda Python distribution
# This will build the base directory /tools for all following software

RUN		wget http://repo.continuum.io/miniconda/Miniconda-3.3.0-Linux-x86_64.sh && \
		sh Miniconda-3.3.0-Linux-x86_64.sh -b -p /tools/anaconda && \
		rm -f Miniconda-3.3.0-Linux-x86_64.sh
RUN		echo y | conda install numpy scipy bzip2 cmake freeglut freetype pandas psycopg2 readline sqlite sqlalchemy zlib

# Install JPEG-9 libraries
RUN		wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz && \
		tar xvfz jpegsrc.v9a.tar.gz && \
		cd jpeg-9a && \
		./configure --prefix=/tools/jpeg-9a && \
		make && make install && \
		cd / && rm -rf /jpeg-9a /jpegsrc.v9a.tar.gz

# Install Python Imaging Library
RUN		wget http://effbot.org/downloads/Imaging-1.1.7.tar.gz && \
		tar xvfz Imaging-1.1.7.tar.gz && \
		cd Imaging-1.1.7 && \
		sed -i 's/JPEG_ROOT = None/JPEG_ROOT = \("\/tools\/jpeg-9a"\)/g' setup.py && \
		python setup.py build && python setup.py install && \
		cd / && rm -rf Imaging-1.1.7 Imaging-1.1.7.tar.gz

# Install Python EPSG
RUN		wget --no-check-certificate https://pypi.python.org/packages/source/p/python-epsg/python-epsg-0.1.4.tar.gz && \
		tar xvfz python-epsg-0.1.4.tar.gz && \
		cd python-epsg-0.1.4 && \
		python setup.py build && python setup.py install && \
		cd / && rm -rf python-epsg-0.1.4*

# Install CFITSIO
RUN		wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio3360.tar.gz && \
		tar xvfz cfitsio3360.tar.gz && \
		cd cfitsio && \
		./configure --prefix=/tools/cfitsio --enable-sse2 --enable-ssse3 --enable-reentrant && \
		make -j && make install && \
		cd / && rm -rf cfitsio*

# GEOS
RUN		wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2 && \
		tar xvfj geos-3.4.2.tar.bz2 && \
		cd geos-3.4.2 && \
		export SWIG_FEATURES="-I/usr/share/swig/1.3.40/python -I/usr/share/swig/1.3.40" && \
		./configure --prefix=/tools/geos --enable-python && \
		make -j && make install && \
		cd / && rm -rf geos*

# PROJ
RUN		wget http://download.osgeo.org/proj/proj-4.8.0.tar.gz && \
		tar xvfz proj-4.8.0.tar.gz && \
		cd proj-4.8.0 && \
		./configure --prefix=/tools/proj --with-jni=no && \
		make -j && make install && \
		cd / && rm -rf proj*

# OPENJPEG
RUN		wget https://openjpeg.googlecode.com/files/openjpeg-2.0.0-Linux-i386.tar.gz && \
		tar xvfz openjpeg-2.0.0-Linux-i386.tar.gz -C /tools  && \
		rm -rf openjpeg*

# GDAL
# Parallel make will fail due to race conditions. Do not use -j
RUN		wget http://download.osgeo.org/gdal/1.11.0/gdal-1.11.0beta1.tar.gz && \
		tar xvfz gdal-1.11.0beta1.tar.gz && \
		cd gdal-1.11.0beta1 && \
		./configure --prefix=/tools/gdal --with-geos=/tools/geos/bin/geos-config --with-cfitsio=/tools/cfitsio \
		--with-python --with-openjpeg=/tools/openjpeg-2.0.0-Linux-i386 --with-sqlite3=no && \
		make && make install && \
		cd / && rm -rf gdal*

ENV		GDAL_DATA	/tools/gdal/share/gdal

# Install Ames Stereo Pipeline
RUN     wget http://byss.ndc.nasa.gov/stereopipeline/binaries/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && \
		tar xvfj StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && \
		rm StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2

