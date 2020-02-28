FROM ubuntu:bionic

ENV MESA=mesa-12.0.0.tar.gz
ENV VTK=VTK-8.2.0.tar.gz

RUN rm -rf VTK-src
RUN rm -rf VTK-build
RUN rm -rf mesa-src

RUN mkdir VTK-src
RUN mkdir VTK-build
RUN mkdir mesa-src

COPY $VTK /VTK-src
COPY $MESA /mesa-src

WORKDIR /VTK-src
RUN tar zxvf $VTK
RUN rm $VTK

WORKDIR /mesa-src
RUN tar zxvf $MESA
RUN rm $MESA

RUN sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential git libsm6 libxext6 libxrender-dev python3-dev python3-pip python3-tk python3-lxml python3-six cmake libtool autoconf pkg-config

RUN pip3 install -U pip==9.0.1
ENV PATH=/usr/local/bin/:$PATH
ENV PYTHON_INCLUDE_DIR=/usr/include/python3.6
ENV PYTHON_LIBRARY=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu/libpython3.6.so
RUN pip3 install -U setuptools

WORKDIR /mesa-src/mesa-12.0.0
RUN autoreconf -fi
RUN apt install -y xorg-dev
RUN ./configure CXXFLAGS="-O2 -g -DDEFAULT_SOFTWARE_DEPTH_BITS=31" CFLAGS="-O2 -g -DDEFAULT_SOFTWARE_DEPTH_BITS=31"--disable-xvmc --disable-dri --with-dri-drivers="" --with-gallium-drivers="swrast" --enable-texture-float --disable-egl --with-egl-platforms="" --enable-gallium-osmesa --enable-gallium-llvm=yes --with-llvm-shared-libs --prefix=/usr/
RUN make -j 6
RUN make install

WORKDIR /VTK-build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DVTK_WRAP_PYTHON=ON -DVTK_USE_X=OFF -DBUILD_SHARED_LIBS=ON -DVTK_OPENGL_HAS_OSMESA=ON -DVTK_USE_OFFSCREEN=ON -DOPENGL_gl_LIBRARY=/usr/lib/libglapi.so -DOSMESA_INCLUDE_DIR=/usr/include/ -DOSMESA_LIBRARY=/usr/lib/libOSMesa.so -DCMAKE_INSTALL_PREFIX=/usr/ ../VTK-src/VTK*
RUN make -j 6
RUN make install

ENV PYTHONPATH=/usr/lib/x86_64-linux-gnu/python3.6/site-packages/:/usr/bin/
ENV LD_LIBRARY_PATH=/usr/bin/
