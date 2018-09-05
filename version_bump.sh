#!/bin/bash

desc_file="DESCRIPTION"
old_line=`grep -E "^Version:" $desc_file`
VERSION_LINE_REGEXP="^Version:[[:space:]]*([^[:space:]].*[^[:space:]])[[:space:]]*$"

version_string=`echo $old_line | sed -r "s/$VERSION_LINE_REGEXP/\1/"`

NB_REGEXP="(0|[0-9][0-9]*)"
VERSION_REGEXP="^($NB_REGEXP)(\.|-)($NB_REGEXP)(\.|-)($NB_REGEXP)$"

x=`echo $version_string | sed -r "s/$VERSION_REGEXP/\1/"`
y=`echo $version_string | sed -r "s/$VERSION_REGEXP/\4/"`
z=`echo $version_string | sed -r "s/$VERSION_REGEXP/\7/"`

z=$((z+1))
action="z->z+1"

new_version_string="$x.$y.$z"
echo "==> $new_version_string ($action)"

new_line="Version: $new_version_string"

sed -i.bak "s/$old_line/$new_line/" "$desc_file"
