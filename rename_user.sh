#!/bin/bash
# Rename a User and change home directory

OLD=$1
NEW=$2

# Rename User
usermod -l $NEW $OLD
# Rename Primary Group
groupmod -n $NEW $OLD
# Move Home Directory
usermod -d /home/$NEW -m $NEW
