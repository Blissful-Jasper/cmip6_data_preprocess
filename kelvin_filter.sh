#!/bin/bash


cd /Datadisk/CMIP6_daily2/pr/stand_pr/

output_folder="/DatadiskExt/xpji/pr_cmip6/kelvin_filter"

if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

for file in /Datadisk/CMIP6_daily2/pr/stand_pr/*.nc 



do
    echo "$file."
    filename=$(basename -- "$file")
    filename_no_ext="${filename%.*}"
    ncl_script="/Users/xpji/cmip6_wk/cmip6_model_filter.ncl"
    export infile="/Datadisk/CMIP6_daily2/pr/stand_pr/$filename"
    export filename="$filename"
    export folderout="$output_folder"
    ncl -Q $ncl_script 


done

echo "All files processed."