#!/bin/bash


cd /Datadisk/CMIP6_daily/pr/stand_pr/prepocess_1997-2014/prepocess_1997-2014_interp_2x2_v2/ || exit

output_folder="/Datadisk/CMIP6_daily/pr/stand_pr/prepocess_1997-2014/CCKWs/"

if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

for file in /Datadisk/CMIP6_daily/pr/stand_pr/prepocess_1997-2014/prepocess_1997-2014_interp_2x2_v2/*interp_2x2.nc 
# file="/Users/xpji/cmip6_wk/CMIP6_His_nc/GPCP_data_1997-2014.nc"
do
    echo "$file is processing...."
    
    ncl_script="/Datadisk/CMIP6_daily/pr/stand_pr/prepocess_1997-2014/cmip6_model_filter_single.ncl"
    export infile="$file"
    ncl -Q $ncl_script 


done

echo "All files processed."





# cd /Users/xpji/cmip6_wk/test/

# output_folder="/Users/xpji/cmip6_wk/test/kelvin_filter/"

# if [ ! -d "$output_folder" ]; then
#     mkdir -p "$output_folder"
# fi

# for file in /Users/xpji/cmip6_wk/test/GPCP*.nc 



# do
#     echo "$file."
#     filename=$(basename -- "$file")
#     filename_no_ext="${filename%.*}"
#     ncl_script="/Users/xpji/cmip6_wk/cmip6_model_filter.ncl"
#     export infile="/Users/xpji/cmip6_wk/test/$filename"
#     export filename="$filename"
#     export folderout="$output_folder"
#     ncl -Q $ncl_script 


# done

# echo "All files processed."



# cd /DatadiskExt/xpji/data_interp/wap_interp/

# output_folder="/DatadiskExt/xpji/data_interp/wap_interp/kelvin_filter"

# if [ ! -d "$output_folder" ]; then
#     mkdir -p "$output_folder"
# fi

# for file in /DatadiskExt/xpji/data_interp/wap_interp/*.nc 



# do
#     echo "$file."
#     filename=$(basename -- "$file")
#     filename_no_ext="${filename%.*}"
#     ncl_script="/Users/xpji/cmip6_wk/cmip6_model_filter.ncl"
#     export infile="/DatadiskExt/xpji/data_interp/wap_interp/$filename"
#     export filename="$filename"
#     export folderout="$output_folder"
#     ncl -Q $ncl_script 


# done

# echo "All files processed."



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