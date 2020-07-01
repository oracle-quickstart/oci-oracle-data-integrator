#!/bin/bash
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
#

# Trap for script exit
onComplete() {
  rv=$?
  echo "Oracle Essbase VM initialization finished with error code $rv"
  #sudo rm -rf /tmp/essbase_config.json
}

trap onComplete EXIT
set -e

# Read version file
image_version=`sudo cat /etc/essbase/image_version.txt`
echo Using image ${image_version}

# Update the global env settings
echo Updating the global env settings for this instance
sudo /bin/bash <<EOF
echo 'DOMAIN_HOME=/u01/config/domains/essbase_domain' >> /etc/essbase/env
echo 'ARBORPATH=/u01/data/essbase' >> /etc/essbase/env
EOF

# Wait for 30 minutes for the vm to be prepared and configuration
# to be complete.  This is run as the opc user
timeout 30m /bin/bash -e <<'EOF'

# Wait until flag has been created
echo Waiting for prepare_vm script to complete
until [ -e /tmp/.prepare_vm.completed ]; 
do 
  echo waiting prepare_vm to complete...
  sleep 10
done

rv=$(cat /tmp/.prepare_vm.completed)
if [ "$rv" -ne "0" ]; then
   exit $rv
fi

# Run the configuration script as oracle user
# This is needed to be done to make sure limits are applied
echo Running configuration script as oracle user
exec sudo -i -u oracle /u01/vmtools/configure.sh
EOF

# Run the post configuration script as root
sudo /u01/vmtools/post-configure.sh
