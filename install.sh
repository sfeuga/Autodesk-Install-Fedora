#!/usr/bin/env bash

if [[ $(grep "Fedora 32" /etc/os-release) ]]; then
  echo "Download Maya, Bifrost and BonusTools installers"
  wget -c http://trial2.autodesk.com/NetSWDLD/2020/MAYA/BB8314BA-8DE1-45E4-B827-79F63158212E/ESD/Autodesk_Maya_2020_ML_Linux_64bit.tgz
  if [[ "$?" != "0" ]]; then
    wget -c https://gitlab.com/sfeuga/autodesk-maya-trials/-/raw/master/Autodesk_Maya_2020_ML_Linux_64bit.tgz
  fi
  if [[ ! -f "Packages/Bifrost2020-2.1.0.0-1.x86_64.rpm" && ! -f "Bifrost2020-2.1.0.0-1.x86_64.rpm" ]]; then
    wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Bifrost2020-2.1.0.0-1.x86_64.rpm
  fi
  if [[ ! -f "Packages/MayaBonusTools-2017-2020-linux.sh" && ! -f "MayaBonusTools-2017-2020-linux.sh" ]]; then
    wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/MayaBonusTools-2017-2020-linux.sh
  fi
  if [[ ! -f "Packages/MtoA-4.0.4-linux-2020.run" && ! -f "MtoA-4.0.4-linux-2020.run" ]]; then
    wget -c https://gitlab.com/sfeuga/autodesk-arnold-trials/-/raw/master/MtoA-4.0.4-linux-2020.run
  fi

  echo "Decompress Maya installer"
  tar -axvf Autodesk_Maya_2020_ML_Linux_64bit.tgz
  if [[ ! "$?" == 0 ]]; then
    echo "Install failed, nothing to install"
    exit 2
  fi

  if [[ ! -f "Packages/Bifrost2020-2.1.0.0-1.x86_64.rpm" ]]; then
    mv Bifrost2020-2.1.0.0-1.x86_64.rpm Packages/
  fi
  if [[ ! -f "Packages/MayaBonusTools-2017-2020-linux.sh" ]]; then
    mv MayaBonusTools-2017-2020-linux.sh Packages/
  fi
  if [[ ! -f "Packages/MtoA-4.0.4-linux-2020.run" ]]; then
    mv MtoA-4.0.4-linux-2020.run Packages/
  fi

  (
    cd Packages

    echo "Fix Autodesk scripts"
    sed -i 's/print "Installing CLM Licensing Components...."/print ("Installing CLM Licensing Components....")/' unix_installer.py
    sed -i 's/cd $ABSDIR/cd "$ABSDIR"/' unix_installer.sh
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
    sudo dnf install -y adlmapps17-17.0.49-0.x86_64.rpm
    sudo dnf install -y Maya2020_64-2020.0-235.x86_64.rpm
    sudo dnf install -y adsklicensing9.2.1.2399-0-0.x86_64.rpm
    sudo dnf install -y adlmflexnetclient-17.0.49-0.x86_64.rpm

    echo "Install Bifrost, Substance, Arnold & Maya BonusTools"
    sudo dnf install -y Substance_in_Maya-2020-2.0.3-1.el7.x86_64.rpm
    if [[ -f "Bifrost2020-2.1.0.0-1.x86_64.rpm" ]]; then
      sudo dnf install -y Bifrost2020-2.1.0.0-1.x86_64.rpm
    else
      sudo dnf install -y Bifrost2020-2.0.3.0-1.x86_64.rpm
    fi
    sudo chmod a+x ./unix_installer.sh && sudo ./unix_installer.sh
    if [[ -f "MtoA-4.0.4-linux-2020.run" ]]; then
      chmod a+x MtoA-4.0.4-linux-2020.run
      sudo ./MtoA-4.0.4-linux-2020.run
    fi

    if [[ -f "MayaBonusTools-2017-2020-linux.sh" ]]; then
      echo "Install Maya BonusTools"
      chmod a+x MayaBonusTools-2017-2020-linux.sh
      sudo ./MayaBonusTools-2017-2020-linux.sh
    fi
  )
  if [[ "$?" != "0" ]]; then
    exit 2
  fi

  sudo cp /usr/autodesk/maya2020/desktop/Autodesk-Maya.desktop /usr/share/applications/Autodesk-Maya2020.desktop
  sudo sed -i 's|autodesk/maya|autodesk/maya2020|g' /usr/share/applications/Autodesk-Maya2020.desktop
  sudo rm /usr/share/applications/Autodesk-Maya.desktop

  echo "Do you have a license ? (y/N)"
  read yn
  case $yn in
    [yY] | [yY][Ee][Ss] )
      echo "You can now register your license by running:"
      echo "sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R17/lib64 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/AdskLicensingInstHelper register --prod_key 657L1 --prod_ver 2020.0.0.F --config_file /var/opt/Autodesk/Adlm/Maya2020/MayaConfig.pit --eula_locale EN_US --feature_id MAYA --lic_method STANDALONE --serial_number YOUR-SERIAL-NUMBER --sel_prod_key 657L1"
      ;;
    [nN] | [n|N][O|o] | * )
      wget -c https://gitlab.com/sfeuga/pif/-/raw/master/Sources/Autodesk_Maya_2020_ML_Linux_64bit_Hack.zip
      unzip -o Autodesk_Maya_2020_ML_Linux_64bit_Hack.zip
      if [[ -d "CLM_usr" && -d "adsklic" ]]; then
        sudo cp CLM_usr/libadlmint.so.17.0.49 /opt/Autodesk/Adlm/R17/lib64/
        sudo cp CLM_usr/libadlmint.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/AdskLicensingAgent/lib/
        sudo cp CLM_usr/libadlmint.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/
        sudo cp CLM_usr/libadlmint.so.17.0.49 /usr/autodesk/maya2020/lib/
        sudo cp adsklic/libadlmutil.so.17.0.49 /opt/Autodesk/AdskLicensing/9.2.1.2399/AdskLicensingAgent/lib/
        sudo cp adsklic/libadlmutil.so.17.0.49 /usr/autodesk/maya2020/lib/

        echo "Register Standalone License"
        sudo LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R17/lib64 /opt/Autodesk/AdskLicensing/9.2.1.2399/helper/AdskLicensingInstHelper register --prod_key 657L1 --prod_ver 2020.0.0.F --config_file /var/opt/Autodesk/Adlm/Maya2020/MayaConfig.pit --eula_locale EN_US --feature_id MAYA --lic_method STANDALONE --serial_number 666-69696969 --sel_prod_key 657L1
      fi
      ;;
  esac

  mkdir -p ~/maya/2020
  echo -e "MAYA_DISABLE_CIP=1\nMAYA_DISABLE_CER=1\nLC_ALL=C\nMAYA_CM_DISABLE_ERROR_POPUPS=1\nMAYA_COLOR_MGT_NO_LOGGING=1" > ~/maya/2020/Maya.env

  echo "You can now run Maya \\o/"
fi
