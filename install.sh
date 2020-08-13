#!/usr/bin/env bash

if [[ $(grep "Fedora 32" /etc/os-release) ]]; then
  echo "Download MotionBuilder"
  wget -c https://trial2.autodesk.com/NetSWDLD/2019/MOBPRO/879C76CA-50E6-4DB9-0029-4D40DE4B2256/ESD/Autodesk_MotionBuilder_2019_Linux64.tgz

  echo "Decompress MotionBuilder installer"
  tar -axvf Autodesk_MotionBuilder_2019_Linux64.tgz
  if [[ ! "$?" == 0 ]]; then
    echo "Install failed, nothing to install"
    exit 2
  fi

  (
    echo "Install missings components"
    sudo dnf install -y audiofile audiofile-devel compat-openssl10 e2fsprogs-libs gamin glibc \
      liberation-fonts-common liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts \
      libICE libpng12 libpng15 libSM libtiff libX11 libXau libxcb libXext libXi libXinerama libXmu \
      libXp libXt mesa-libGLU mesa-libGLw pcre-utf16 redhat-lsb tcsh xorg-x11-fonts-ISO8859-1-100dpi \
      xorg-x11-fonts-ISO8859-1-75dpi zlib openal-soft

    echo "Install MotionBuilder & license utils"
    sudo dnf install -y adlmapps15-15.0.72-0.x86_64.rpm
    sudo dnf install -y adlmflexnetclient-15.0.72-0.x86_64.rpm
    sudo rpm -ivh --force MotionBuilder2019_64-2019-1.x86_64.rpm
  )
  if [[ "$?" != "0" ]]; then
    exit 2
  fi

  #echo "Do you have a license ? (y/N)"
  #read yn
  #case $yn in
  #  [yY] | [yY][Ee][Ss] )
  #    echo "You can now register your license by running:"
  #    echo "sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R15/lib64/ /usr/autodesk/MotionBuilder2019/bin/adlmreg -i S 727K1 727K1 2019.0.0.F 666-69696969 /usr/autodesk/MotionBuilder2019/bin/MotionBuilderConfig.pit"
  #    ;;
  #  [nN] | [n|N][O|o] | * )
  #    wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Autodesk_Maya_2019_ML_Linux_64bit_Hack.zip
  #    unzip -o Autodesk_Maya_2019_ML_Linux_64bit_Hack.zip
  #    if [[ -d "CLM" ]]; then
  #      sudo cp CLM/libadlmint.so.14.0.23 /usr/autodesk/mudbox2019/lib

  #      echo "Register Standalone License"
  #      sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R15/lib64/ /usr/autodesk/MotionBuilder2019/bin/adlmreg -i S 727K1 727K1 2019.0.0.F 666-69696969 /usr/autodesk/MotionBuilder2019/bin/MotionBuilderConfig.pit
  #    fi
  #    ;;
  #esac

  echo "You can now run MotionBuilder \\o/"
fi
