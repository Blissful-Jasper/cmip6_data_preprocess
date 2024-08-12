; Author: Dr. Sandro Lubis (Jan 2020)
;         How to filter CCEW signalsa using kf_filter
;         Lubis, SW, Respati, MR. Impacts of convectively coupled
;         equatorial waves on rainfall extremes in Java, Indonesia.
;         Int J Climatol. 2021; 41: 2418– 2440
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/Users/tfeng/.conda/envs/ncl/lib/ncarg/nclscripts/contrib/kf_filter.ncl"

begin

    smooth = True

    wave = "kelvin"  ; 输入变量 (mjo, kelvin, er, mrg, eig, td)

    print("Reading the input file...")

    infile = getenv("infile")
    filename = getenv("filename")
    folderout = getenv("folderout")

    f = addfile(infile, "r")
    time = f->time
    latN = 25
    latS = -latN

    plev = f->plev 
    lat = f->lat({latS:latN})
    lon = f->lon

    olr = short2flt(f->wap(time|:, plev|:, {lat|latS:latN}, lon|:))

    threshold = 1000
    olr@_FillValue = 1e20

    if (any(isnan_ieee(olr))) then
      replace_ieeenan (olr, olr@_FillValue, 0)
    end if
;   olr = where(olr.gt.threshold, olr@_FillValue, olr)

    guess     = 1

    is_cyclic = True

    nscan     = 1500

    eps       = 1.e-2

    relc      = 0.6

    opt       = 0


    poisson_grid_fill( olr, is_cyclic, guess, nscan, eps, relc, opt)

    print(all(.not.ismissing(olr)))

    printMinMax(olr,False)

    print("Calculating climatology and anomaly...")

    TIME = cd_calendar(time, 0)  ; type float 
    year = toint(TIME(:,0))  ; toint strips meta data
    month = toint(TIME(:,1))
    day = toint(TIME(:,2))

    if (isatt(TIME, "calendar")) then  ; default is gregorian

        year@calendar = TIME@calendar  

    end if

    ddd = day_of_year(year, month, day) 

    if (isatt(year, "calendar")) then  ; default is gregorian
        ddd@calendar = year@calendar  
    end if

    yyyyddd = year * 1000 + ddd  ; needed for input
    if (isatt(ddd, "calendar")) then  ; default is gregorian
        yyyyddd@calendar = ddd@calendar  
    end if
    year_day_size = max(ddd)
    ; 定义climatology和anomaly数组
    climatology = new((/year_day_size, dimsizes(plev), dimsizes(lat), dimsizes(lon)/), float, -999)
    anomaly = new((/dimsizes(time), dimsizes(plev), dimsizes(lat), dimsizes(lon)/), float, -999)

    if (smooth) then
        nhar = 1  ; 只考虑年周期
        do p = 0, (dimsizes(plev) - 1)
            ; 提取当前压力层的切片
            olr_slice = olr(:, p, :, :)
            ; 计算当前切片的climatology
            climday = clmDayTLL(olr_slice, yyyyddd)
            printVarSummary(climday)
            ; 存储当前切片的平滑后的climatology
            climatology(:, p, :, :) = smthClmDayTLL(climday, nhar)
            printVarSummary(climatology(:, p, :, :))
            ; 计算并存储当前切片的anomaly
            anomaly(:, p, :, :) = calcDayAnomTLL(olr_slice, yyyyddd, climatology(:, p, :, :))
            printVarSummary(anomaly(:, p, :, :))
        end do
    else
        do p = 0, (dimsizes(plev) - 1)
            ; 提取当前压力层的切片
            olr_slice = olr(:, p, :, :)
            ; 计算并存储当前切片的climatology
            climatology(:, p, :, :) = clmDayTLL(olr_slice, yyyyddd)
            ; 计算并存储当前切片的anomaly
            anomaly(:, p, :, :) = calcDayAnomTLL(olr_slice, yyyyddd, climatology(:, p, :, :))
        end do
    end if

    print("Filtering...")

    filtered = new((/dimsizes(time), dimsizes(plev), dimsizes(lat), dimsizes(lon)/), float, -999)

    filtered!0 = "time"
    filtered!1 = "plev"
    filtered!2 = "lat"
    filtered!3 = "lon"
    filtered&time = time
    filtered&plev = plev
    filtered&lat = lat
    filtered&lon = lon
    filtered@units = "Pa /s"

    obsPerDay = 1
    mis = -999
    mis@_FillValue = -999
    wave_type = wave

    if (wave.eq."mjo") then
        wavenumber = (/1, 5/)
        period = (/20, 100/)
        depth = (/mis, mis/)
        filtered@long_name = "Madden-Julian Oscillations in Outgoing Longwave Radiation"
    else if (wave.eq."kelvin") then
        wavenumber = (/2, 14/)
        period = (/3, 20/)
        depth = (/8, 90/)
        filtered@long_name = "Kelvin Waves in Precipitation"
    else if (wave.eq."er") then
        wavenumber = (/-10, -1/)
        period = (/9, 72/)
        depth = (/8, 90/)
        filtered@long_name = "Equatorial Rossby Waves in Outgoing Longwave Radiation"
    else if (wave.eq."mrg") then
        wavenumber = (/-10, -1/)
        period = (/3, 10/)
        depth = (/8, 90/)
        filtered@long_name = "Mixed Rossby-Gravity Waves in Outgoing Longwave Radiation"
    else if (wave.eq."eig") then
        wavenumber = (/1, 14/)
        period = (/1, 5/)
        depth = (/12, 50/)
        wave_type = "ig0"
        filtered@long_name = "Eastward Inertio Gravity Waves in Outgoing Longwave Radiation"
    else if (wave.eq."td") then
        wavenumber = (/-20, -6/)
        period = (/2.5, 5/)
        depth = (/mis, 90/)
        wave_type = "td-type"
        filtered@long_name = "Tropical Depression-Type Waves in Outgoing Longwave Radiation"
    end if
    end if
    end if
    end if
    end if
    end if

    do y = 0, (dimsizes(lat) - 1)
        do p = 0, (dimsizes(plev) - 1)
            filtered(:, p, y, :) = kf_filter(anomaly(:, p, y, :), obsPerDay, period(0), period(1), wavenumber(0), wavenumber(1), depth(0), depth(1), wave_type)
        end do
        print((/lat(y)/))
    end do

    printVarSummary(filtered)
    printMinMax(filtered, False)

    print("Opening the output file...")

    g = addfile(folderout + filename + "_" + wave + "_" +  "newtime.nc", "c")

    print("Writing the output file...")

    g->$wave$ = filtered

    print("Closing the output file...")

    delete(g)

end