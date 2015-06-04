pro display_expdisk,fit,unit,index,sep,mu0=mu0,ft=ft

IF KEYWORD_SET(mu0) AND KEYWORD_SET(ft) THEN text_plus= ' & ' $
+STRN(mu0,FORMAT='(f6.2)')+','+STRN(FT,FORMAT='(f6.2)') ELSE text_plus=''

text = 'EXPDISK & ' $
+'['+STRN(fit[index,0],FORMAT='(f8.2)')+sep+STRN(fit[index,1],FORMAT='(f8.2)')+','+STRN(fit[index,2],FORMAT='(f8.2)')+sep+STRN(fit[index,3],FORMAT='(f8.2)')+ '] &' $
+STRN(fit[index,4],FORMAT='(f8.2)')+sep+STRN(fit[index,5],FORMAT='(f8.2)')+' & &' $
+STRN(fit[index,8],FORMAT='(f8.2)')+sep+STRN(fit[index,9],FORMAT='(f8.2)')+' & & ' $
+STRN(fit[index,12],FORMAT='(f8.2)')+sep+STRN(fit[index,13],FORMAT='(f8.2)')+' & ' $
+STRN(fit[index,14],FORMAT='(f8.2)')+sep+STRN(fit[index,15],FORMAT='(f8.2)')+text_plus+' \\ \hline'
printf,unit,text,FORMAT='(a)'

end

pro display_sersic,fit,unit,index,sep,mu0=mu0,ft=ft

IF KEYWORD_SET(mu0) AND KEYWORD_SET(ft) THEN text_plus= ' & ' $
+STRN(mu0,FORMAT='(f6.2)')+','+STRN(FT,FORMAT='(f6.2)') ELSE text_plus=''

printf,unit,'SERSIC & ' $
+'['+STRN(fit[index,0],FORMAT='(f8.2)')+sep+STRN(fit[index,1],FORMAT='(f8.2)')+','+STRN(fit[index,2],FORMAT='(f8.2)')+sep+STRN(fit[index,3],FORMAT='(f8.2)')+ '] &' $
+STRN(fit[index,4],FORMAT='(f8.2)')+sep+STRN(fit[index,5],FORMAT='(f8.2)')+' & ' $
+STRN(fit[index,6],FORMAT='(f8.2)')+sep+STRN(fit[index,7],FORMAT='(f8.2)')+' & & ' $
+STRN(fit[index,10],FORMAT='(f8.2)')+sep+STRN(fit[index,11],FORMAT='(f8.2)')+' & ' $
+STRN(fit[index,12],FORMAT='(f8.2)')+sep+STRN(fit[index,13],FORMAT='(f8.2)')+' & ' $
+STRN(fit[index,14],FORMAT='(f8.2)')+sep+STRN(fit[index,15],FORMAT='(f8.2)')+text_plus+'\\ \hline',FORMAT='(a)'

end

pro display_psf,fit,unit,index,sep,mu0=mu0,ft=ft

IF KEYWORD_SET(mu0) AND KEYWORD_SET(ft) THEN text_plus= ' & ' $
+STRN(mu0,FORMAT='(f6.2)')+','+STRN(FT,FORMAT='(f6.2)') ELSE text_plus=''

printf,unit,'PSF & ' $
+'['+STRN(fit[index,0],FORMAT='(f8.2)')+sep+STRN(fit[index,1],FORMAT='(f8.2)')+','+STRN(fit[index,2],FORMAT='(f8.2)')+sep+STRN(fit[index,3],FORMAT='(f8.2)')+ '] &' $
+STRN(fit[index,4],FORMAT='(f8.2)')+sep+STRN(fit[index,5],FORMAT='(f8.2)')+' & & & & & '+text_plus+' \\ \hline', FORMAT='(a)' 

end

pro make_frame,name,zz,Mr,ra,dec,pixscale,band,mu0r,bt,dt,BAXIS=baxis,READINI=readini

READCOL,name+'_comp.txt',name_comp2,mag,re,rd,n,q,pa,mu0,ft,FORMAT='(a,f,f,f,f,f,f,f)',/SILENT

IF KEYWORD_SET(readini) THEN BEGIN
   filename=name+'.in'
   read_ini,filename,name=name_comp,comp=comp,sky=sky
   chi2=[0,0]
ENDIF ELSE BEGIN
   filename = name+'.log'
   readlog,filename,name=name_comp,comp=comp,sky=sky,chi2=chi2
