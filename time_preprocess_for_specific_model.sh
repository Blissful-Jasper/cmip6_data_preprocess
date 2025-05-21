#!/bin/bash


cd /DatadiskExt/xpji/2077_2094_interp/ta/sametime/

output_folder="/DatadiskExt/xpji/2077_2094_interp/ta/sametime/"

if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

models=(
   "ACCESS-CM2"
   "NorESM2-MM"
   "KACE-1-0-G"
)

for file in *.nc; do
    filename=$(basename -- "$file")
    filename_no_ext="${filename%.*}"

    # 检查 filename 是否包含 models 中的任一模型名
    matched=false
    for model in "${models[@]}"; do
        if [[ "$filename" == *"$model"* ]]; then
            matched=true
            break
        fi
    done

    if [ "$matched" = true ]; then
        echo "Deal with $filename"
        
        cdo -selday,1/30 "$file" "tmp1.nc"
        cdo -delete,month=2,day=29,30 "tmp1.nc" "$output_folder/${filename_no_ext}.nc"
        rm -f "tmp1.nc"
    else
        echo "Skip $filename (not in model list)"
    fi
done

echo "All files processed."
