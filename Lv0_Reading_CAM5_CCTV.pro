PRO Lv0_Reading_CAM5_CCTV
  TIC
  ;;;#########################################################################
  ;;; A program that reads rain streak image data extracted from CCTV images
  ;;;  and calculates the diameter and number of diameters of raindrops
  ;;;
  ;;;                                        By Hyeon-Joon Kim (2023.01.12)
  ;;;
  ;;; If you use this code, please cite it as below.
  ;;; Lee, J., Byun, J., Baik, J., Jun, C., and Kim, H.-J.(2023) Estimation of raindrop size distribution and rain rate with infrared surveillance camera in dark conditions, Atmos. Meas. Tech. 
  ;;;
  ;;;#########################################################################

  np = python.import('numpy')


  ;;;======== Directory =====================================================
  Main_Dir = 'D:\Dropbox\Github\Rain_CCTV\'

  CCTV_Dir = Main_Dir+'Data\Lv0_rain_streak\'
  ND_Dir = Main_Dir+'Data\Lv1_Drops\'
  Pic_Dir = Main_Dir+'Figure\'

  file_mkdir, CCTV_Dir, /NOEXPAND_PATH
  file_mkdir, ND_Dir, /NOEXPAND_PATH
  file_mkdir, Pic_Dir, /NOEXPAND_PATH
  ;;;======================================================================

  files = file_search(CCTV_Dir+'*.npy', count=ct_files)
  num_arr1=intarr(ct_files)
  
  nx = 640  ;;; image x axis size
  ny = 640  ;;; image y axis size

  FOR f = 5, 5 DO BEGIN
  ;;;FOR f = 5, ct_files-1L DO BEGIN

    f_npy = files[f]

    b1 = strpos(f_npy,'.npy',/reverse_search)
    num1 = strmid(f_npy,b1-4,4)
    
    ;;;======================================================
    f_eachdrop = ND_Dir+'Eachdrop_'+string(num1,format='(I04)')+'.txt'
    openw, u_eachdrop, f_eachdrop, /get_lun
    ;;;======================================================

    data = np.load(f_npy)   

    data = rotate(data,7)
    data = float(data)

    dim_data = size(data,/dimensions)
    xdim = dim_data[0]
    ydim = dim_data[1]

    ;;;//////// Figure in manuscript /////////////////////////
    ;;;fsize=20
    ;;;pos = [0.15,0.15,0.9,0.9]
    ;;;
    ;;;win = window(dimension=[800,800])
    ;;;p0 = plot([0],[0],xrange=[0,ydim],yrange=[0,ydim],xtitle='X (pixel)',ytitle='Y (pixel)',position=pos,font_size=fsize,/nodata,/current)
    ;;;im = image(data, rgb_table=0, max_value=30.0,position=pos,/overplot)
    ;;;p0.save,Pic_Dir+'Lv1_Image_'+string(f,format='(I03)')+'.png'
    ;;;///////////////////////////////////////////////////////


    ;;;----- Low-pass filter for Noise Filtering ---------------
    kernel_Dim = 10
    kernelSize = [kernel_Dim, kernel_Dim]
    kernel = REPLICATE((1./(kernelSize[0]*kernelSize[1])), kernelSize[0], kernelSize[1])
    data_lowpass = CONVOL(FLOAT(data), kernel, /CENTER, /EDGE_TRUNCATE)

    set_value_lowpass = 3
    nan_ok = where(data_lowpass lt set_value_lowpass)
    data_lowpass[nan_ok]=!values.f_nan

    ;;;//////// Figure in manuscript /////////////////////////
    ;;;fsize=20
    ;;;pos = [0.15,0.15,0.9,0.9]
    ;;;
    ;;;win = window(dimension=[800,800])
    ;;;p0 = plot([0],[0],xrange=[0,ydim],yrange=[0,ydim],xtitle='X (pixel)',ytitle='Y (pixel)',position=pos,font_size=fsize, $
    ;;;              xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,/nodata,/current)
    ;;;im = image(data_lowpass, rgb_table=0, max_value=30.0,position=pos,/overplot)
    ;;;p0.save,Pic_Dir+'Lv2_Lowpass_Image_'+string(f,format='(I03)')+'.png'
    ;;;///////////////////////////////////////////////////////

    ;;;----- labeling part ------------------------------------
    data_label = LABEL_REGION(data_lowpass)

    data_label=float(data_label)
    ok_zero = where(data_label eq 0.0)
    data_label[ok_zero]=0.0;;;!values.f_nan

    data_label_1D = reform(data_label, xdim*ydim)
    label_arr = data_label[UNIQ(data_label, SORT(data_label))]
    n_label = n_elements(label_arr)-1

    ;;;//////// Figure in manuscript /////////////////////////
    ;;;data_label=float(data_label)
    ;;;ok_zero = where(data_label eq 0.0)
    ;;;data_label[ok_zero]=!values.f_nan
    ;;;
    ;;;fsize=20
    ;;;pos = [0.15,0.15,0.9,0.9]
    ;;;
    ;;;win = window(dimension=[800,800])
    ;;;p0 = plot([0],[0],xrange=[0,ydim],yrange=[0,ydim],xtitle='X (pixel)',ytitle='Y (pixel)',position=pos,font_size=fsize, $
    ;;;  xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,/nodata,/current)
    ;;;im = image(data_label, rgb_table=34,position=pos,/overplot)
    ;;;p0.save,Pic_Dir+'Lv3_Drop_Labeling_'+string(f,format='(I03)')+'.png'
    ;;;///////////////////////////////////////////////////////


    IF(n_label gt 0.0)THEN BEGIN

      Dia_short = dblarr(n_label)
      Dia_long=Dia_short

      For l = 2, 2 do begin
      ;;;For l = 2, n_label-1L do begin

        label_number = label_arr[l+1]

        no_label = where(data_label ne label_number)

        data_each = data_label
        data_each[no_label] = 0.0;;;!values.f_nan

        ;;;//////// Figure in manuscript /////////////////////////
        ;;;data_each=float(data_each)
        ;;;ok_zero = where(data_each eq 0.0)
        ;;;data_each[ok_zero]=!values.f_nan
        ;;;
        ;;;fsize=20
        ;;;pos = [0.15,0.15,0.9,0.9]
        ;;;
        ;;;win = window(dimension=[800,800])
        ;;;p0 = plot([0],[0],xrange=[0,ydim],yrange=[0,ydim],xtitle='X (pixel)',ytitle='Y (pixel)',position=pos,font_size=fsize, $
        ;;;  xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,/nodata,/current)
        ;;;im = image(data_each, rgb_table=0,position=pos,/overplot)
        ;;;p0.save,Pic_Dir+'Lv4_One_Drop_'+string(f,format='(I03)')+'_'+string(l,format='(I04)')+'.png'
        ;;;///////////////////////////////////////////////////////

        label_edge = PREWITT(data_each)
        ok_edge = where(label_edge gt 0.0)
        label_edge[ok_edge]=1.0

        label_thin = THIN(data_each)
        label_thin = float(label_thin)

        ok_thin = where(label_thin gt 0.0)
        label_thin[ok_thin]=1.0

        ok_thin = where(label_thin eq 1.0, ct_thin)
        ind2D_thin = array_indices(label_thin, ok_thin)

        xdim_thin = reform(ind2D_thin[0,*], ct_thin)
        ydim_thin = reform(ind2D_thin[1,*], ct_thin)

        xdim_uniq = xdim_thin[uniq(xdim_thin, sort(xdim_thin))]
        ydim_uniq = ydim_thin[uniq(ydim_thin, sort(ydim_thin))]
        n_xdim_uniq = n_elements(xdim_uniq)
        n_ydim_uniq = n_elements(ydim_uniq)

        if(n_xdim_uniq gt 1 and n_ydim_uniq gt 1)then begin
          fit_thin = POLY_FIT(xdim_thin, ydim_thin, 1)
          ratio_label = float(fit_thin[1])

          angle_label = atan(ratio_label)*(180./!pi)
          if(angle_label lt 0.0)then angle_label=360.0+angle_label
          angle_label_radian = atan(ratio_label)

        endif else begin
          angle_label = 0.0
        endelse ;;; if(n_xdim_uniq gt 1 and n_ydim_uniq gt 1)then begin

        ok_label_edge = where(label_edge eq 1.0, ct_label_edge)
        ind2D_label_edge = array_indices(label_edge, ok_label_edge)

        xdim_label_edge = reform(ind2D_label_edge[0,*], ct_label_edge)
        ydim_label_edge = reform(ind2D_label_edge[1,*], ct_label_edge)

        xdim_thin = xdim_thin - min(xdim_label_edge) - (max(xdim_label_edge)-min(xdim_label_edge))/2
        ydim_thin = ydim_thin - min(ydim_label_edge) - (max(ydim_label_edge)-min(ydim_label_edge))/2

        xdim_label_edge = xdim_label_edge - min(xdim_label_edge) - (max(xdim_label_edge)-min(xdim_label_edge))/2
        ydim_label_edge = ydim_label_edge - min(ydim_label_edge) - (max(ydim_label_edge)-min(ydim_label_edge))/2

        xdim_label_edge = float(xdim_label_edge)
        ydim_label_edge = float(ydim_label_edge)

        im = plot(xdim_label_edge, ydim_label_edge, linestyle=6, symbol='plus')


        ;;;//////// Figure in manuscript /////////////////////////
        symsize=0.8
        fsize=20
        pos = [0.15,0.15,0.9,0.9]
        xrange=[-20,20]
        yrange=[-20,20]
        sym_color='black'
        sym_color2 = 'red'
        
        win = window(dimension=[800,800])
        p0 = plot([0],[0],xrange=xrange,yrange=yrange,xtitle='X (pixel)',ytitle='Y (pixel)',position=pos,font_size=fsize, $
          xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,/nodata,/current)
        p1 = plot(xdim_label_edge, ydim_label_edge, linestyle=6, symbol='square',sym_color=sym_color,/sym_filled,sym_size=symsize,/overplot)
        p2 = plot(xdim_thin, ydim_thin, linestyle=6, symbol='square',sym_color=sym_color2,/sym_filled,sym_size=symsize,/overplot)
        p0.save,Pic_Dir+'Lv5_Drop_Before_Rotation_'+string(f,format='(I03)')+'_'+string(l,format='(I04)')+'.png'
        ;;;///////////////////////////////////////////////////////


        xdim_label_edge_ang=fltarr(ct_label_edge)
        ydim_label_edge_ang=xdim_label_edge_ang

        for i = 0, ct_label_edge-1 do begin
          range_pixel = sqrt(xdim_label_edge[i]^2.+ydim_label_edge[i]^2.)

          cosa_point = xdim_label_edge[i] / range_pixel
          sin_point = ydim_label_edge[i] / range_pixel

          Deg_point = (180/!pi)*acos(cosa_point)

          if(xdim_label_edge[i] le 0 and ydim_label_edge[i] le 0 or xdim_label_edge[i] ge 0 and ydim_label_edge[i] le 0)then begin
            Deg_point = 360.0-Deg_point
          endif

          Deg_point2 = Deg_point-angle_label

          xdim_label_edge_ang[i] = range_pixel*cos((!Pi/180)*Deg_point2)
          ydim_label_edge_ang[i] = range_pixel*sin((!Pi/180)*Deg_point2)
        endfor  ;;; for i = 0, ct_thin-1 do begin

        xdim_thin_ang=fltarr(ct_thin)
        ydim_thin_ang=xdim_thin_ang

        for i = 0, ct_thin-1 do begin
          range_pixel = sqrt(xdim_thin[i]^2.+ydim_thin[i]^2.)

          cosa_point = xdim_thin[i] / range_pixel
          sin_point = ydim_thin[i] / range_pixel

          Deg_point = (180/!pi)*acos(cosa_point)

          if(xdim_thin[i] le 0 and ydim_thin[i] le 0 or xdim_thin[i] ge 0 and ydim_thin[i] le 0)then begin
            Deg_point = 360.0-Deg_point
          endif

          Deg_point2 = Deg_point-angle_label

          xdim_thin_ang[i] = range_pixel*cos((!Pi/180)*Deg_point2)
          ydim_thin_ang[i] = range_pixel*sin((!Pi/180)*Deg_point2)
        endfor  ;;; for i = 0, ct_thin-1 do begin

        ;;;//////// Figure in manuscript /////////////////////////
        symsize=0.9
        fsize=20
        pos = [0.15,0.15,0.9,0.9]
        xrange=[-20,20]
        yrange=[-20,20]
        sym_color='black'
        
        win = window(dimension=[800,800])
        p0 = plot([0],[0],xrange=xrange,yrange=yrange,xtitle='X (pixel)',ytitle='Y (pixel)',position=pos,font_size=fsize, $
          xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,/nodata,/current)
        p = plot(xdim_label_edge_ang, ydim_label_edge_ang, linestyle=6, symbol='square',sym_color=sym_color,/sym_filled,sym_size=symsize,/overplot)
        p0.save,Pic_Dir+'Lv6_Drop_After_Rotation_'+string(f,format='(I03)')+'_'+string(l,format='(I04)')+'.png'
        ;;;///////////////////////////////////////////////////////
