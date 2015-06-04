PRO make_file_comp,name,pixscale,zp,exptime, LOG_FILE, SUBCOMP_FILE, OUTFILE,  READINI_FILE=READINI_FILE

      OPENW,unit,OUTFILE,/GET_LUN
      printf,unit, format='(a)', 'Componente   magT       R_e      R_d       n_sersic    b/a      PA     Mu0     Chi2'
      IF KEYWORD_SET(readini) THEN read_ini,READINI_FILE,name=name_comp,comp=comp,sky=sky ELSE readlog,LOG_FILE,name=name_comp,comp=comp,sky=sky,chi2=chi2
      
      ncomp=N_ELEMENTS(name_comp)

      F=FLTARR(ncomp)
      FOR l=0,Ncomp-1 DO BEGIN
         F[l] = 10^(-0.4*comp[l,4])
      ENDFOR
      F_tot=TOTAL(F)
      
      FOR l=0,ncomp-1 DO BEGIN
         
         im_comp=READFITS(SUBCOMP_FILE,EXTEN_NO=l+1,/SILENT)
         xc=comp[l,0]
         yc=comp[l,2]
         mag=comp[l,4]
         re=comp[l,6]
         rd=comp[l,8]
         n=comp[l,10]
         q=comp[l,12]
         pa=comp[l,14]
         
         IF STRCMP(name_comp[l],'sersic') EQ 1 AND n NE 1. THEN BEGIN
            mu0=-2.5*ALOG10(im_comp[xc,yc]/exptime/(pixscale*pixscale))+zp
         ENDIF ELSE IF STRCMP(name_comp[l],'sersic') EQ 1 AND n EQ 1 THEN BEGIN
            rd=re/1.678
            mu0=mag + 2.5*alog10(2*!pi*rd*rd*pixscale*pixscale)
         ENDIF ELSE IF STRCMP(name_comp[l],'expdisk') EQ 1 THEN BEGIN
            mu0=mag + 2.5*alog10(2*!pi*rd*rd*pixscale*pixscale)
         ENDIF ELSE IF STRCMP(name_comp[l],'psf') EQ 1 THEN BEGIN
            mu0=-2.5*ALOG10(im_comp[xc,yc]/exptime/(pixscale*pixscale))+zp
         ENDIF 

         FT=F[l]/F_tot
         
         PRINTF,unit,name_comp[l],mag,re,rd,n,q,pa,mu0,ft,FORMAT='(a,2x,8(f8.4,2x))'
         ENDFOR
      FREE_LUN,unit
	

END
