#!/usr/bin/env bash

if [[ $(grep "Fedora 32" /etc/os-release) ]]; then
  echo "Download Maya, Bifrost and BonusTools installers"
  wget -c https://trial2.autodesk.com/NetSWDLD/2019/MAYA/EC2C6A7B-1F1B-4522-0054-4FF79B4B73B5/ESD/Autodesk_Maya_2019_Linux_64bit.tgz
  if [[ ! -f "Bifrost2019-2.1.0.0-1.x86_64.rpm" ]]; then
    wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Bifrost2019-2.1.0.0-1.x86_64.rpm
  fi
  if [[ ! -f "MayaBonusTools-2017-2020-linux.sh" ]]; then
    wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/MayaBonusTools-2017-2020-linux.sh
  fi

  echo "Decompress Maya installer"
  tar -axvf Autodesk_Maya_2019_Linux_64bit.tgz
  if [[ ! "$?" == 0 ]]; then
    echo "Install failed, nothing to install"
    exit 2
  fi

  echo "Fix Autodesk scripts"
  sed -i 's/print "Installing CLM Licensing Components...."/print ("Installing CLM Licensing Components....")/' unix_installer.py
  sed -i 's/ silent//' unix_installer.sh

  echo "Install missings components"
  sudo dnf install -y audiofile audiofile-devel compat-openssl10 e2fsprogs-libs gamin glibc \
    liberation-fonts-common liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts \
    libICE libpng12 libpng15 libSM libtiff libX11 libXau libxcb libXext libXi libXinerama libXmu \
    libXp libXt mesa-libGLU mesa-libGLw pcre-utf16 redhat-lsb tcsh xorg-x11-fonts-ISO8859-1-100dpi \
    xorg-x11-fonts-ISO8859-1-75dpi zlib
  if [[ "$?" != "0" ]]; then
    exit 2
  fi

  echo "Install Maya & license utils"
  sudo dnf install -y adlmapps14-14.0.23-0.x86_64.rpm
  sudo dnf install -y Maya2019_64-2019.0-7966.x86_64.rpm
  sudo dnf install -y adlmflexnetclient-14.0.23-0.x86_64.rpm

  echo "Install Bifrost, Substance & Arnold"
  if [[ -f "Bifrost2019-2.1.0.0-1.x86_64.rpm" ]]; then
    sudo dnf install -y Bifrost2019-2.1.0.0-1.x86_64.rpm
  else
    sudo dnf install -y bifrost.rpm
  fi
  sudo chmod a+x SubstanceMaya-1.4.0-2019-Install.sh
  sudo ./SubstanceMaya-1.4.0-2019-Install.sh
  sudo chmod a+x unix_installer.sh
  sudo ./unix_installer.sh

  if [[ -f "MayaBonusTools-2017-2020-linux.sh" ]]; then
    echo "Install Maya BonusTools"
    chmod a+x MayaBonusTools-2017-2020-linux.sh
    sudo ./MayaBonusTools-2017-2020-linux.sh
  fi
  sudo cp /usr/autodesk/maya2019/desktop/Autodesk-Maya.desktop /usr/share/applications/
  sudo sed -i 's|autodesk/maya|autodesk/maya2019|g' /usr/share/applications/Autodesk-Maya.desktop
  sudo rm /usr/share/applications/Autodesk-Maya2016.desktop

  if [[ "$?" != "0" ]]; then
    exit 2
  fi

  echo "Do you have a license ? (y/N)"
  read yn
  case $yn in
    [yY] | [yY][Ee][Ss] )
      echo "You can now register your license by running:"
      echo "sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R14/lib64/ /usr/autodesk/maya2019/bin/adlmreg -i S 657K1 657K1 2019.0.0.F YOUR-SERIAL-NUMBER /var/opt/Autodesk/Adlm/Maya2019/MayaConfig.pit"
      ;;
    [nN] | [n|N][O|o] | * )
      wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Autodesk_Maya_2019_ML_Linux_64bit_Hack.zip
      unzip -o Autodesk_Maya_2019_ML_Linux_64bit_Hack.zip
      if [[ -d "CLM" ]]; then
        sudo mkdir -p /opt/Autodesk/CLM/V{4,5}
        sudo cp CLM/libadlmint.so.14.0.23 /opt/Autodesk/CLM/V5
        sudo cp CLM/libadlmint.so.12.0.32 /opt/Autodesk/CLM/V4
        sudo cp CLM/libadlmint.so.14.0.23 /usr/autodesk/maya2019/lib

        echo "Register Standalone License"
        sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R14/lib64/ /usr/autodesk/maya2019/bin/adlmreg -i S 657K1 657K1 2019.0.0.F 666-69696969 /var/opt/Autodesk/Adlm/Maya2019/MayaConfig.pit
      fi
      ;;
  esac

  mkdir -p ~/maya/2019
  echo -e "MAYA_DISABLE_CIP=1\nMAYA_DISABLE_CER=1\nLC_ALL=C\nMAYA_CM_DISABLE_ERROR_POPUPS=1\nMAYA_COLOR_MGT_NO_LOGGING=1" > ~/maya/2019/Maya.env

  echo "You can now run Maya \\o/"
fi
