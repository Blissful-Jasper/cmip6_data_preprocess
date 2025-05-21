#!/bin/bash

# Define input and output directories
SOURCE_DIR="/Datadisk/CMIP6_daily/ua/"
TARGET_DIR="/Datadisk/CMIP6_daily/ua/1997_2014_850hpa_ua/"
INTERP_DIR="/Datadisk/CMIP6_daily/ua/interp_2x2/"
SAMETIME_DIR="/Datadisk/CMIP6_daily/ua/sametime/"

# Create output directories if not already exist
mkdir -p "$TARGET_DIR" "$INTERP_DIR" "$SAMETIME_DIR"

# Whitelisted models (only process files containing these strings)
models=(
  "CAMS-CSM1-0"  "CanESM5" "INM-CM4-8" "INM-CM5-0" "GFDL-CM4" "IPSL-CM6A-LR"
  "MPI-ESM1-2-HR" "CESM2" "HadGEM3-GC31-LL" "MIROC6" "UKESM1-0-LL"
  "NorCPM1" "SAM0-UNICON" "CESM2-WACCM" "EC-Earth3" "GFDL-ESM4"
  "EC-Earth3-Veg" "NorESM2-LM" "MIROC-ES2L" "MRI-ESM2-0" "NESM3"
  "ACCESS-CM2" "ACCESS-ESM1-5" "BCC-CSM2-MR" "BCC-ESM1" "CNRM-CM6-1-HR"
  "AWI-ESM-1-1-LR" "CMCC-CM2-SR5" "CNRM-CM6-1" "CNRM-ESM2-1"
    "FGOALS-f3-L" "FGOALS-g3" "KACE-1-0-G" "MPI-ESM-1-2-HAM" "MPI-ESM-1-2-LR"
    "MPI-ESM-1-2-HR"   "NorESM2-MM" "TaiESM1"
)

# Change to source directory
cd "$SOURCE_DIR" || exit 1

# Loop through NetCDF files
for file in *.nc; do
    filename=$(basename "$file")
    filename_no_ext="${filename%.*}"
    output_file="$TARGET_DIR/${filename_no_ext}_850hpa_1997-2014.nc"
    interp_file="$INTERP_DIR/${filename_no_ext}_850hpa_1997-2014_interp_2x2.nc"
    sametime_file="$SAMETIME_DIR/${filename_no_ext}_850hpa_1997-2014_sametime.nc"
    tmp_file="$INTERP_DIR/tmp1.nc"

    # Check if model is in the whitelist
    matched=false
    for model in "${models[@]}"; do
        if [[ "$filename" == *"$model"* ]]; then
            matched=true
            break
        fi
    done
    if [ "$matched" = false ]; then
        echo "Skipping $filename (model not in whitelist)."
        continue
    fi

    # Skip if already processed
    if [ -f "$output_file" ]; then
        echo "Skipping $filename (already processed)."
        continue
    fi

    # Check if file contains 85000 Pa level
    levels=$(cdo showlevel "$file" 2>/dev/null)
    if [[ "$levels" != *"85000"* ]]; then
        echo "Skipping $filename (no 85000 Pa level found)."
        continue
    fi

    echo "Processing $filename..."

    # Step 1: Select level and years
    cdo -sellevel,85000 -selyear,1997/2014 "$file" "$output_file"
    if [ $? -ne 0 ] || [ ! -s "$output_file" ]; then
        echo "Error: Failed to extract 850hPa or file is empty. Skipping $filename."
        continue
    fi

    # Step 2: Regrid to 2x2
    cdo remapcon,r180x91 "$output_file" "$interp_file"
    if [ $? -ne 0 ]; then
        echo "Error: remapcon failed on $output_file. Skipping."
        continue
    fi

    # Step 3: Extract same days (1–30) and delete Feb 29/30
    cdo -selday,1/30 "$interp_file" "$tmp_file"
    if [ $? -ne 0 ]; then
        echo "Error: selday failed on $interp_file. Skipping."
        continue
    fi

    cdo -delete,month=2,day=29,30 "$tmp_file" "$sametime_file"
    if [ $? -ne 0 ]; then
        echo "Error: delete failed on $tmp_file. Skipping."
        rm -f "$tmp_file"
        continue
    fi
    rm -f "$tmp_file"

    echo "✅ Successfully processed:"
    echo "   ↳ $output_file"
    echo "   ↳ $interp_file"
    echo "   ↳ $sametime_file"

    # Additional time step check
    nt=$(cdo -ntime "$sametime_file")
    echo "   ⏱️ Time steps: $nt"
    if [ "$nt" -lt 6444 ]; then
        echo "   ⚠️ Warning: $sametime_file may be incomplete"
    else
        echo "   ✅ $sametime_file passed completeness check"
    fi

done

echo "🎉 All files processed."
