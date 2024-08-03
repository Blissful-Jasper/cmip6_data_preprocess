; Author: Jasper (June 2024)
;         How to filter CCEW signalsa using kf_filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/Users/tfeng/.conda/envs/ncl/lib/ncarg/nclscripts/contrib/kf_filter.ncl"

begin

smooth = True


wave = "kelvin"; input variable (mjo, kelvin, er, mrg, eig, td)

print("Reading the input file...")

infile = getenv("infile")

filename = getenv("filename")

folderout = getenv("folderout")

f = addfile(infile, "r")
;f = addfile(folder + "olr.day.anom.nc", "r")

;date = cd_calendar(f->time, -2)

time = f->time

latN = 25
latS = -latN


lat = f->lat({latS:latN})
lon = f->lon


olr = short2flt(f->pr(time|:,{lat|latS:latN}, lon|:))

print(all(.not.ismissing(olr)))

threshold = 1000
olr@_FillValue = 1e20

if (any(isnan_ieee(olr))) then
	replace_ieeenan (olr, olr@_FillValue, 0)
end if

olr = where(olr.gt.threshold, olr@_FillValue, olr)


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

                               
TIME    = cd_calendar(time, 0)             ; type float 
year    = toint( TIME(:,0) )               ; toint strips meta data
month   = toint( TIME(:,1) )
day     = toint( TIME(:,2) ) 

if (isatt(TIME,"calendar")) then           ; default is gregorian
   year@calendar = TIME@calendar         
end if

ddd     = day_of_year(year, month, day) 
if (isatt(year,"calendar")) then           ; default is gregorian
   ddd@calendar = year@calendar  
end if

yyyyddd = year*1000 + ddd                 ; needed for input
if (isatt(ddd,"calendar")) then           ; default is gregorian
   yyyyddd@calendar = ddd@calendar  
end if

year_day_size = max(ddd)

if smooth then
    nhar = 1 ; ONLY CONSIDER ANNUal cycle
    climday = clmDayTLL(olr, yyyyddd)
    printVarSummary(climday)
    climatology = smthClmDayTLL(climday, nhar)
    printVarSummary(climatology)
    anomaly = calcDayAnomTLL(olr, yyyyddd, climatology)
    printVarSummary(anomaly )
else
    climatology = clmDayTLL(olr, yyyyddd)
    anomaly = calcDayAnomTLL(olr, yyyyddd, climatology)
end if

print("Filtering...")

filtered = new((/dimsizes(time), dimsizes(lat), dimsizes(lon)/), float, -999)

filtered!0 = "time"
filtered!1 = "lat"
filtered!2 = "lon"

filtered&time = time
filtered&lat = lat
filtered&lon = lon

filtered@units = "kg/m2s"

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
	; period = (/2.5, 10/)
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
	filtered(time|:, lat|y, lon|:) = (/kf_filter(anomaly(time|:, lat|y, lon|:), obsPerDay, period(0), period(1), wavenumber(0), wavenumber(1), depth(0), depth(1), wave_type)/)
	print((/lat(y)/))
end do

printVarSummary(filtered)
printMinMax(filtered, False)

print("Opening the output file...")


g = addfile(folderout+filename +"_"+ wave + "_"+latN+"newtime.nc", "c")

print("Writing the output file...")

g->$wave$ = filtered

print("Closing the output file...")

delete(g)

end
