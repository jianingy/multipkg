#!/bin/bash

multipkg=$(which multipkg)

if [ -z "$multipkg" ]; then
  cp -v source/lib/Seco/Multipkg.pm Multipkg.pm.orig

  echo "Installing buildrequires. It may require sudo privileges."

  if which yum; then
    sudo yum groupinstall -y 'Development Tools'
    sudo yum install -y perl-YAML-Syck perl-ExtUtils-MakeMaker
    rm -v -f multipkg-*.rpm
  elif which dpkg; then
    sudo apt-get -y install build-essential libyaml-syck-perl libsvn-perl libjson-perl libfile-fnmatch-perl
    rm -v -f multipkg_*.deb
  fi

  PREFIX=./root PKGVERID=0 INSTALLDIR=source scripts/transform
  perl -I ./source/lib root/usr/bin/multipkg -t .

  if which yum; then
    sudo yum install -y multipkg-*rpm
    rm -v multipkg-*rpm
  elif which dpkg; then
    sudo dpkg -i multipkg_*deb
    rm -v multipkg_*deb
  fi

  unset PREFIX PKGVERID INSTALLDIR
  mv -v Multipkg.pm.orig source/lib/Seco/Multipkg.pm

fi

multipkg -t .

# remove temporarily installed multipkg
if [ -z "$multipkg" ]; then
  if which yum; then
    sudo yum remove -y multipkg
  elif which dpkg; then
    sudo dpkg -P multipkg
  fi
fi
echo ======================
echo == package build ok ==
echo ======================
ls -alh multipkg*
