PRO Lv1_Make_ND_CCTV
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



  Lv2_cctv = Lv2_Dir+'ND_CCTV.mis'

  openw,u_lv2_cctv, Lv2_cctv,/get_lun
  format_c = '(80(x,f11.3))'

  ND_c = fltarr(80)
  
  f_drop_kernel = file_search(CCTV_Each_Drop_Dir+'Eachdrop_????.txt', count=ct_drop_kernel)

  FOR f = 0, ct_drop_kernel-1L DO BEGIN
    f_drop = f_drop_kernel[f]

    b1 = strpos(f_drop,'.txt',/reverse_search)
    num_c = strmid(f_drop,b1-26,4)

    f_lines = file_lines(f_drop)
    Dia_short=[]

    openr,u_drop,f_drop,/get_lun
    for i = 0, f_lines-1L do begin
      readf,u_drop, Dia_short1, Dia_long1,format='(f10.2,x,f10.2)'
      Dia_short = [Dia_short, Dia_short1]
    endfor  ;;; for i = 0, f_lines-1L do begin
    close,u_drop & free_lun,u_drop

    Dia_short = Dia_short * 0.0512352

    bsz = 0.1
    count_arr = HISTOGRAM(Dia_short, MIN=0, MAX=8, BINSIZE=bsz, LOCATION=xloc)
    count_arr = count_arr[0:-2]
    
    ND_c1=float(count_arr) 
    ND_c = ND_c+ND_c1

  ENDFOR  ;;; FOR f = 0, ct_drop_kernel-1L DO BEGIN

  printf,u_lv2_cctv,ND_c[*],format=format_c
  close,u_lv2_cctv & free_lun,u_lv2_cctv






  print, '===================='
  print, '=== End Program ==='
  print, '===================='
  TOC
END ;;; PRO Lv1_Matching_ND_CCTV_PARSIVEL







