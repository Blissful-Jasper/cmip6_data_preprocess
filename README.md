# CMIP6 daily资料的一些前处理脚本


## 批量滤波脚本 ncl + shell

- 对于同一个文件夹内的多个daily的cmip6的nc文件，进行批量滤波
- cmip6_model_filter.ncl & kelvin_filter.sh 结合
- 在shell脚本调用ncl脚本

## 批量日期格式转换脚本 ncl

- 对于多个nc文件的日历calendar的格式为proleptic_gregorian，将其利用cdo进行格式转换，转化为standard的标准时间


# 免责声明

本项目中的自动化脚本及相关代码仅供学习和研究使用。使用本项目代码的用户应遵守相关法律法规及目标网站的使用条款。
