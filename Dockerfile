# DOCKER-VERSION 0.3.4
FROM    centos

MAINTAINER Charles Nguyen <ctn@umn.edu>

# Install updates and tools
RUN		yum groupinstall "Development Tools"
#### Install other items. TCL/TK, Freetype

# Set paths for all software        
# We are setting these early on to reduce the number of layers created. Update these as you update software.
# It does not hurt to specify these too early.

ENV     PATH    /tools/anaconda/bin:$PATH:/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5/bin                                                                      
ENV     LD_LIBRARY_PATH $LD_LIBRARY_PATH:/tools/jpeg-9a/lib:/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5/lib                                                                        

# Install Anaconda Python distribution
# This will build the base director /tools for all following software

RUN		wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.9.1-Linux-x86_64.sh && sh Anaconda-1.9.1-Linux-x86_64.sh -b -p /tools/anaconda && rm -f Anaconda-1.9.1-Linux-x86_64.sh

# Install JPEG-9 libraries
RUN		wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz && tar xvfz jpegsrc.v9a.tar.gz && cd jpeg-9a && ./configure --prefix=/tools/jpeg-9a && make && make install && cd / && rm -rf /jpeg-9a /jpegsrc.v9a.tar.gz

# Install Ames Stereo Pipeline
RUN     wget http://byss.ndc.nasa.gov/stereopipeline/binaries/StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && tar xvfj StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2 && rm StereoPipeline-2.3.0-x86_64-Linux-GLIBC-2.5.tar.bz2

# Exeute test
#ENTRYPOINT	["/STHbench.sh"]
