PRO Lv2_Analysis_ND_CCTV_PARSIVEL
  TIC
  ;;;################################################################
  ;;; A program that reads N(D) data obtained through CCTV and
  ;;; PARSIVEL observation and creates a result figures
  ;;;
  ;;;                                By Hyeon-Joon Kim (2023.01.12)
  ;;;################################################################


  ;;;======== Directory =====================================================
  Main_Dir = 'F:\In_CAU\For_CCTV_QPE\Program\For_CCTV\For_GitHub\'
  Lv2_Dir = Main_Dir+'Data\Lv2_ND\'
  Pic_Dir = Main_Dir+'Figure\'

  file_mkdir, Lv2_Dir, /NOEXPAND_PATH
  file_mkdir, Pic_Dir, /NOEXPAND_PATH
  ;;;======================================================================

  dia = [0.062,0.187,0.312,0.437,0.562,0.687,0.812,0.937,1.062,1.187,1.375,1.625,1.875,2.125,$
    2.375,2.750,3.250,3.750,4.250,4.750,5.500,6.500,7.500,8.500,9.500,11.000,13.000,15.000,17.000,19.000,21.500,24.500]
  inter = [0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.250,0.250,0.250,0.250,0.250,0.500,0.500,0.500,$
    0.500,0.500,1.000,1.000,1.000,1.000,1.000,2.000,2.000,2.000,2.000,2.000,3.000,3.000]
  vf =[0.050,0.150,0.250,0.350,0.450,0.550,0.650,0.750,0.850,0.950,1.100,1.300,1.500,1.700,1.900,2.200,2.600,3.000,3.400,3.800, $
    4.400,5.200,6.000,6.800,7.600,8.800,10.40,12.00,13.60,15.20,17.60,20.80]

  d2=dia^2 & d3=dia^3 & d4=dia^4 & d5=dia^5 & d6=dia^6
  terminal_vel=9.65-10.3*exp(-0.6*dia)


  inter_cctv = 0.1
  dia_cctv = (indgen(80)*inter_cctv) + (inter_cctv/2.)
  vel_cctv = 9.65-10.3*exp(-0.6*dia_cctv)
  d2_cctv=dia_cctv^2 & d3_cctv=dia_cctv^3 & d4_cctv=dia_cctv^4 & d5_cctv=dia_cctv^5 & d6_cctv=dia_cctv^6

  ;;;======================================
  Lv2_parsi = Lv2_Dir+'ND_PARSIVEL_paper.mis'
  Lv2_cctv = Lv2_Dir+'ND_CCTV_paper.mis'
  ;;;======================================

  nlines_p = file_lines(Lv2_parsi)
  nlines_c = file_lines(Lv2_cctv)

  ND1=fltarr(32)  ;;; for PARSIVEL
  ND2=fltarr(80)  ;;; for CCTV

  yy_p=lonarr(nlines_p)
  mm_p=yy_p & dd_p=yy_p & hh_p=yy_p & mn_p=yy_p
  tjs_p=dblarr(nlines_p)
  ND_p=dblarr(nlines_p,32)
  ND_p_corrected=ND_p
  rain_p=dblarr(nlines_p) & ref_p=rain_p & rain_p_corrected=rain_p
  Dm_p=rain_p & D0_p=rain_p & N0_p=rain_p & Nw_p=rain_p
  LWC_p=rain_p & slope_p=rain_p & shape_p=rain_p
  Dmax_p=rain_p

  exp_DSD_p=dblarr(nlines_p,32)
  gamma_DSD_p=exp_DSD_p

  ;;;------------------
  yy_c=lonarr(nlines_c)
  mm_c=yy_c & dd_c=yy_c & hh_c=yy_c & mn_c=yy_c
  tjs_c=dblarr(nlines_c)
  ND_c=dblarr(nlines_c,80)
  rain_c=dblarr(nlines_c) & ref_c=rain_c
  Dm_c=rain_c & D0_c=rain_c & N0_c=rain_c & Nw_c=rain_c
  LWC_c=rain_c & slope_c=rain_c & shape_c=rain_c
  Dmax_c=rain_c

  exp_DSD_c=dblarr(nlines_p,80)
  gamma_DSD_c=exp_DSD_c

  format_p = '(i04,4(x,i02), 32f11.3, 2f9.3)'
  format_c = '(I04,4(x,I02),80(x,f11.3))'

  openr,u_parsi,Lv2_parsi,/get_lun
  FOR i = 0, nlines_p-1L DO BEGIN
    readf,u_parsi, yy1,mm1,dd1,hh1,mn1,ND1,rain1,ref1,format=format_p
    yy_p[i]=yy1 & mm_p[i]=mm1 & dd_p[i]=dd1
    hh_p[i]=hh1 & mn_p[i]=mn1
    tjs_p[i]=julday(mm1,dd1,yy1,hh1,mn1,00)
    ND_p[i,*] = ND1[*]
    rain_p[i]=rain1 & ref_p[i]=ref1

    ND1_corrected=ND1

    if(rain1 ge 0.0 and rain1 lt 0.5)then begin
      ND1_corrected[2] = ND1_corrected[2] * 0.05
      ND1_corrected[3] = ND1_corrected[3] * 0.12
      ND1_corrected[4] = ND1_corrected[4] * 0.38
      ND1_corrected[5] = ND1_corrected[5] * 0.48
      ND1_corrected[6] = ND1_corrected[6] * 0.70
      ND1_corrected[7] = ND1_corrected[7] * 0.73
      ND1_corrected[8] = ND1_corrected[8] * 0.84
      ND1_corrected[9] = ND1_corrected[9] * 0.90
      ND1_corrected[10] = ND1_corrected[10] * 0.84
      ND1_corrected[11] = ND1_corrected[11] * 0.75
      ND1_corrected[12] = ND1_corrected[12] * 0.74
      ND1_corrected[13] = ND1_corrected[13] * 0.66
      ND1_corrected[14] = ND1_corrected[14] * 0.51
      ND1_corrected[15] = ND1_corrected[15] * 0.47
      ND1_corrected[16] = ND1_corrected[16] * 0.42
      ND1_corrected[17] = ND1_corrected[17] * 0.47
    endif else if(rain1 ge 0.5 and rain1 lt 1.0)then begin
      ND1_corrected[2] = ND1_corrected[2] * 0.06
      ND1_corrected[3] = ND1_corrected[3] * 0.15
      ND1_corrected[4] = ND1_corrected[4] * 0.44
      ND1_corrected[5] = ND1_corrected[5] * 0.54
      ND1_corrected[6] = ND1_corrected[6] * 0.77
      ND1_corrected[7] = ND1_corrected[7] * 0.74
      ND1_corrected[8] = ND1_corrected[8] * 0.84
      ND1_corrected[9] = ND1_corrected[9] * 0.84
      ND1_corrected[10] = ND1_corrected[10] * 0.81
      ND1_corrected[11] = ND1_corrected[11] * 0.71
      ND1_corrected[12] = ND1_corrected[12] * 0.57
      ND1_corrected[13] = ND1_corrected[13] * 0.54
      ND1_corrected[14] = ND1_corrected[14] * 0.56
      ND1_corrected[15] = ND1_corrected[15] * 0.45
      ND1_corrected[16] = ND1_corrected[16] * 0.46
    endif else if(rain1 ge 1.0 and rain1 lt 2.0)then begin
      ND1_corrected[2] = ND1_corrected[2] * 0.09
      ND1_corrected[3] = ND1_corrected[3] * 0.24
      ND1_corrected[4] = ND1_corrected[4] * 0.63
      ND1_corrected[5] = ND1_corrected[5] * 0.71
      ND1_corrected[6] = ND1_corrected[6] * 0.95
      ND1_corrected[7] = ND1_corrected[7] * 0.97
      ND1_corrected[8] = ND1_corrected[8] * 1.03
      ND1_corrected[9] = ND1_corrected[9] * 1.04
      ND1_corrected[10] = ND1_corrected[10] * 1.00
      ND1_corrected[11] = ND1_corrected[11] * 0.88
      ND1_corrected[12] = ND1_corrected[12] * 0.77
      ND1_corrected[13] = ND1_corrected[13] * 0.71
      ND1_corrected[14] = ND1_corrected[14] * 0.63
      ND1_corrected[15] = ND1_corrected[15] * 0.47
      ND1_corrected[16] = ND1_corrected[16] * 0.39
      ND1_corrected[17] = ND1_corrected[17] * 0.46
    endif else if(rain1 ge 2.0)then begin
      ND1_corrected[2] = ND1_corrected[2] * 0.12
      ND1_corrected[3] = ND1_corrected[3] * 0.28
      ND1_corrected[4] = ND1_corrected[4] * 0.66
      ND1_corrected[5] = ND1_corrected[5] * 0.85
      ND1_corrected[6] = ND1_corrected[6] * 1.13
      ND1_corrected[7] = ND1_corrected[7] * 1.09
      ND1_corrected[8] = ND1_corrected[8] * 1.26
      ND1_corrected[9] = ND1_corrected[9] * 1.27
      ND1_corrected[10] = ND1_corrected[10] * 1.21
      ND1_corrected[11] = ND1_corrected[11] * 1.03
      ND1_corrected[12] = ND1_corrected[12] * 0.96
      ND1_corrected[13] = ND1_corrected[13] * 0.88
      ND1_corrected[14] = ND1_corrected[14] * 0.83
      ND1_corrected[15] = ND1_corrected[15] * 0.77
      ND1_corrected[16] = ND1_corrected[16] * 0.71
      ND1_corrected[17] = ND1_corrected[17] * 0.53
      ND1_corrected[18] = ND1_corrected[18] * 0.43
      ND1_corrected[19] = ND1_corrected[19] * 0.20
      ND1_corrected[20] = ND1_corrected[20] * 0.42
    endif

    ND_p_corrected[i,*] = ND1_corrected[*]

    rain_p_corrected1 = total(d3(0:31)*ND_p_corrected(i,0:31)*inter(0:31)*terminal_vel(0:31),/DOUBLE,/NAN)
    rain_p_corrected[i]=rain_p_corrected1*(!PI/6.)*3.6e-3

    ND_ind = ND1_corrected[*]
    ok_ND = where(ND_ind gt 0.0, ct_ND)

    if(ct_ND le 0)then begin
      Dmax_p[i] = !values.f_nan
    endif else begin
      Dmax_p[i] = dia[ok_ND[-1]]
    endelse

    m2 = total(ND1_corrected(0:31)*d2(0:31)*inter(0:31),/DOUBLE,/NAN) ; moment 2
    m3 = total(ND1_corrected(0:31)*d3(0:31)*inter(0:31),/DOUBLE,/NAN) ; moment 3
    m4 = total(ND1_corrected(0:31)*d4(0:31)*inter(0:31),/DOUBLE,/NAN) ; moment 4
    m6 = total(ND1_corrected(0:31)*d6(0:31)*inter(0:31),/DOUBLE,/NAN) ; moment 6

    g = (m4^2)/(m2*m6)
    mu = ((7.-11.*g)-(g^2.0+14.*g+1)^0.5)/(2.*(g-1.))
    slp = ((m2/m4)*(4.+mu)*(3.+mu))^0.5

    Dm_p[i]= m4/m3
    D0_p[i]= (3.67+mu)/slp
    N0_p[i]= slp^(mu+3.)*m2/gamma(mu+3.)
    slope_p[i]=slp
    shape_p[i]=mu

    LWC_p[i]=0.001*(!PI/6.)*m3
    Nw_p[i]=(256/(!PI*0.001))*(LWC_p[i]/(Dm_p[i]^4))

    exp_DSD_p[i,0:31] = N0_p[i]*exp((-1.0)*slp*dia(0:31))
    gamma_DSD_p[i,0:31] = N0_p[i]*dia(0:31)^mu*exp((-1.0)*slp*dia(0:31))


  ENDFOR  ;;; FOR i = 0, nlines_p-1L DO BEGIN
  close,u_parsi & free_lun,u_parsi


  openr,u_cctv,Lv2_cctv,/get_lun
  FOR i = 0, nlines_c-1L DO BEGIN
    readf,u_cctv, yy1,mm1,dd1,hh1,mn1,ND2,format=format_c
    yy_c[i]=yy1 & mm_c[i]=mm1 & dd_c[i]=dd1
    hh_c[i]=hh1 & mn_c[i]=mn1
    tjs_c[i]=julday(mm1,dd1,yy1,hh1,mn1,00)

    for j = 3, 79 do begin
      if(ND2[j-1] gt 0.0 and (ND2[j] eq 0.0 or finite(ND2[j]) eq 0))then begin
        ND2[j:*] = !values.f_nan
      endif

      if(ND2[j] eq 0.0 or finite(ND2[j]) eq 0)then continue
    endfor  ;;; for j = 2, 79 do begin

    ND2[0:1]=!values.f_nan
    ND2[*] = ND2[*] * 6.0

    ND_ind = ND2[*]
    ok_ND = where(ND_ind gt 0.0, ct_ND)

    if(ct_ND le 0)then begin
      Dmax_c[i] = !values.f_nan
    endif else begin
      Dmax_c[i] = dia_cctv[ok_ND[-1]]
    endelse

    ND_c[i,*] = ND2[*]

    rain_c1 = total(d3_cctv(0:79)*ND2(0:79)*inter_cctv*vel_cctv(0:79),/DOUBLE,/NAN)
    rain_c[i]=rain_c1*(!PI/6.)*3.6e-3

    ref_c1 = total(d6_cctv(0:79)*ND2(0:79)*inter_cctv,/DOUBLE,/NAN)
    if (ref_c1 gt 0.0) then begin
      ref_c[i]=10*alog10(ref_c1)        ; Log화 된 반사도 (계산된 반사도)
    endif else if (ref_c1 le 0.0) then begin
      ref_c[i]=0.0
    endif

    m2 = total(ND2(0:79)*d2_cctv(0:79)*inter_cctv,/DOUBLE,/NAN) ; moment 2
    m3 = total(ND2(0:79)*d3_cctv(0:79)*inter_cctv,/DOUBLE,/NAN) ; moment 3
    m4 = total(ND2(0:79)*d4_cctv(0:79)*inter_cctv,/DOUBLE,/NAN) ; moment 4
    m6 = total(ND2(0:79)*d6_cctv(0:79)*inter_cctv,/DOUBLE,/NAN) ; moment 6

    g = (m4^2)/(m2*m6)
    mu = ((7.-11.*g)-(g^2.0+14.*g+1)^0.5)/(2.*(g-1.))
    slp = ((m2/m4)*(4.+mu)*(3.+mu))^0.5

    Dm_c[i]= m4/m3
    D0_c[i]= (3.67+mu)/slp
    N0_c[i]= slp^(mu+3.)*m2/gamma(mu+3.)
    slope_c[i]=slp
    shape_c[i]=mu

    LWC_c[i]=0.001*(!PI/6.)*m3
    Nw_c[i]=(256/(!PI*0.001))*(LWC_c[i]/(Dm_c[i]^4))


    exp_DSD_c[i,0:79] = N0_c[i]*exp((-1.0)*slp*dia_cctv(0:79))
    gamma_DSD_c[i,0:79] = N0_c[i]*dia_cctv(0:79)^mu*exp((-1.0)*slp*dia_cctv(0:79))


  ENDFOR  ;;; FOR i = 0, nlines_c-1L DO BEGIN
  close,u_cctv & free_lun,u_cctv



  ;;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ;;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ;;;@@@@@  Drawing Figures  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ;;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ;;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


  st_time = julday(03, 25, 2022, 19, 45, 00)
  ed_time = julday(03, 26, 2022, 06, 00, 00)

  ok_time1 = where(tjs_p ge st_time and tjs_p le ed_time, ct_time1)
  ok_time2 = where(tjs_c ge st_time and tjs_c le ed_time, ct_time2)

  tjs_p = tjs_p[ok_time1]
  ND_p_corrected = ND_p_corrected[ok_time1,*]
  rain_p_corrected = rain_p_corrected[ok_time1]
  ref_p = ref_p[ok_time1]
  Dmax_p = Dmax_p[ok_time1]
  Dm_p = Dm_p[ok_time1]
  D0_p = D0_p[ok_time1]
  N0_p = N0_p[ok_time1]
  slope_p = slope_p[ok_time1]
  shape_p = shape_p[ok_time1]
  LWC_p = LWC_p[ok_time1]
  Nw_p = Nw_p[ok_time1]
  exp_DSD_c = exp_DSD_c[ok_time1,*]
  gamma_DSD_c = gamma_DSD_c[ok_time1,*]

  tjs_c = tjs_c[ok_time2]
  ND_c = ND_c[ok_time2,*]
  rain_c = rain_c[ok_time2]
  ref_c = ref_c[ok_time2]
  Dmax_c = Dmax_c[ok_time2]
  Dm_c = Dm_c[ok_time2]
  D0_c = D0_c[ok_time2]
  N0_c = N0_c[ok_time2]
  slope_c = slope_c[ok_time2]
  shape_c = shape_c[ok_time2]
  LWC_c = LWC_c[ok_time2]
  Nw_c = Nw_c[ok_time2]
  exp_DSD_p = exp_DSD_p[ok_time2,*]
  gamma_DSD_p = gamma_DSD_p[ok_time2,*]


  ;;;/////////////////////////////////////////////////////////////////////
  ;;;/// Scatter plot ////////////////////////////////////////////////////
  ;;;/////////////////////////////////////////////////////////////////////

  inter_t = 15
  nline_pc = n_elements(rain_p_corrected)


  print, 'nline_pc = ', nline_pc

  rain_p_acc=[]
  rain_c_acc=[]

  for t = 0, nline_pc-1L, inter_t do begin
    if(t+inter_t-1 gt nline_pc-1L)then begin
      rain_p1 = rain_p_corrected[t : nline_pc-1L]
      rain_c1 = rain_c[t : nline_pc-1L]
    endif else begin
      rain_p1 = rain_p_corrected[t : t+inter_t-1]
      rain_c1 = rain_c[t : t+inter_t-1]
    endelse

    rain_p_acc1 = total(rain_p1,/double,/nan)
    rain_c_acc1 = total(rain_c1,/double,/nan)

    rain_p_acc = [rain_p_acc, rain_p_acc1]
    rain_c_acc = [rain_c_acc, rain_c_acc1]
  endfor  ;;; for t = 0, nline_pc-1L do begin

  rain_p_acc = rain_p_acc / float(inter_t)  ;;; 강우강도로 단위 변환(누적시간 나눠줌)
  rain_c_acc = rain_c_acc / float(inter_t)  ;;; 강우강도로 단위 변환(누적시간 나눠줌)

  xarr = [0:100]

  pol1 = POLY_FIT(rain_p_acc, rain_c_acc, 1, MEASURE_ERRORS=measure_errors,SIGMA=sigma)
  a0_1 = pol1[0] & a1_1 = pol1[1]
  yarr1 = a0_1 + xarr*a1_1

  ok_filter2 = where(rain_c_acc lt 2., ct_filter2)
  rain_p_acc2 = rain_p_acc[ok_filter2]
  rain_c_acc2 = rain_c_acc[ok_filter2]

  pol2 = POLY_FIT(rain_p_acc2, rain_c_acc2, 1, MEASURE_ERRORS=measure_errors,SIGMA=sigma)
  a0_2 = pol2[0] & a1_2 = pol2[1]
  yarr2 = a0_2 + xarr*a1_2


  ok_filter3 = where(rain_c_acc ge 2., ct_filter3)
  rain_p_acc3 = rain_p_acc[ok_filter3]
  rain_c_acc3 = rain_c_acc[ok_filter3]

  pol3 = POLY_FIT(rain_p_acc3, rain_c_acc3, 1, MEASURE_ERRORS=measure_errors,SIGMA=sigma)
  a0_3 = pol3[0] & a1_3 = pol3[1]
  yarr3 = a0_3 + xarr*a1_3

  ;;;--------------------------------------------------
  fit_p_acc1 = a1_1*rain_p_acc+a0_1
  str_relation1 = ' R!DCCTV!N = '+string(a1_1,format='(f4.2)')+'R!DPAR!N+'+string(a0_1,format='(f5.2)')

  mae1 = (1./float(n_elements(rain_c_acc))) * total(abs(fit_p_acc1-rain_c_acc),/double,/nan)
  corr1 = correlate(rain_p_acc, rain_c_acc,/double)
  rmse1 = rmse(rain_p_acc, rain_c_acc)
  mape1 = (1./float(n_elements(rain_c_acc))) * total(abs(( rain_p_acc-rain_c_acc)/rain_p_acc),/double,/nan)

  str_R1 = 'CC = '+ string(corr1, format='(f0.2)')
  str_mae1 = 'MAE = '+ string(mae1, format='(f5.2)')
  str_rmse1 = 'RMSE = '+ string(rmse1, format='(f5.2)')
  str_mape1 = 'MAPE = '+ string(mape1, format='(f5.2)')

  ;;;--------------------------------------------------
  fit_p_acc2 = a1_2*rain_p_acc2+a0_2
  str_relation2 = 'R!DCCTV!N='+string(a1_2,format='(f4.2)')+'R!DPAR!N'+string(a0_2,format='(f5.2)')

  mae2 = (1./float(n_elements(rain_c_acc2))) * total(abs(fit_p_acc2-rain_c_acc2),/double,/nan)
  corr2 = correlate(rain_p_acc2, rain_c_acc2,/double)
  rmse2 = rmse(rain_p_acc2, rain_c_acc2)
  mape2 = (1./float(n_elements(rain_c_acc2))) * total(abs(( rain_p_acc2-rain_c_acc2)/rain_p_acc2),/double,/nan)

  str_R2 = 'CC = '+ string(corr2, format='(f0.2)')
  str_mae2 = 'MAE = '+ string(mae2, format='(f5.2)')
  str_rmse2 = 'RMSE = '+ string(rmse2, format='(f5.2)')
  str_mape2 = 'MAPE = '+ string(mape2, format='(f5.2)')

  ;;;--------------------------------------------------
  fit_p_acc3 = a1_3*rain_p_acc3+a0_3
  str_relation3 = 'R!DCCTV!N='+string(a1_3,format='(f4.2)')+'R!DPAR!N'+string(a0_3,format='(f5.2)')

  mae3 = (1./float(n_elements(rain_c_acc3))) * total(abs(fit_p_acc3-rain_c_acc3),/double,/nan)
  corr3 = correlate(rain_p_acc3, rain_c_acc3,/double)
  rmse3 = rmse(rain_p_acc3, rain_c_acc3)
  mape3 = (1./float(n_elements(rain_c_acc3))) * total(abs(( rain_p_acc3-rain_c_acc3)/rain_p_acc3),/double,/nan)

  str_R3 = 'CC = '+ string(corr3, format='(f0.2)')
  str_mae3 = 'MAE = '+ string(mae3, format='(f5.2)')
  str_rmse3 = 'RMSE = '+ string(rmse3, format='(f5.2)')
  str_mape3 = 'MAPE = '+ string(mape3, format='(f5.2)')

  ;;;--------------------------------------------------
  str_R_all = '  CC   =  '+ string(corr1, format='(f0.2)')+'/'+string(corr2, format='(f0.2)')+'/'+string(corr3, format='(f0.2)')
  str_mae_all = ' MAE  = '+ string(mae1, format='(f0.2)')+'/'+string(mae2, format='(f0.2)')+'/'+string(mae3, format='(f0.2)')
  str_rmse_all = 'RMSE = '+ string(rmse1, format='(f0.2)')+'/'+string(rmse2, format='(f0.2)')+'/'+string(rmse3, format='(f0.2)')
  str_mape_all = 'MAPE = '+ string(mape1, format='(f0.2)')+'/'+string(mape2, format='(f0.2)')+'/'+string(mape3, format='(f0.2)')

  ;;;--------------------------------------------------
  xtitle='Rain rate [PARSIVEL] (mm h!U-1!N)'
  ytitle='Rain rate [CCTV] (mm h!U-1!N)'
  pos1=[0.15, 0.15, 0.95,0.95]
  xrange=[0,10] & yrange=[0,10]
  fsize1=20 & fsize2 = 18
  trans=10


  win = window(dimension=[800,600])
  p0 = plot([0],[0],xrange=xrange,yrange=yrange,xtitle=xtitle,ytitle=ytitle,font_size=fsize1,position=pos1, $
    xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1, font_style='Bold',/nodata,/current)

  p1 = plot(rain_p_acc, rain_c_acc, linestyle=6,sym_color='dim_gray',symbol='circle',sym_transparency=trans,/sym_filled,/overplot)
  fit1 = plot(xarr, yarr1, color='red',thick=2,/overplot)
  pline = plot([xrange[0],xrange[1]], [yrange[0],yrange[1]], color='gray',/overplot  )

  t1 = text(0.58, 0.48, str_relation1,/normal, font_size=fsize2)
  t2 = text(0.58, 0.41, str_R_all,/normal, font_size=fsize2)
  t3 = text(0.58, 0.34, str_mae_all,/normal, font_size=fsize2)
  t4 = text(0.58, 0.27, str_rmse_all,/normal, font_size=fsize2)
  t4 = text(0.58, 0.20, str_mape_all,/normal, font_size=fsize2)

  p0.save,Pic_Dir+'Scatter_Rainrate.png'


  ;;;/////////////////////////////////////////////////////////////////////
  ;;;/// Timeseries //////////////////////////////////////////////////////
  ;;;/////////////////////////////////////////////////////////////////////

  start_time1 = julday(03, 25, 2022, 19, 45, 00)
  end_time1 = julday(03, 26, 2022, 06, 00, 00)

  start_time2 = julday(03, 25, 2022, 22, 00, 00)
  end_time2 = julday(03, 26, 2022, 03, 00, 00)

  x_range1=[start_time1,end_time1]
  x_range2=[start_time2,end_time2]

  Rain_margin = [0.1, 0.15, 0.05, 0.1]
  ND_margin = [0.08, 0.15, 0.15, 0.1]
  lev_ND=[-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
  clabel=['10!U-2!N','','10!U-1!N','','10!U0!N','','10!U1!N','','10!U2!N','','10!U3!N','','10!U4!N','','10!U5!N']

  ;;;;;date_label=LABEL_DATE(DATE_FORMAT = ['%H:%I'])
  date_label=LABEL_DATE(DATE_FORMAT = ['%H:%I'])

  T_margin = [0.1, 0.1, 0.2, 0.12]
  C_margin = [0.89, 0.1, 0.91, 0.88]

  R_pos1 = [0.1, 0.12, 0.95, 0.95]
  R_pos2 = [0.25, 0.4, 0.75, 0.9]

  leg1_position=[0.85, 0.8]
  Rain_range1=[0,30]
  Rain_range2=[0,7]

  Ref_range=[10, 70]
  WD_range=[0,360]
  WS_min=0 & WS_max=40
  Dm_range=[0.5, 3.5]
  Nw_range=[2,5]
  NT_range=[2,5]
  Mass_Var_range=[0,1.5]
  shape_range=[-5,20]
  slope_range=[0,60]
  KineticE_Time_range=[0,6000]
  Momentum_range=[0,150]

  fontsize=17 & symsize=0.5 & ct = COLORTABLE(21, /REVERSE)

  LogND_PARSIVEL=alog10(ND_p_corrected)
  LogND_CCTV =  alog10(ND_c)

  leg_pos = [0.83, 0.88]


  win = window(dimension=[1000,500]);,/buffer)
  c1 = contour(LogND_PARSIVEL,tjs_p,dia,rgb_table=33,axis_style=2,margin=ND_margin,/fill,C_VALUE=lev_ND,$
    xtitle='Time (h)',ytitle='Diameter (mm)',font_size=18, font_style='Bold',  $
    yrange=[0.2,4],xrange=x_range1,XTICKFORMAT=['LABEL_DATE'], XTICKUNITS = ['Time'],/current)
  cb1 = colorbar(TARGET=c1, orientation=1, POSITION=[0.86,0.15,0.88,0.9],TITLE='Number Concentration (mm!U-1!Nm!U-3!N)',$
    Textpos=1,taper=0,font_size=15,TICKNAME=clabel, font_style='Bold')
  p1 = plot(tjs_p, Dm_p,name='D!Dm!N', color='black',thick=1.5,/overplot)
  leg = legend(target=[p1],position=leg_pos,/normal,/auto_text_color, font_size=18, font_style='Bold')
  c1.save,Pic_Dir+'Timeseries_PARSIVEL.png'


  win = window(dimension=[1000,500]);,/buffer)
  c1 = contour(LogND_CCTV, tjs_c, dia_cctv, rgb_table=33,axis_style=2,margin=ND_margin,/fill,C_VALUE=lev_ND,$
    xtitle='Time (h)',ytitle='Diameter (mm)',font_size=18, font_style='Bold', $
    yrange=[0.2,4],xrange=x_range1,XTICKFORMAT=['LABEL_DATE'], XTICKUNITS = ['Time'],/current)
  cb1 = colorbar(TARGET=c1, orientation=1, POSITION=[0.86,0.15,0.88,0.9],TITLE='Number Concentration (mm!U-1!Nm!U-3!N)',$
    Textpos=1,taper=0,font_size=15,TICKNAME=clabel, font_style='Bold')
  p1 = plot(tjs_c, Dm_c,name='D!Dm!N', color='black',thick=1.5,/overplot)
  leg = legend(target=[p1],position=leg_pos,/normal,/auto_text_color, font_size=18, font_style='Bold')
  c1.save,Pic_Dir+'Timeseries_CCTV.png'


  leg_pos = [0.94, 0.93]

  win = window(dimension=[1000,500]);,/buffer)
  p0 = plot([0],[0], axis_style=2,position=R_pos1, xtitle='Time (h)',ytitle='Rain rate (mm h!U-1!N)',font_size=20, font_style='Bold', $
    yrange=Rain_range1,xrange=x_range1,XTICKFORMAT=['LABEL_DATE'], XTICKUNITS = ['Time'],/nodata,/current)
  p1 = barplot(tjs_c, rain_c,color='gray',fill_color='gray',name='CCTV',/overplot)
  p2 = plot(tjs_p, rain_p_corrected, linestyle=0,color='red',thick=2,name='PARSIVEL',/overplot)
  ;;;p3 = plot(tjs_g, rain_g_ma, linestyle=0,color='blue',thick=2,name='GAUGE',/overplot)
  leg = legend(target=[p1,p2],position=leg_pos,/normal,/auto_text_color, font_size=18)

  p0 = plot([0],[0], axis_style=2,position=R_pos2, xtitle='Time (h)',ytitle='Rain rate (mm h!U-1!N)',font_size=15, font_style='Bold', $
    yrange=Rain_range2,xrange=x_range2,XTICKFORMAT=['LABEL_DATE'], XTICKUNITS = ['Time'], $
    xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,xminor=3,/nodata,/current)
  p1 = barplot(tjs_c, rain_c,color='gray',fill_color='gray',name='CCTV',/overplot)
  p2 = plot(tjs_p, rain_p_corrected, linestyle=0,color='red',thick=2,name='PARSIVEL',/overplot)
  ;;;p3 = plot(tjs_g, rain_g_ma, linestyle=0,color='blue',thick=2,name='GAUGE',/overplot)
  p0.save,Pic_Dir+'Timeseries_Rainrate.png'



  ;;;/////////////////////////////////////////////////////////////////////
  ;;;/// Averaged N(D) //////////////////////////////////////////////////
  ;;;/////////////////////////////////////////////////////////////////////

  nan_ok=where(ND_p_corrected eq 0.0) & ND_p_corrected[nan_ok]=!values.f_nan
  nan_ok=where(ND_c eq 0.0) & ND_c[nan_ok]=!values.f_nan

  ;;;-----------------------------------
  ok_rain1 = where(rain_p gt 0.1 and rain_p lt 1.0 and rain_c gt 0.0, ct_rain1)
  ok_rain2 = where(rain_p ge 1.0 and rain_p lt 5.0 and rain_c gt 0.0, ct_rain2)
  ok_rain3 = where(rain_p ge 5.0 and rain_c gt 0.0, ct_rain3)

  ND_p_R1 = ND_p_corrected[ok_rain1,*] & ND_c_R1 = ND_c[ok_rain1,*]
  ND_p_R2 = ND_p_corrected[ok_rain2,*] & ND_c_R2 = ND_c[ok_rain2,*]
  ND_p_R3 = ND_p_corrected[ok_rain3,*] & ND_c_R3 = ND_c[ok_rain3,*]

  exp_DSD_p_R1 = exp_DSD_p[ok_rain1,*] & exp_DSD_c_R1 = exp_DSD_c[ok_rain1,*]
  exp_DSD_p_R2 = exp_DSD_p[ok_rain2,*] & exp_DSD_c_R2 = exp_DSD_c[ok_rain2,*]
  exp_DSD_p_R3 = exp_DSD_p[ok_rain3,*] & exp_DSD_c_R3 = exp_DSD_c[ok_rain3,*]

  gamma_DSD_p_R1 = gamma_DSD_p[ok_rain1,*] & gamma_DSD_c_R1 = gamma_DSD_c[ok_rain1,*]
  gamma_DSD_p_R2 = gamma_DSD_p[ok_rain2,*] & gamma_DSD_c_R2 = gamma_DSD_c[ok_rain2,*]
  gamma_DSD_p_R3 = gamma_DSD_p[ok_rain3,*] & gamma_DSD_c_R3 = gamma_DSD_c[ok_rain3,*]

  ;;;-----------------------------------
  ave_ND_p = fltarr(32) & ave_exp_p=ave_ND_p & ave_gamma_p=ave_ND_p
  ave_ND_c = fltarr(80) & ave_exp_c=ave_ND_c & ave_gamma_c=ave_ND_c

  ave_ND_p_R1 = fltarr(32) & ave_exp_p_R1=ave_ND_p_R1 & ave_gamma_p_R1=ave_ND_p_R1
  ave_ND_p_R2 = fltarr(32) & ave_exp_p_R2=ave_ND_p_R2 & ave_gamma_p_R2=ave_ND_p_R2
  ave_ND_p_R3 = fltarr(32) & ave_exp_p_R3=ave_ND_p_R3 & ave_gamma_p_R3=ave_ND_p_R3

  ave_ND_c_R1 = fltarr(80) & ave_exp_c_R1=ave_ND_c_R1 & ave_gamma_c_R1=ave_ND_c_R1
  ave_ND_c_R2 = fltarr(80) & ave_exp_c_R2=ave_ND_c_R2 & ave_gamma_c_R2=ave_ND_c_R2
  ave_ND_c_R3 = fltarr(80) & ave_exp_c_R3=ave_ND_c_R3 & ave_gamma_c_R3=ave_ND_c_R3

  for j = 2, 31 do begin
    ave_ND_p[j] = mean(ND_p_corrected[*,j],/double,/nan)
    ave_exp_p[j] = mean(exp_DSD_p[*,j],/double,/nan)
    ave_gamma_p[j] = mean(gamma_DSD_p[*,j],/double,/nan)

    ave_ND_p_R1[j] = mean(ND_p_R1[*,j],/double,/nan)
    ave_ND_p_R2[j] = mean(ND_p_R2[*,j],/double,/nan)
    ave_ND_p_R3[j] = mean(ND_p_R3[*,j],/double,/nan)

    ave_exp_p_R1[j] = mean(exp_DSD_p_R1[*,j],/double,/nan)
    ave_exp_p_R2[j] = mean(exp_DSD_p_R2[*,j],/double,/nan)
    ave_exp_p_R3[j] = mean(exp_DSD_p_R3[*,j],/double,/nan)

    ave_gamma_p_R1[j] = mean(gamma_DSD_p_R1[*,j],/double,/nan)
    ave_gamma_p_R2[j] = mean(gamma_DSD_p_R2[*,j],/double,/nan)
    ave_gamma_p_R3[j] = mean(gamma_DSD_p_R3[*,j],/double,/nan)
  endfor

  for j = 2, 79 do begin
    ave_ND_c[j] = mean(ND_c[*,j],/double,/nan)
    ave_exp_c[j] = mean(exp_DSD_c[*,j],/double,/nan)
    ave_gamma_c[j] = mean(gamma_DSD_c[*,j],/double,/nan)

    ave_ND_c_R1[j] = mean(ND_c_R1[*,j],/double,/nan)
    ave_ND_c_R2[j] = mean(ND_c_R2[*,j],/double,/nan)
    ave_ND_c_R3[j] = mean(ND_c_R3[*,j],/double,/nan)

    ave_exp_c_R1[j] = mean(exp_DSD_c_R1[*,j],/double,/nan)
    ave_exp_c_R2[j] = mean(exp_DSD_c_R2[*,j],/double,/nan)
    ave_exp_c_R3[j] = mean(exp_DSD_c_R3[*,j],/double,/nan)

    ave_gamma_c_R1[j] = mean(gamma_DSD_c_R1[*,j],/double,/nan)
    ave_gamma_c_R2[j] = mean(gamma_DSD_c_R2[*,j],/double,/nan)
    ave_gamma_c_R3[j] = mean(gamma_DSD_c_R3[*,j],/double,/nan)
  endfor


  xtitle='Diameter (mm)' & ytitle='Number Concentration (mm!U-1!Nm!U-3!N)'
  pos1 = [0.15, 0.11, 0.95, 0.95]
  pos2 = [0.6, 0.5, 0.93, 0.9]

  xrange1=[0,5] & yrange1=[0.1, 1000000]
  xrange2=[0.2, 1] & yrange2=[100, 5000]

  fsize1=20
  fsize2=12

  leg_pos=[0.51,0.92]

  thick=3

  win = window(dimension=[800,600])
  p0 = plot([0],[0],xrange=xrange1,yrange=yrange1,font_size=fsize1,xtitle=xtitle,ytitle=ytitle,position=pos1, $
    /ylog,ytickformat='mytickformat', font_style='Bold',/nodata,/current)
  p1 = plot(dia, ave_gamma_p,name='Gamma (PARSIVEL)',linestyle=0,color='black',thick=thick,/overplot)
  p2 = plot(dia_cctv, ave_gamma_c,name='Gamma (CCTV)',linestyle=0,color='red',thick=thick,/overplot)
  p3 = plot(dia, ave_ND_p,name='Obs (PARSIVEL)',linestyle=2,color='black',thick=thick,fill_level=0.1,fill_color='red',/overplot)
  p4 = plot(dia_cctv, ave_ND_c,name='Obs (CCTV)',linestyle=2,color='red',thick=thick,/overplot)
  leg = legend(target=[p1,p2,p3,p4],position=leg_pos,/normal,/auto_text_color, font_size=15)

  p0 = plot([0],[0],xrange=xrange2,yrange=yrange2,font_size=fsize2,xtitle=xtitle,ytitle=ytitle,position=pos2,font_style='Bold',$
    xticklen=1,yticklen=1,xsubticklen=0.02,ysubticklen=0.02,xgridstyle=1,ygridstyle=1,/ylog,ytickformat='mytickformat',/nodata,/current)
  p1 = plot(dia, ave_gamma_p,name='Gamma (PARSIVEL)',linestyle=0,color='black',thick=thick,/overplot)
  p2 = plot(dia_cctv, ave_gamma_c,name='Gamma (CCTV)',linestyle=0,color='red',thick=thick,/overplot)
  p3 = plot(dia, ave_ND_p,name='Obs (PARSIVEL)',linestyle=2,color='black',thick=thick,fill_level=0.1,fill_color='red',/overplot)
  p4 = plot(dia_cctv, ave_ND_c,name='Obs (CCTV)',linestyle=2,color='red',thick=thick,/overplot)
  p0.save,Pic_Dir+'Ave_ND_Total.png'


  print, '===================='
  print, '=== End Program ==='
  print, '===================='
  TOC
