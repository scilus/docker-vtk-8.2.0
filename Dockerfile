FROM ubuntu:bionic

ENV MESA=mesa-19.0.8.tar.gz
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

WORKDIR /mesa-src/mesa-19.0.8
RUN apt install -y xorg-dev
RUN apt install -y llvm-7 llvm-7-dev llvm-7-runtime
RUN ./configure --prefix=/usr/ --enable-autotools                   \
                  --enable-opengl --disable-gles1 --disable-gles2   \
                  --disable-va --disable-xvmc --disable-vdpau       \
                  --enable-shared-glapi                             \
                  --disable-texture-float                           \
                  --enable-gallium-llvm --enable-llvm-shared-libs   \
                  --with-gallium-drivers=swrast,swr                 \
                  --disable-dri --with-dri-drivers=                 \
                  --disable-egl --with-egl-platforms= --disable-gbm \
                  --disable-glx                                     \
                  --disable-osmesa --enable-gallium-osmesa --with-llvm-prefix=/usr/lib/llvm-7
RUN make -j 10
RUN make install

WORKDIR /VTK-build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DVTK_WRAP_PYTHON=ON -DVTK_USE_X=OFF -DBUILD_SHARED_LIBS=ON -DVTK_OPENGL_HAS_OSMESA=ON -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON -DOPENGL_gl_LIBRARY=/usr/lib/libglapi.so -DOSMESA_INCLUDE_DIR=/usr/include/ -DOSMESA_LIBRARY=/usr/lib/libOSMesa.so -DCMAKE_INSTALL_PREFIX=/usr/ ../VTK-src/VTK*
RUN make -j 8
RUN make install

ENV PYTHONPATH=/usr/lib/x86_64-linux-gnu/python3.6/site-packages/:/usr/bin/
ENV LD_LIBRARY_PATH=/usr/bin/
