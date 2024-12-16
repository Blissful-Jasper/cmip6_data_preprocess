; Author: Xianpu Ji (Dec 2024)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "/Users/tfeng/.conda/envs/ncl/lib/ncarg/nclscripts/contrib/kf_filter.ncl"

begin
    smooth = True
    folderout = "/Datadisk/CMIP6_daily/pr/stand_pr/prepocess_1997-2014/CCKWs/"


    infile = getenv("infile")
    
        
    print("Processing file: " + infile)

    ; 打开文件
    f = addfile(infile, "r")
    nhar = 3
    ; 文件成功打开，继续处理
    file_name = systemfunc("basename " + infile)
    file_name_no_ext = systemfunc("echo " + file_name + " | sed 's/.nc$//'")
    
    date = cd_calendar(f->time, -2)
    date_start = ind(date.eq.19970101)
    date_end = ind(date.eq.20141231)
    latN = 25
    latS = -latN

    time = f->time
    lat = f->lat({latS:latN})
    lon = f->lon
    
    pr = short2flt(f->pr(time|:, {lat|latS:latN}, lon|:))
    threshold = 500
    pr@_FillValue = 1e20

    ; 如果 pr 包含 NaN，使用填充值替换
    if (any(isnan_ieee(pr))) then
        replace_ieeenan(pr, pr@_FillValue, 0)
    end if

    pr = where(pr.gt.threshold, pr@_FillValue, pr)

    ; 设置参数
    guess     = 1
    is_cyclic = True
    nscan     = 1500
    eps       = 1.e-2
    relc      = 0.6
    opt       = 0

    ; 填充缺失值
    poisson_grid_fill(pr, is_cyclic, guess, nscan, eps, relc, opt)

    ; 计算气候平均值和异常
    climday = onedtond(ndtooned(pr), (/18,358,dimsizes(pr&lat),dimsizes(pr&lon)/))
    climday!0="year"
    climday!1="day"
    climday!2="lat"
    climday!3="lon"
    climday&year = fspan(1, 18, 18)
    climday&day = fspan(1, 358, 358)
    climday&lat = pr&lat
    climday&lon = pr&lon
    climday_day = dim_avg_n_Wrap(climday, 0)
    climatology = smthClmDayTLL(climday_day, nhar)
    clim = new((/18, 358, dimsizes(pr&lat), dimsizes(pr&lon)/), float, -999)

    do i = 0, 17
        clim(i, :, :, :) = climatology
    end do    

    anomaly = climday - clim
    pranomaly = onedtond(ndtooned(anomaly), (/18*358,dimsizes(pr&lat),dimsizes(pr&lon)/))
    pranomaly!0 = "time"
    pranomaly!1 = "lat"
    pranomaly!2 = "lon"
    pranomaly&time = fspan(1, 18*358, 18*358)
    pranomaly&lat = pr&lat
    pranomaly&lon = pr&lon

    ; 开始滤波处理
    filtered = new((/dimsizes(time), dimsizes(lat), dimsizes(lon)/), float, -999)
    filtered!0 = "time"
    filtered!1 = "lat"
    filtered!2 = "lon"
    filtered&time = time
    filtered&lat = lat
    filtered&lon = lon
    filtered@units = "kg m-2 s-1"

    wave = "kelvin"
    wave_type = wave
    wavenumber = (/2, 14/)
    period = (/3, 20/)
    depth = (/8, 90/)
    obsPerDay = 1
    do y = 0, (dimsizes(lat) - 1)
        filtered(time|:, lat|y, lon|:) = kf_filter(pranomaly(time|:, lat|y, lon|:), obsPerDay, period(0), period(1), wavenumber(0), wavenumber(1), depth(0), depth(1), wave_type)
        print((/lat(y)/))
    end do

    ; 输出文件
    g = addfile(folderout+"pr_day_"+file_name_no_ext+"_"+wave+"_"+latN+".nc", "c")
    g->$wave$ = filtered
    delete(g)
    
    
end
