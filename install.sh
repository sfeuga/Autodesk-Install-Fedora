#!/usr/bin/env bash

if [[ $(grep "Fedora 32" /etc/os-release) ]]; then
  echo "Download MotionBuilder installer"
  wget -c http://trial2.autodesk.com/NetSWDLD/2020/MOBPRO/E13820F1-4475-4BA1-B8F5-EEAD1F51C5D0/ESD/Autodesk_MB_2020_ML_Linux64.tgz

  echo "Decompress MotionBuilder installer"
  tar -axvf Autodesk_MB_2020_ML_Linux64.tgz
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
    sudo dnf install -y adlmapps17-17.0.49-0.x86_64.rpm
    sudo dnf install -y adsklicensing9.2.1.2399-0-0.x86_64.rpm
    sudo dnf install -y adlmflexnetclient-17.0.49-0.x86_64.rpm
    sudo rpm -ivh --force MotionBuilder2020_64-2020-1.x86_64.rpm
  )
  if [[ "$?" != "0" ]]; then
    exit 2
  fi

  echo "Do you have a license ? (y/N)"
  read yn
  case $yn in
    [yY] | [yY][Ee][Ss] )
      echo "You can now register your license by running:"
      echo "sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R17/lib64 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/AdskLicensingInstHelper register --prod_key 727L1 --prod_ver 2020.0.0.F --config_file /usr/autodesk/MotionBuilder2020/bin/MotionBuilderConfig.pit --eula_locale EN_US --feature_id MOTIONBUILDER --lic_method STANDALONE --serial_number YOUR-SERIAL-NUMBER --sel_prod_key 727L1"
      ;;
    [nN] | [n|N][O|o] | * )
      wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Autodesk_Maya_2020_ML_Linux_64bit_Hack.zip
      unzip -o Autodesk_Maya_2020_ML_Linux_64bit_Hack.zip
      if [[ -d "CLM_usr" && -d "adsklic" ]]; then
        sudo cp CLM_usr/libadlmint.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/AdskLicensingAgent/lib/
        sudo cp CLM_usr/libadlmint.so.17.0.49 /usr/autodesk/MotionBuilder2020/bin/linux_64/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/Adlm/R17/lib64/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/AdskLicensingAgent/lib/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/

        echo "Register Standalone License"
        sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R17/lib64 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/AdskLicensingInstHelper register --prod_key 727L1 --prod_ver 2020.0.0.F --config_file /usr/autodesk/MotionBuilder2020/bin/MotionBuilderConfig.pit --eula_locale EN_US --feature_id MOTIONBUILDER --lic_method STANDALONE --serial_number 666-69696969 --sel_prod_key 727L1

        echo "##########################################################"
        echo "# Click on \"Enter a serial number\" on the license form #"
        echo "##########################################################"
      fi
      ;;
  esac

  echo "You can now run MotionBuilder \\o/"
fi