stop

        Dia_short[l] = abs(max(ydim_label_edge_ang)) + abs(min(ydim_label_edge_ang))
        Dia_long[l] = abs(max(xdim_label_edge_ang)) + abs(min(xdim_label_edge_ang))

        xdim_thin_ang = round(xdim_thin_ang)
        ydim_thin_ang = round(ydim_thin_ang)
        xdim_label_edge_ang = round(xdim_label_edge_ang)

        Dia_thin = fltarr(ct_thin)

        for i = 0, ct_thin-1 do begin
          ok_y_ang1 = where(xdim_label_edge_ang eq xdim_thin_ang[i] and ydim_label_edge_ang gt ydim_thin_ang[i])
          ok_y_ang2 = where(xdim_label_edge_ang eq xdim_thin_ang[i] and ydim_label_edge_ang lt ydim_thin_ang[i])

          Dia_thin[i] = min(ydim_label_edge_ang[ok_y_ang1]) - max(ydim_label_edge_ang[ok_y_ang2])
        endfor  ;;; for i = 0, ct_thin-1 do begin

        if(min(Dia_thin) ge 0.1)then Dia_short[l] = min(Dia_thin)

        ;;;======================================================
        printf,u_eachdrop, Dia_short[l], Dia_long[l],format='(f10.2,x,f10.2)'
        ;;;======================================================

stop

      Endfor  ;;; For l = 0, n_label-1L do begin

    ENDIF ;;; IF(n_label gt 0.0)THEN BEGIN

    ;;;======================================================
    close,u_eachdrop & free_lun,u_eachdrop
    ;;;======================================================


  ENDFOR  ;;; FOR f = 0, ct_files-1L DO BEGIN

  print, '===================='
  print, '=== End Program ==='
  print, '===================='
  TOC
END ;;; PRO Lv0_Reading_CAM5_CCTV











