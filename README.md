# CMIP6 daily资料的一些前处理脚本


## 批量滤波脚本1：cmip6_model_filter.ncl + kelvin_filter.sh - 降水三维数据

- 对于同一个文件夹内的多个daily的cmip6的nc文件，进行批量滤波
- cmip6_model_filter.ncl & kelvin_filter.sh 结合
- 在shell脚本调用ncl脚本

## 批量滤波脚本2：cmip6_model_filter_wap.ncl + kelvin_filter_wap.sh - 垂直速度四维数据

- 对于同一个文件夹内的多个daily的cmip6的nc文件，进行批量滤波
- cmip6_model_filter_wap.ncl & kelvin_filter_wap.sh 结合
- 在shell脚本调用ncl脚本

## 批量日期格式转换脚本 calendar_convert.ncl

- 对于多个nc文件的日历calendar的格式为proleptic_gregorian，将其利用cdo进行格式转换，转化为standard的标准时间

## 基于python的kf_filter滤波方法：python_wk_filter.py & ma.py - 实现对于赤道波动的滤波 - 以kelvin波进行滤波

- 传入指定的daily的nc文件以及对应的变量名，实现不同尺度波动的滤波
- 需要保证两个py文件在同一个文件夹下
- python_wk_filter.py & ma.py

## 对于cimp6的monthly 资料的批量处理方法：monthly_data_interp.sh
- 实现对于monthly资料的插值、截取时间范围
# 免责声明

本项目中的自动化脚本及相关代码仅供学习和研究使用。使用本项目代码的用户应遵守相关法律法规及目标网站的使用条款。
