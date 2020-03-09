# docker build -t pollenm/docker_runner_phoenix_linux .
# docker build -t pollenm/docker_runner_phoenix_linux . && docker-compose up -d && docker exec -it docker_runner_phoenix_linux /bin/bash
# https://gitlab.com/gitlab-org/gitlab-foss/issues/50851
# https://docs.gitlab.com/runner/commands/

FROM ubuntu:19.10
LABEL MAINTENER Pollen Metrology <admin-team@pollen-metrology.com>

# Indispensable sinon l'installation demande de choisir le keyboard
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

# Git
RUN apt-get install -y git

# apt-get install g++
RUN apt-get install -y  build-essential

# openssl
#RUN apt-get install -y openssl
RUN apt-get install -y libssl-dev


# cmake >= 3.16.0
## RUN apt-get install -y cmake 3.16.4
RUN git clone --quiet --recurse-submodules --single-branch --branch v3.16.4 https://gitlab.kitware.com/cmake/cmake.git /tmp/cmake && cd /tmp/cmake && /tmp/cmake/bootstrap --no-qt-gui --parallel=$(nproc) --prefix=/usr/local && make -j $(nproc) && make -j $(nproc) install && cd /
#RUN git clone --recurse-submodules --single-branch --branch v3.16.4 https://gitlab.kitware.com/cmake/cmake.git /tmp/cmake &&\
# /tmp/cmake/bootstrap --no-qt-gui --parallel=$(nproc) --prefix=/usr/local &&\
# /tmp/make -j $(nproc) &&\
# /tmp/make -j $(nproc) install

# Python 3.7"
RUN apt-get install -y python 3.7
RUN apt-get install -y python-dev 3.7
RUN apt-get install -y python3-pip

# LLVM/Clang (>= 9.0.0)
RUN apt-get install -y llvm
RUN apt-get install -y clang

# gcc > 9
# already installed

# Mingw 64 bits
RUN apt-get install -y gcc-mingw-w64

# vcpkg
# https://blog.impulsebyingeniance.io/vcpkg/
RUN git clone https://github.com/Microsoft/vcpkg /vcpkg
##RUN cd /vcpkg
RUN /vcpkg/./bootstrap-vcpkg.sh     
RUN /vcpkg/./vcpkg integrate install
RUN /vcpkg/./vcpkg install --triplet x64-linux --clean-after-build eigen3 gtest boost-stacktrace boost-iostreams boost-core boost-math boost-random boost-format boost-crc opencv3[core,contrib,tiff,png,jpeg] 
##vxl (1.8) 
RUN cd /vcpkg && git checkout --quiet 411b4cc && /vcpkg/./vcpkg install --triplet x64-linux --clean-after-build vxl 
RUN cd /

RUN apt-get install -y clang-format clang-tidy clang-tools

RUN apt-get install -y cppcheck

RUN pip3 install pylint

RUN pip3 install mypy

RUN apt-get install -y doxygen

RUN apt-get install -y graphviz

RUN pip3 install sphinx

RUN apt-get install -y gcovr

#RUN apt-get install -y lcov
# https://github.com/linux-test-project/lcov
RUN git clone -b master --single-branch https://github.com/linux-test-project/lcov.git /tmp/lcov && cd /tmp/lcov && make install PREFIX=/usr/local && cd /
#RUN make install PREFIX=/usr/local


# valgrind (>= 3.15.0)
RUN apt-get install -y valgrind

RUN pip3 install pytest-benchmark

RUN pip3 install conan

# cpack
# already installed

RUN pip3 install setuptools

#RUN apt-get install -y texlive-base
RUN apt-get install -y texlive-base

# Jupiter ?

# download and compile phoenix
# git clone --recurse-submodule https://gitlab.com/pollen-metrology/phoenix-group/Phoenix.git /tmp/Phoenix
# git clone --recurse-submodule git@gitlab.com:pollen-metrology/phoenix-group/Phoenix.git /tmp/Phoenix
# cd Phoenix
# mkdir phoenix_build
# cd phoenix_build
# rm -rf
# cmake -DVCPKG_TARGET_TRIPLET=x64-linux -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake ../tools/alternative_build/
# ou
# /usr/local/bin/cmake -DVCPKG_TARGET_TRIPLET=x64-linux -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake ../tools/alternative_build/
# make -j $(nproc)



# A FAIRE
## git clone pollenData
#RUN git clone -b master --single-branch git@gitlab.com:pollen-metrology/PollenData.git /tmp/PollenData

# CLANG - Linux
# cd phoenig_build_clang
# /usr/local/bin/cmake -DVCPKG_TARGET_TRIPLET=x64-linux -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake ../tools/alternative_build/ -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang
# make

# VARIABLES
# cmake -L . | grep PHOENIX

# ARTIFACT : https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html

# GITLAB-RUNNER
RUN apt-get install -y vim curl gitlab-runner

COPY run.sh /
RUN chmod 755 /run.sh

ENTRYPOINT ["/./run.sh", "-D", "FOREGROUND"]