FROM nvidia/cuda:8.0-cudnn5-devel

RUN apt update && \
    apt upgrade -y

RUN apt install -y \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev  \
    libboost-test-dev  \
    libboost-serialization-dev  \
    libboost-regex-dev \
    libboost-program-options-dev \
    git  \
    mercurial  \
    autotools-dev \
    dh-autoreconf \
    cmake

ENV EIGEN_PATH /usr/local/include/eigen
ENV DYNET_PATH /usr/local/src/dynet
ENV CUDA_PATH /usr/local/cuda
ENV NMTKIT_PATH /usr/local/src/nmtkit

WORKDIR /usr/local/include
RUN hg clone https://bitbucket.org/eigen/eigen/ $EIGEN_PATH

ENV DYNET_SHA1 b154988b4b813056a2056ded3facc4a3dbcfcff7
WORKDIR /usr/local/src/
RUN git clone https://github.com/clab/dynet.git $DYNET_PATH && \
    cd $DYNET_PATH && \
    mkdir build && cd build && \
    cmake .. -DEIGEN3_INCLUDE_DIR=/usr/local/include/eigen/ -DBACKEND=cuda && \
    make -j 8 && \
    make install && \
    ldconfig

RUN git clone https://github.com/odanado/nmtkit.git $NMTKIT_PATH && \
    cd $NMTKIT_PATH && \
    git checkout -b remove-dynetcuda remotes/origin/remove-dynetcuda && \
    cd $NMTKIT_PATH && \
    git submodule init && \
    git submodule update && \
    autoreconf -i && \
    ./configure --with-eigen=$EIGEN_PATH --with-dynet=$DYNET_PATH --with-cuda=$CUDA_PATH && \
    make -j 8

