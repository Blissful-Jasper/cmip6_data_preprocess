#!/bin/bash

cd /Datadisk/CMIP6_daily2/prc/

output_folder="/Datadisk/CMIP6_daily2/prc/pr_interp_2x2"

if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

for file in /Datadisk/CMIP6_daily2/prc/*.nc 
    do
        echo "$file"
        filename=$(basename -- "$file")
        prefix=$(echo "$filename" | perl -pe 's/_[0-9]{6}-[0-9]{6}\.nc$//')
        echo "$prefix"
        
        # filename_no_ext="${filename%.*}"

        cdo  -selyear,1997/2014  $file $output_folder/$prefix"_1997_2014.nc"

        
    done

cd $output_folder

for file in /Datadisk/CMIP6_daily2/prc/pr_interp_2x2/*.nc 
    do
        echo "$file"
        filename=$(basename -- "$file")
        
        filename_no_ext="${filename%.*}"

        cdo  remapcon,r181x90, $file $output_folder/$filename_no_ext"_interp_2x2.nc"

        rm $file        
    done

# cdo remapcon,r181x90 $output_folder/$filename_no_ext"_1997_2014.nc" $output_folder/$filename_no_ext"_1997_2014.nc"