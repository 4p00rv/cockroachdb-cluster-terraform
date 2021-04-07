#!/bin/bash -xe

# Log script output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# update os
# yum update -y

COCKROACH_VERSION="v20.2.7"
ARTIFACT="cockroach-$COCKROACH_VERSION.linux-amd64"

# Download and extract cockroachdb
wget -qO- https://binaries.cockroachdb.com/$ARTIFACT.tgz | tar xvz

# Install
cp -i $ARTIFACT/cockroach /usr/local/bin/

# Directory for external libraries
mkdir -p /usr/local/lib/cockroach

# Add external libraries
cp -i $ARTIFACT/lib/libgeos.so /usr/local/lib/cockroach/
cp -i $ARTIFACT/lib/libgeos_c.so /usr/local/lib/cockroach/

rm -rf $ARTIFACT

# Configure NTP
yum erase 'ntp*'
yum install chrony
service chronyd restart
