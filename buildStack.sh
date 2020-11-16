#!/bin/sh
#
# $Header: odi/src/javadev/odi.release/packaging/odi-oci-stack/buildStack.sh /main/4 2020/11/08 22:16:41 sjayaram Exp $
#
# buildStack.sh
#
# Copyright (c) 2020, Oracle and/or its affiliates. 
#
#    NAME
#      buildStack.sh - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    sjayaram    05/22/20 - Creation
#
# This script builds the odi oci stack.
# It takes a parameter to decide whether to build a BASIC or ADVANCED stack

# Make sure you do a cleanview before running this command
# Usage : buildStack.sh BASIC


sed "s/<studio_mode>/$1/g" ./main.tf.template >  main.tf
cat outputs.tf.template > outputs.tf
if [ $1 == "BASIC" ]
then
 echo 'output "public_web_studio_url" {
    value = "http://${module.odi.node_public_ip}:9999/odi-web-studio"
}' >> outputs.tf
 echo '' >> outputs.tf
 echo 'output "private_web_studio_url" {
    value = "http://${module.odi.node_private_ip}:9999/odi-web-studio"
}' >> outputs.tf
fi

zip -r odi_stack_$1.zip ./*  -x "./buildStack.sh" "./*.template" "./*.zip" "*/.*" 
