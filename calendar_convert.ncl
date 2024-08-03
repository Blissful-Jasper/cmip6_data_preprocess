; Author: Jasper (June 2024)
; 日历格式转换
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/Users/tfeng/.conda/envs/ncl/lib/ncarg/nclscripts/contrib/kf_filter.ncl"

begin

	; 定义输入文件夹和输出文件夹路径
	input_dir = "/Datadisk/CMIP6_daily2/pr/"
	output_dir = "/Datadisk/CMIP6_daily2/pr/stand_pr/"

	; 获取输入文件夹中的所有文件名
	files = systemfunc("ls " + input_dir + "*.nc")
	print("Files to be processed: " + files)
	; 循环遍历所有文件
	nfiles = dimsizes(files)
	do i = 0, nfiles-1
		input_file =  files(i)
		base_name = system("basename " + input_file )
		print("base_name to be processed: " + base_name)
		output_file = output_dir +"stand" + base_name

		; 打开 NetCDF 文件
		f = addfile(input_file, "r")

		; 读取时间变量和其属性
		time = f->time
		calendar = time@calendar

		; 打印当前处理的文件名和 calendar 属性
		print("Processing file: " + input_file)
		print("Calendar type: " + calendar)

		; 检查 calendar 是否为 proleptic_gregorian
		if (calendar .eq. "proleptic_gregorian") then
		print("Calendar is proleptic_gregorian. Converting to gregorian using CDO...")

		; 使用系统命令调用 CDO 进行转换
		system("cdo setcalendar,standard " + input_file + " " + output_file)
		print("Conversion complete. Output saved to " + output_file)
		else
		print("Calendar is not proleptic_gregorian. No conversion needed.")
		end if
	end do
end
