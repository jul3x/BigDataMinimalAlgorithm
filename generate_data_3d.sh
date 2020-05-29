#!/bin/bash

range_min_x=-1000
range_max_x=1000
range_min_y=-1000
range_max_y=1000
range_min_z=-1000
range_max_z=1000

records=$1
file_name=$2

if test -f "$file_name"; then
    echo "$file_name exist!"
else
    echo "Processing $1 records..."

    touch $file_name
    echo "index,x,y,z" >> $file_name
    for (( c=1; c<=$records; c++ ))
    do
        x=$(( RANDOM % (range_max_x - range_min_x) + range_min_x ))
        y=$(( RANDOM % (range_max_y - range_min_y) + range_min_y ))
        z=$(( RANDOM % (range_max_z - range_min_z) + range_min_z ))
        printf  "$c,$x,$y,$z\n" >> $file_name
    done
     echo "File $2 generated!"

fi