ENDELSE
ncomp = N_ELEMENTS(name_comp)

OPENU,unit,'results_galfit_'+name+'.tex',/APPEND,/GET_LUN

PRINTF,unit,'\begin{frame}'
PRINTF,unit,'\tiny'
PRINTF,unit,'\begin{columns}'
PRINTF,unit,'\column{0.3\textwidth}'
PRINTF,unit,name+' \\'
PRINTF,unit,'bande '+band+' \\'
PRINTF,unit,'RA = '+STRTRIM(STRING(ra,FORMAT='(f12.7)'),2)+' \\'
PRINTF,unit,'DEC = '+STRTRIM(STRING(dec,FORMAT='(f12.7)'),2)+' \\'
PRINTF,unit,'z = '+STRTRIM(STRING(zz,FORMAT='(f8.3)'),2)+' \\'
PRINTF,unit,'Mr = '+STRTRIM(STRING(Mr,FORMAT='(f8.3)'),2)+' \\'
;printf,unit,'Rhalf = '+strtrim(string(rhalf_kpc,format='(f8.3)'),2)+' kpc  \\'
printf,unit,'\textcolor{red}{$\mu_0$(r) = '+strtrim(string(mu0r,format='(f8.3)'),2)+' mag.arcsec$^{-2}$} \\'
PRINTF,unit,'\column{0.6\textwidth}'
PRINTF,unit,'\hspace{1cm} image \hspace{1.7cm} model \hspace{1.7cm} residu \\'
PRINTF,unit,'\includegraphics[width=0.33\textwidth]{'+name+'_im.eps}'
PRINTF,unit,'\includegraphics[width=0.33\textwidth]{'+name+'_mod.eps}'
PRINTF,unit,'\includegraphics[width=0.33\textwidth]{'+name+'_res.eps} \\'
PRINTF,unit,'\end{columns}'

file_ini = name+'.in'
read_ini,file_ini,name=name_comp_ini,comp=comp_ini,sky=sky_ini
ncomp_ini = N_ELEMENTS(name_comp_ini)
ind_sersic = 0
ind_expdisk = 0
ind_psf = 0

PRINTF,unit,'Initial conditions : \\'

PRINTF,unit,'\begin{tabular}{|l|l|l|l|l|l|l|l|}'
PRINTF,unit,'\hline'
PRINTF,unit,'component & [x,y] & mag (r AB) & Re (pix) & Rd (pix) & n & b/a & PA (deg) \\ \hline'

FOR k=0,Ncomp_ini-1 DO BEGIN
   IF STRCMP(name_comp_ini[k],'sersic') EQ 1 THEN display_sersic,comp_ini,unit,k,'/'
   IF STRCMP(name_comp_ini[k],'expdisk') EQ 1 THEN display_expdisk,comp_ini,unit,k,'/'
   IF STRCMP(name_comp_ini[k],'psf') EQ 1 THEN display_psf,comp_ini,unit,k,'/'
ENDFOR

PRINTF,unit,'\end{tabular} \newline'

PRINTF,unit,'SKY : '+STRN(sky_ini[2],FORMAT='(f12.3)')+' ; '+STRN(sky_ini[3],FORMAT='(i)')

 PRINTF,unit,'\begin{columns}'
 PRINTF,unit,'\column{0.9\textwidth}'
 IF KEYWORD_SET(baxis) THEN BEGIN
    PRINTF,unit,'\includegraphics[width=0.35\textwidth]{'+name+'_profile_baxis.eps}' 
    PRINTF,unit,'\includegraphics[width=0.35\textwidth]{'+name+'_muprofile_baxis.eps}'
    PRINTF,unit,'\includegraphics[width=0.35\textwidth]{'+name+'_resprofile_baxis.eps} \\'
 ENDIF ELSE BEGIN
    PRINTF,unit,'\includegraphics[width=0.35\textwidth]{'+name+'_profile.eps}' 
    PRINTF,unit,'\includegraphics[width=0.35\textwidth]{'+name+'_muprofile.eps}'
    PRINTF,unit,'\includegraphics[width=0.35\textwidth]{'+name+'_resprofile.eps} \\'
 ENDELSE
    PRINTF,unit,'\column{0.1\textwidth}'

;IF Ncomp GE 2 THEN BEGIN
;   printf,unit,'\begin{center}'
;   FOR k=0,Ncomp-1 DO BEGIN
   
