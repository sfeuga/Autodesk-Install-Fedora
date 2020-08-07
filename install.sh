#!/usr/bin/env bash

if [[ $(grep "Fedora 32" /etc/os-release) ]]; then
  echo "Download Mudbox installer"
  wget -c http://trial2.autodesk.com/NetSWDLD/2020/MBXPRO/506354E9-5590-41EC-BDC8-419F4BB0DCDF/ESD/Autodesk_Mudbox_2020_ML_Linux64.tgz

  echo "Decompress Mudbox installer"
  tar -axvf Autodesk_Mudbox_2020_ML_Linux64.tgz
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
      xorg-x11-fonts-ISO8859-1-75dpi zlib

    echo "Install Mudbox & license utils"
    sudo dnf install -y adlmapps17-17.0.49-0.x86_64.rpm
    sudo dnf install -y adsklicensing9.2.1.2399-0-0.x86_64.rpm
    sudo dnf install -y adlmflexnetclient-17.0.49-0.x86_64.rpm
    sudo rpm -ivh --force Mudbox2020_64-2020-23.x86_64.rpm
  )
  if [[ "$?" != "0" ]]; then
    exit 2
  fi

  echo "Do you have a license ? (y/N)"
  read yn
  case $yn in
    [yY] | [yY][Ee][Ss] )
      echo "You can now register your license by running:"
      echo "sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R17/lib64 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/AdskLicensingInstHelper register --prod_key 498L1 --prod_ver 2020.0.0.F --config_file /var/opt/Autodesk/Adlm/Mudbox2020/MudboxConfig.pit --eula_locale EN_US --feature_id MUDBOX --lic_method STANDALONE --serial_number YOUR-SERIAL-NUMBER --sel_prod_key 498L1"
      ;;
    [nN] | [n|N][O|o] | * )
      wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Autodesk_Maya_2020_ML_Linux_64bit_Hack.zip
      unzip -o Autodesk_Maya_2020_ML_Linux_64bit_Hack.zip
      if [[ -d "CLM_usr" && -d "adsklic" ]]; then
        sudo cp CLM_usr/libadlmint.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/AdskLicensingAgent/lib/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/Adlm/R17/lib64/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/AdskLicensingAgent/lib/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/

        echo "Register Standalone License"
        sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R17/lib64 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/AdskLicensingInstHelper register --prod_key 498L1 --prod_ver 2020.0.0.F --config_file /var/opt/Autodesk/Adlm/Mudbox2020/MudboxConfig.pit --eula_locale EN_US --feature_id MUDBOX --lic_method STANDALONE --serial_number 666-69696969 --sel_prod_key 498L1

        echo "##########################################################"
        echo "# Click on \"Enter a serial number\" on the license form #"
        echo "##########################################################"
      fi
      ;;
  esac

  echo "You can now run Mudbox \\o/"
fi
