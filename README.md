# cmip6_data_preprocess code describe

- How to batch process nc data of cmip6


## code 1 ：Interp_monthly_netcdf_V2.sh

usage: sh Interp_monthly_netcdf.sh "pr"

"pr" is the **variable name**, because the netcdf file is named as follows:

**pr**_Amon_IPSL-CM6A-LR_historical_r1i1p1f1_gr_185001-201412.nc

If the netcdf file is named:

**prc**_Amon_IPSL-CM6A-LR_historical_r1i1p1f1_gr_185001-201412.nc

Then change the variable name: **prc**

```bash
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
```

## code 2： pr_interp_monthly_netcdf.sh

This is the first version of Interp_monthly_netcdf_V2.sh. This script is less flexible and more clumsy than Interp_monthly_netcdf_V2.sh.

So it is only used for backup.
