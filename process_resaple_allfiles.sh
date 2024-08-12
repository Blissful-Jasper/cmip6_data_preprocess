#!/bin/bash

# 设置输入和输出文件夹
input_dir="/DatadiskExt/xpji/pr_cmip6"
output_dir="${input_dir}/prepocess_1997-2014"


# 创建输出文件夹（如果不存在）
mkdir -p "$output_dir"



# 遍历输入文件夹中的所有.nc文件
for nc_file in "$input_dir"/*.nc; do
    # 提取文件名（不带路径）
    filename=$(basename "$nc_file")
    
    # 提取模型名称
    model_name=$(echo "$filename" | sed -n 's/.*day_\([A-Za-z0-9-]*\)_historical.*/\1/p')

    
   
    # 构建输出文件名
    output_file="$output_dir/${model_name}_1997-2014.nc"

    # 检查输出文件是否已经存在
    if [ -f "$output_file" ]; then
        echo "Output file $output_file already exists, skipping $filename"
    else
        # 运行cdo命令
        cdo -selyear,1997/2014 -selday,1/30 -delete,month=2,day=29,30 "$nc_file" "$output_file"
        
        # 检查命令是否成功
        if [ $? -eq 0 ]; then
            echo "Processed $filename and saved as $output_file"
        else
            echo "Failed to process $filename" >&2
        fi
    fi

done
