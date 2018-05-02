;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Código hecho por Pablo Andrés Cárdenas Zamorano - UTFSM - 2018 ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Esta subrutina se encarga de graficar la rapidez instantea del viento para cada archivo de salida en su primer nivel eta 
;Al finalizar realiza una animación de este
;Esta versión alternativa plotea los archivos que corresponden al SPINUP del modelo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Carga de paquetes
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin

;Información de la carpeta contenedora
DATADir                     = "../1.wrfouts/spinup/"
FILES                       = systemfunc (" ls -1 " + DATADir + "wrfout_d07_*")
numFILES                    = dimsizes(FILES)
;Inicialización del gráfico
type                        = "png"
wks                         = gsn_open_wks(type,"V_eta1/frames_spinup/10m_vel")
;Almacenamiento de los archivos a plotear 
a                           = addfiles(FILES,"r")
;Obtención de pasos de tiempo para los archivos
times                       = wrf_user_getvar(a, "times", -1)
ntimes                      = dimsizes(times)

;Obtención de la orografía del trreno
ter                         = wrf_user_getvar(a[0],"HGT",0)
ter@long_name               = "Terrain Height (m)"
delete(ter@description)
delete(ter@units) 
delete(ter@long_name)
;Características del gráfico del terreno
res                         = True
res@cnLineDashPattern       = 2
;res@cnLevelSpacingF         = 60.
res@cnLineColor             = "Black"
res@cnLineLabelsOn          = False
res@gsnDraw                 = False
res@gsnFrame                = False
res@gsnMaximize             = True
;Plot del terreno
contour_hgt                 = gsn_contour(wks,ter,res)

;Características del gráfico de magnitud del viento a 10m 
res@MainTitle               = "Rapidez del viento en ~F33~h~F~ = 1"
res@cnFillPalette           = "MPL_viridis"
res@cnFillOn                = True
res@gsnSpreadColors         = True
res@gsnSpreadColorStart     = 1
res@gsnSpreadColorEnd       = -3
res@Footer                  = False
res@FieldTitle              = "V (m s-1)"
res@cnLevelSelectionMode    = "ManualLevels"
res@cnLevelSpacingF         = 0.1
res@cnMinLevelValF          = 3.
res@cnMaxLevelValF          = 7.
;res@InitTime                = False
res@cnInfoLabelOn   = False
res@lbAutoManage = False
res@lbLabelStride         = 4.
res@lbLabelFontHeightF    = .015
;res@lbLabelBarOn    = False

;Carácterísticas del wrfoverlay 
mpres                       = True
mpres@mpOutlineOn           = False
;mpres@mpDataBaseVersion     = "HighRes"
;mpres@mpDataResolution      = "finest"

;Características del plot global
auxres  = True
auxres@NoTitles = True

;Inicio del ciclo que recorre todos los pasos de tiempo
do it = 0,ntimes-1,1
    ;Comienzo de creación de gráficos
    res@TimeLabel           = times(it)
    uvm                     = wrf_user_getvar(a[it],"uvmet",0)
    u                       = uvm(0,0,:,:) 
    v                       = uvm(1,0,:,:)
    mag                     = sqrt(u^2 + v^2)
    print("        Graficando en tiempo: " + times(it) + "        max = " + sprintf("%6.3f", max(mag))+ "        min = " + sprintf("%6.3f", min(mag)))
    contour_mag             = wrf_contour(a[it],wks,mag,res)
    plot                    = wrf_map_overlays(a[it],wks,(/contour_hgt,contour_mag/),auxres,mpres)
end do

;Edición(corte) de las fotos
FILES2 = systemfunc (" ls -1 V_eta1/frames_spinup/*.png")
numFILES2 = dimsizes(FILES2)
print("        Editando gráficos...")

;Ciclo que recorre las fotos
do ii=0,numFILES2-1
    system("convert "+FILES2(ii)+" -crop 730x850+170+0 +repage "+FILES2(ii))
end do

;Creación del gif en base a las fotos cortadas
system("printf '        Generando archivo gif...'")
;system("convert -delay 15 -loop 0 V_eta1/frames/*.png 7.eta1_vel.gif")
end