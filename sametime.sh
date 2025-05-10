#!/bin/bash

cd /DatadiskExt/xpji/2077_2094_interp/

# 
subfolders=( "hus" "tas" "ua" "va" "wap" )

# 
for file in *.nc 
do
    filename=$(basename -- "$file")
    filename_no_ext="${filename%.*}"
    
    echo "Processing $filename"
    
    # 
    varname=$(echo "$filename" | cut -d'_' -f1)
    
    # 
    output_folder="/DatadiskExt/xpji/2077_2094_interp/${varname}/sametime/"
    
    # 
    if [ ! -d "$output_folder" ]; then
        mkdir -p "$output_folder"
    fi

    # 
    cdo -selday,1/30 "$filename" "tmp1.nc"
    
    # 
    cdo -delete,month=2,day=29,30 "tmp1.nc" "$output_folder/${filename_no_ext}_sametime.nc"
    
    # 
    rm -f "tmp1.nc"
    
done

echo "All files processed."
