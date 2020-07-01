#!/bin/sh
#
# $Header: odi/src/javadev/odi.release/packaging/odi-oci-stack/buildStack.sh /main/1 2020/05/26 08:15:23 sjayaram Exp $
#
# buildStack.sh
#
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
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
zip -r odi_stack_$1.zip ./*  -x ./buildStack.sh ./main.tf.template ./*.zip 
