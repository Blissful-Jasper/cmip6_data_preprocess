#!/bin/bash

# 定义路径和目标目录
data_dir="/DatadiskExt/CMIP6/historical/ua/"
output_dir="/DatadiskExt/xpji/CMIP6_monthly_interp_jxp/"

# 创建目标目录，如果不存在
mkdir -p "$output_dir"

# 查找所有的模型和实验配置组合
models=$(ls $data_dir | awk -F_ '{print $3"_historical_"$5}' | sort | uniq)

for model in $models; do
    # 获取当前模型和实验配置的所有文件
    files=$(ls $data_dir*${model}*.nc)
    echo "$files"
    # 定义临时文件名称
    temp_file="${output_dir}${model}_merged.nc"
    interpolated_file="${output_dir}${model}_1997-2014_interpolated.nc"
    if [ -f "$interpolated_file" ]; then
        echo "Interpolated file $interpolated_file already exists, skipping..."
        continue
    fi
    # 合并文件
    cdo mergetime $files $temp_file
    
    # 检查文件是否包含1997-2014的数据
    if cdo -showdate $temp_file | grep -q "1997"; then
        echo "Processing $temp_file for model $model"
        
        # 截取时间范围为1997-2014的数据
        cdo  -selyear,1997/2014 $temp_file "${output_dir}${model}_1997-2014.nc"
        
        # 使用CDO进行插值
        cdo remapcon,r180x91 "${output_dir}${model}_1997-2014.nc" "${output_dir}${model}_1997-2014_interpolated.nc"
        
        # 删除临时文件
       
        rm "${output_dir}${model}_1997-2014.nc"
    else
        echo "Skipping $temp_file as it does not contain data for 1997-2014"
    fi
done