;      printf,unit,'\includegraphics[width=0.7\textwidth]{'+name+'_subcomp'+STRN(k+1,FORMAT='(i)')+'.eps} \\ '
;      char = name_comp[k]
;      IF STRCMP(name_comp[k],'sersic') EQ 1 THEN char = char+' ; re = '+STRN(comp[k,6]*pixscale,FORMAT='(f8.2)') + ' arcsec '
;      IF STRCMP(name_comp[k],'expdisk') EQ 1 THEN char = char+' ; re = '+STRN(comp[k,8]*1.678*pixscale,FORMAT='(f8.2)') + ' arcsec '
;      printf,unit,char+' \\'
;   ENDFOR 
;   printf,unit,'\end{center}'
;ENDIF
PRINTF,unit,'\end{columns}'

PRINTF,unit,'\vspace{0.2cm}'
PRINTF,unit,'\begin{tabular}{|l|l|l|l|l|l|l|l|}'
PRINTF,unit,'\hline'
PRINTF,unit,'comp & [x,y] & mag ('+band+' AB) & Re (pix) & Rd (pix) & n & b/a & PA (deg)  \\ \hline'

FOR k=0,Ncomp-1 DO BEGIN
   IF STRCMP(name_comp[k],'sersic') EQ 1 THEN display_sersic,comp,unit,k,'$\pm$'
   IF STRCMP(name_comp[k],'expdisk') EQ 1 THEN display_expdisk,comp,unit,k,'$\pm$'
   IF STRCMP(name_comp[k],'psf') EQ 1 THEN display_psf,comp,unit,k,'$\pm$'
ENDFOR

PRINTF,unit,'\end{tabular} \newline'

text=''
FOR k=0,ncomp-1 DO BEGIN
   text=text+'$\mu_0$['+STRN(k+1,FORMAT='(i)')+']='+STRN(mu0[k],FORMAT='(f6.2)')+' ; '
ENDFOR
text=text+' \newline '
FOR k=0,ncomp-1 DO BEGIN
   text=text+'F/T['+STRN(k+1,FORMAT='(i)')+']='+STRN(FT[k],FORMAT='(f6.2)')+' ; '
ENDFOR
text=text+' \newline '

text=text+' \textcolor{red}{B/T='+STRN(bt,FORMAT='(f12.2)')+' ; D/T='+STRN(dt,FORMAT='(f12.2)')+ '} ; SKY = '+STRN(sky[2],format='(f12.3)') + ' ; $\chi^2/\nu$ = '+STRN(chi2[1],FORMAT='(f8.4)') + '\\' 


printf,unit,text
PRINTF,unit,'\end{frame}'

FREE_LUN,unit

END

PRO display_results,name,ra,dec,zz,Mr,pixscale,band,mu0r,bt,dt,cleaneps=cleaneps,readini=readini

OPENW,unit,'results_galfit_'+name+'.tex',/GET_LUN   ;; slides resultats

PRINTF,unit,'% !TEX encoding = IsoLatin'
PRINTF,unit,'\documentclass[8pt]{beamer}'
PRINTF,unit,'\usepackage{graphicx}'
PRINTF,unit,'\usepackage{tabularx}'
PRINTF,unit,'\setbeamersize{text margin left=0.1cm}'
PRINTF,unit,'\setbeamersize{text margin right=0.1cm}'

PRINTF,unit,'\begin{document}'
FREE_LUN,unit

make_frame,name,zz,Mr,ra,dec,pixscale,band,mu0r,bt,dt,readini=readini
make_frame,name,zz,Mr,ra,dec,pixscale,band,mu0r,bt,dt,/baxis,readini=readini

openu,unit,'results_galfit_'+name+'.tex',/append,/get_lun

printf,unit,'\end{document}'

free_lun,unit

;compilation du fichier .tex
SPAWN,'latex results_galfit_'+name+'.tex'
SPAWN,'dvipdf results_galfit_'+name+'.dvi'
SPAWN,'rm results_galfit_'+name+'.toc results_galfit_'+name+'.aux results_galfit_'+name+'.dvi  results_galfit_'+name+'.log results_galfit_'+name+'.nav  results_galfit_'+name+'.out results_galfit_'+name+'.snm results_galfit_'+name+'.tex'

IF KEYWORD_SET(cleaneps) THEN SPAWN,'rm '+name+'_*profile*.eps '+name+'_im.eps '+name+'_mod.eps '+name+'_res.eps'

END
