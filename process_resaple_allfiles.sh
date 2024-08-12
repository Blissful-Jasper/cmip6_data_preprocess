#!/bin/bash

# �������������ļ���
input_dir="/DatadiskExt/xpji/pr_cmip6"
output_dir="${input_dir}/prepocess_1997-2014"


# ��������ļ��У���������ڣ�
mkdir -p "$output_dir"



# ���������ļ����е�����.nc�ļ�
for nc_file in "$input_dir"/*.nc; do
    # ��ȡ�ļ���������·����
    filename=$(basename "$nc_file")
    
    # ��ȡģ������
    model_name=$(echo "$filename" | sed -n 's/.*day_\([A-Za-z0-9-]*\)_historical.*/\1/p')

    
   
    # ��������ļ���
    output_file="$output_dir/${model_name}_1997-2014.nc"

    # �������ļ��Ƿ��Ѿ�����
    if [ -f "$output_file" ]; then
        echo "Output file $output_file already exists, skipping $filename"
    else
        # ����cdo����
        cdo -selyear,1997/2014 -selday,1/30 -delete,month=2,day=29,30 "$nc_file" "$output_file"
        
        # ��������Ƿ�ɹ�
        if [ $? -eq 0 ]; then
            echo "Processed $filename and saved as $output_file"
        else
            echo "Failed to process $filename" >&2
        fi
    fi

done
