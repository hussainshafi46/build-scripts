#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package        : udpa/go
# Version        : v0.0.0-20191209042840-269d4d468f6f, v0.0.0-20200629203442-efcf912fb354 
# Source repo    : https://github.com/cncf/udpa
# Tested on      : UBI 8.4
# Language       : GO
# Travis-Check   : True
# Script License : Apache License, Version 2 or later
# Maintainer     : Sapana Khemkar <spana.khemkar@ibm.com>/ Balavva Mirji <Balavva.Mirji@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_URL=https://github.com/cncf/udpa
PACKAGE_NAME=udpa
PACKAGE_VERSION=${1:-v0.0.0-20191209042840-269d4d468f6f}

PACKAGE_COMMIT_HASH=`echo $PACKAGE_VERSION | cut -d'-' -f3` 

GO_VERSION=go1.17.5

yum install -y git wget tar make gcc-c++  

#install go
rm -rf /bin/go
wget https://golang.org/dl/$GO_VERSION.linux-ppc64le.tar.gz 
tar -C /bin -xzf $GO_VERSION.linux-ppc64le.tar.gz  
rm -f $GO_VERSION.linux-ppc64le.tar.gz 

#set go path
export PATH=$PATH:/bin/go/bin
export GOPATH=/home/tester/go
mkdir -p /home/tester/go
cd $GOPATH

#clone package
mkdir -p $GOPATH/src/github.com/cncf
cd $GOPATH/src/github.com/cncf
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_COMMIT_HASH

cd go
if ! go mod tidy; then
        echo "------------------$PACKAGE_NAME:dependency_fails-------------------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | GitHub | Fail |  Dependency_Fails"
        exit 1
fi

if ! go install ./...; then
        echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
        exit 1
else
        echo "------------------$PACKAGE_NAME:build_and_install_success-------------------------"
        echo "$PACKAGE_VERSION $PACKAGE_NAME"
        echo "$PACKAGE_NAME  | $PACKAGE_VERSION | GitHub  | Pass |  Install_Success"
        exit 0
fi

# test cases are not available for both versions. Hence skipping test
# go test -v ./...