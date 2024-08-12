#!/bin/bash

cd /DatadiskExt/xpji/data_interp/wap_interp/

output_folder="/DatadiskExt/xpji/data_interp/wap_interp/kelvin_filter_second"

if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

for file in /DatadiskExt/xpji/data_interp/wap_interp/*.nc 



do
    echo "$file."
    filename=$(basename -- "$file")
    filename_no_ext="${filename%.*}"
    ncl_script="/Users/xpji/cmip6_wk/cmip6_model_filter_wap.ncl"
    export infile="/DatadiskExt/xpji/data_interp/wap_interp/$filename"
    export filename="$filename"
    export folderout="$output_folder"
    ncl -Q $ncl_script 


done

echo "All files processed."
