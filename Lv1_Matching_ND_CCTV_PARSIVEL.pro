PRO Lv1_Matching_ND_CCTV_PARSIVEL
  TIC
  ;;;################################################################
  ;;; A program that reads N(D) data obtained through CCTV and
  ;;; PARSIVEL observation and matches the same time
  ;;;
  ;;;                                By Hyeon-Joon Kim (2023.01.12)
  ;;;################################################################

  ;;;======== Directory =====================================================
  Main_Dir = 'F:\In_CAU\For_CCTV_QPE\Program\For_CCTV\For_GitHub\'
  PARSIVEL_Dir = Main_Dir+'Data\PARSIVEL\'
  CCTV_Each_Drop_Dir = Main_Dir+'Data\Lv1_Drops\'
  Lv2_Dir = Main_Dir+'Data\Lv2_ND\'

  file_mkdir, PARSIVEL_Dir, /NOEXPAND_PATH
  file_mkdir, CCTV_Each_Drop_Dir, /NOEXPAND_PATH
  file_mkdir, Lv2_Dir, /NOEXPAND_PATH
  ;;;======================================================================

  dia = [0.062,0.187,0.312,0.437,0.562,0.687,0.812,0.937,1.062,1.187,1.375,1.625,1.875,2.125,$
    2.375,2.750,3.250,3.750,4.250,4.750,5.500,6.500,7.500,8.500,9.500,11.000,13.000,15.000,17.000,19.000,21.500,24.500]
  inter = [0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.250,0.250,0.250,0.250,0.250,0.500,0.500,0.500,$
    0.500,0.500,1.000,1.000,1.000,1.000,1.000,2.000,2.000,2.000,2.000,2.000,3.000,3.000]
  vf =[0.050,0.150,0.250,0.350,0.450,0.550,0.650,0.750,0.850,0.950,1.100,1.300,1.500,1.700,1.900,2.200,2.600,3.000,3.400,3.800, $
    4.400,5.200,6.000,6.800,7.600,8.800,10.40,12.00,13.60,15.20,17.60,20.80]

  d2=dia^2 & d3=dia^3 & d4=dia^4 & d5=dia^5 & d6=dia^6
  terminal_vel=9.65-10.3*exp(-0.6*dia)


  Lv2_parsi = Lv2_Dir+'ND_PARSIVEL.mis'
  Lv2_cctv = Lv2_Dir+'ND_CCTV.mis'

  openw,u_lv2_parsi, Lv2_parsi,/get_lun
  openw,u_lv2_cctv, Lv2_cctv,/get_lun


  f_parsi = PARSIVEL_Dir+'CAU_ND.mis'
  nlines_p = file_lines(f_parsi)

  format_p = '(i04,4(x,i02), 32f11.3, 2f9.3)'
  format_c = '(I04,4(x,I02),80(x,f11.3))'

  ND1=fltarr(32)  ;;; for PARSIVEL
  yy_p=lonarr(nlines_p)
  mm_p=yy_p & dd_p=yy_p & hh_p=yy_p & mn_p=yy_p
  tjs_p=dblarr(nlines_p)
  rain_p=dblarr(nlines_p) & ref_p=rain_p
  ND_p=dblarr(nlines_p,32)


  openr,u_parsi,f_parsi,/get_lun
  FOR i = 0, nlines_p-1L DO BEGIN
    readf,u_parsi, yy1,mm1,dd1,hh1,mn1,ND1,rain1,ref1,format=format_p
    yy_p[i]=yy1
    mm_p[i]=mm1
    dd_p[i]=dd1
    hh_p[i]=hh1
    mn_p[i]=mn1
    tjs_p[i]=julday(mm1,dd1,yy1,hh1,mn1,00)
    ND_p[i,*] = ND1[*]
    rain_p[i]=rain1
    ref_p[i]=ref1
  ENDFOR  ;;; FOR i = 0, nlines_p-1L DO BEGIN
  close,u_parsi & free_lun,u_parsi

  nan_ND = where(ND_p eq 0.0 or finite(ND_p) eq 0)
  ND_p[nan_ND]=!values.f_nan


  Drop_Kernel_Dir = CCTV_Each_Drop_Dir

  f_drop_kernel = file_search(Drop_Kernel_Dir+'Eachdrop_????????????.txt', count=ct_drop_kernel)

  tjs_c = dblarr(ct_drop_kernel)


  FOR f = 0, ct_drop_kernel-1L DO BEGIN
    f_drop = f_drop_kernel[f]

    b1 = strpos(f_drop,'.txt',/reverse_search)
    yy_c = strmid(f_drop,b1-12,4)
    mm_c = strmid(f_drop,b1-8,2)
    dd_c = strmid(f_drop,b1-6,2)
    hh_c = strmid(f_drop,b1-4,2)
    mn_c = strmid(f_drop,b1-2,2)
    tjs_c[f]=julday(mm_c,dd_c,yy_c,hh_c,mn_c,00)

    f_lines = file_lines(f_drop)
    Dia_short=[] & Dia_long=[]

    openr,u_drop,f_drop,/get_lun
    for i = 0, f_lines-1L do begin
      readf,u_drop, Dia_short1, Dia_long1,format='(f10.2,x,f10.2)'
      Dia_short = [Dia_short, Dia_short1]
      Dia_long = [Dia_long, Dia_long1]
    endfor  ;;; for i = 0, f_lines-1L do begin
    close,u_drop & free_lun,u_drop

    Dia_short = Dia_short * 0.0512352

    bsz = 0.1
    count_arr = HISTOGRAM(Dia_short, MIN=0, MAX=8, BINSIZE=bsz, LOCATION=xloc)
    count_arr = count_arr[0:-2]

    ND_c=float(count_arr)
    nan_ND = where(ND_c eq 0.0 or finite(ND_c) eq 0)
    ND_c[nan_ND]=!values.f_nan


    ok_time = where(tjs_p eq tjs_c[f], ct_time)
    if(ct_time eq 1)then begin
      printf,u_lv2_parsi, yy_p[ok_time[0]],mm_p[ok_time[0]],dd_p[ok_time[0]],hh_p[ok_time[0]],mn_p[ok_time[0]], $
        ND_p[ok_time[0],*],rain_p[ok_time[0]],ref_p[ok_time[0]], format=format_p

      printf,u_lv2_cctv,yy_c,mm_c,dd_c,hh_c,mn_c,ND_c[*],format=format_c
    endif ;;; if(ct_time eq 1)then begin


  ENDFOR  ;;; FOR f = 0, ct_drop_kernel-1L DO BEGIN


  close,u_lv2_parsi & free_lun,u_lv2_parsi
  close,u_lv2_cctv & free_lun,u_lv2_cctv








  print, '===================='
  print, '=== End Program ==='
  print, '===================='
  TOC
END ;;; PRO Lv1_Matching_ND_CCTV_PARSIVEL