END ;;; PRO Lv2_Analysis_ND_CCTV_PARSIVEL


;;;=============================================
;;--------------------------------------------------
function rmse, mata ,matb
  ; mata      matrix
  ; matb      matrix too, at least same number type  as matrix
  ; out     rmse
  mat1=reform(mata) & mat2=reform(matb)
  s1=size(mat1) & s2=size(mat2)
  n1=n_elements(mat1) & n2=n_elements(mat2)

  doit= s1(0) ne  s2(0) and n1 eq n2
  if doit then begin
    print,'Number of Dimensions do not agree, but number of elements'
    mat1=reform(mat1,n1) & mat2=reform(mat1,n2)
  endif

  doit= s1(0) eq  s2(0) and n1 eq n2
  if doit then begin
    doit= total( s1(1:s1(0)) ne s2(1:s2(0))) and  (n1 eq n2)
    if doit then begin
      print,'Dimensions do not agree, but number of elements'
      mat1=reform(mat1,n1) & mat2=reform(mat1,n2)
    endif
  endif

  if  n1 ne n2 then begin
    print,'number of elements do not agree' & return,0
  endif
  out= sqrt(total((mat1-mat2)^2)/n1)
  return,out
end ;;; function rmse, mata ,matb

;;--------------------------------------------------
;;;=============================================

;;;=============================================
;;--------------------------------------------------
function mytickformat, axis,index,val
  pow=alog10(val)
  pow=strtrim(string(pow,format='(I)'),1)
  return, '10!U'+pow+'!N'
end
;;--------------------------------------------------
;;;=============================================













