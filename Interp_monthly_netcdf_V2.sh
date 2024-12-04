#!/bin/bash

#########################################################################################################################
#                                                                                                                       #
#  ██████╗ ███████╗████████╗██╗  ██╗ █████╗ ██╗     ██╗██████╗ ███████╗███████╗███████╗███╗   ██╗ █████╗                #
#  ██╔══██╗██╔════╝╚══██╔══╝██║  ██║██╔══██╗██║     ██║██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║██╔══██╗               #
#  ██████╔╝█████╗     ██║   ███████║███████║██║     ██║██║  ██║█████╗  █████╗  █████╗  ██╔██╗ ██║███████║               #
#  ██╔══██╗██╔══╝     ██║   ██╔══██║██╔══██║██║     ██║██║  ██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║██╔══██║               #
#  ██████╔╝███████╗   ██║   ██║  ██║██║  ██║███████╗██║██████╔╝███████╗███████╗███████╗██║ ╚████║██║  ██║               #
#  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝               #
#                                                                                                                       #
#########################################################################################################################
#                                                                                                                       #
#  Description: This script is designed to process monthly model data by merging multiple files of the same model,      #
#  selecting data between 1997 and 2014, and interpolating the merged data to a 2x2 degree grid.                        #
#                                                                                                                       #
#  Author: Xianpu Ji                                                                                                    #
#  Email: xianpuji@hhu.edu.cn                                                                                           #
#  Date: 2024/12/04                                                                                                     #
#                                                                                                                       #
#  Instructions:                                                                                                        #
#  1. Make sure to provide the correct input and output directories when running this script.                           #
#  2. The script will automatically search for the relevant data files, merge them, and apply the necessary filters.    #
#  3. The merged data will be output in a 2x2 degree interpolated format.                                               #
#                                                                                                                       #
#########################################################################################################################


# Check input argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <Variable>"
    exit 1
fi

# Input variable from argument
var=$1

# Define directories
input_dir="/Datadisk/CMIP6_daily2/prc/"
output_folder="/Datadisk/CMIP6_daily2/prc/${var}_interp_2x2"
backup_folder="/Datadisk/CMIP6_daily2/prc/${var}_backup"

# Create output and backup directories if they don't exist
mkdir -p "$output_folder" "$backup_folder"

Define the list of models to process
models=("INM-CM4-8" "INM-CM5-0" "IPSL-CM6A-LR" "MPI-ESM1-2-HR")

# Process each model
for model in "${models[@]}"; do
    echo "Processing model ${model}..."

    # Find the files for the current model
    nc_files=($(find "$input_dir" -type f -name "${var}_Amon_${model}*.nc"))

    # Check if there are files to process
    if [ ${#nc_files[@]} -gt 0 ]; then

        filename=$(basename -- "${nc_files[0]}")
        
        prefix=$(echo "$filename" | perl -pe 's/_[0-9]{6}-[0-9]{6}\.nc$//')

        if [ ${#nc_files[@]} -gt 1 ]; then
            echo "Merging multiple files for model ${model}..."

            # Merge files
            cdo mergetime "${nc_files[@]}" "${output_folder}/${prefix}_mergetime.nc"

            # Select the years 1997-2014 and interpolate to 2x2
            cdo -selyear,1997/2014 "${output_folder}/${prefix}_mergetime.nc" "${output_folder}/${prefix}_1997_2014.nc"
            cdo remapcon,r181x90, "${output_folder}/${prefix}_1997_2014.nc" "${output_folder}/${prefix}_1997_2014_interp_2x2.nc"

            # Clean up intermediate files
            rm "${output_folder}/${prefix}_mergetime.nc"

            # Move original files to backup folder
            mv "${nc_files[@]}" "$backup_folder"

        else
            echo "Only one file found for model ${model}, directly processing..."

            # Process single file: select the years 1997-2014 and interpolate
            cdo -selyear,1997/2014 "${nc_files[0]}" "${output_folder}/${prefix}_1997_2014.nc"
            cdo remapcon,r181x90, "${output_folder}/${prefix}_1997_2014.nc" "${output_folder}/${prefix}_1997_2014_interp_2x2.nc"

            # Move original file to backup folder
            mv "${nc_files[0]}" "$backup_folder"
        fi

        # Move processed data to backup folder
        mv "${output_folder}/${prefix}_1997_2014.nc" "$backup_folder"
    else
        echo "No files found for model ${model}. Skipping..."
    fi
done


#========================================================================================================================           
# models=("INM-CM4-8" "INM-CM5-0" "IPSL-CM6A-LR" "MPI-ESM1-2-HR")

# for model in "${models[@]}"; do
#     echo "处理模型 ${model}..."
#     # 查找该模型对应的 .nc 文件
#     nc_files=($(find "$input_dir" -type f -name "${var}_Amon_${model}*.nc"))
#     if [ ${#nc_files[@]} -gt 1 ]; then
#         echo "合并模型 ${model} 的多个文件..."
#         echo "文件列表: ${nc_files[@]}"

#         filename=$(basename -- "${nc_files[0]}")

#         prefix=$(echo "$filename" | perl -pe 's/_[0-9]{6}-[0-9]{6}\.nc$//')

#         echo "$prefix,.....,${output_folder}/${prefix}_mergetime.nc"

#         echo  "${output_folder}/${prefix}_1997_2014.nc"

#         cdo mergetime "${nc_files[@]}" "${output_folder}/${prefix}_mergetime.nc"

#         cdo  -selyear,1997/2014  "${output_folder}/${prefix}_mergetime.nc"  "${output_folder}/${prefix}_1997_2014.nc"

#         cdo  remapcon,r181x90, "${output_folder}/${prefix}_1997_2014.nc"  "${output_folder}/${prefix}_1997_2014_interp_2x2.nc"

#         rm "${output_folder}/${prefix}_mergetime.nc"

#         mv  "${nc_files[@]}" $backup_folder

#         mv  "${output_folder}/${prefix}_1997_2014.nc" $backup_folder    

#     elif [ ${#nc_files[@]} -eq 1 ]; then

#         echo "模型 ${model} 只有一个文件, 直接进行数据切片以及插值..."

#         filename=$(basename -- "${nc_files[0]}")

#         prefix=$(echo "$filename" | perl -pe 's/_[0-9]{6}-[0-9]{6}\.nc$//')

#         cdo  -selyear,1997/2014  "${nc_files[0]}"  "${output_folder}/${prefix}_1997_2014.nc"

#         cdo  remapcon,r181x90, "${output_folder}/${prefix}_1997_2014.nc"  "${output_folder}/${prefix}_1997_2014_interp_2x2.nc"

#         mv  "${nc_files[0]}" $backup_folder

#         mv  "${output_folder}/${prefix}_1997_2014.nc" $backup_folder
#     else
#         echo "模型 ${model} 没有找到文件, 跳过..."

#     fi
    



# done