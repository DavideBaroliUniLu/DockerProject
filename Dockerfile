FROM quay.io/fenicsproject/stable:2017.1.0.r3
USER root
WORKDIR /tmp

RUN apt-get -qq update && \
    apt-get -y --with-new-pkgs \
    -o Dpkg::Options::="--force-confold" upgrade && \
    apt-get -y install \
    libfltk1.3-dev \
    libfreetype6-dev \
    libgl1-mesa-dev \
    liblapack-dev \
    libxi-dev \
    libxmu-dev \
    mesa-common-dev \
    tcl-dev \
    tk-dev \
    ninja &&\ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY remove-system-libs.py /tmp/remove-system-libs.py

RUN git clone https://github.com/tpaviot/oce.git 

RUN cd oce && \
    git checkout OCE-0.18.1 &&\
    mkdir build &&\
    cd build && \
    cmake  -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DOCE_TESTING=OFF \
        -DOCE_USE_PCH=OFF \
 	-DOCE_COPY_HEADERS_BUILD=ON \
 	-DCMAKE_PREFIX_PATH=$PREFIX \
 	-DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
 	-DOCE_INSTALL_LIB_DIR=lib \
 	-DOCE_INSTALL_BIN_DIR=bin \
 	-DOCE_WITH_FREEIMAGE=ON \
	-DOCE_WITH_GL2PS=OFF \
	-DOCE_WITH_VTK=OFF \
	-DOCE_INSTALL_PREFIX=/usr/local -DOCE_ENABLE_DEB_FLAG=OFF .. &&\
        make  &&\
        make install > installed_files.txt &&\
        python /tmp/remove-system-libs.py /usr/local/OCE.framework/Versions/0.18/Resources/OCE-libraries-release.cmake &&\
    rm -rf /tmp/*
R
USER fenics
WORKDIR /home/fenics
