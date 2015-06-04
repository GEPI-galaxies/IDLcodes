; NAME:
; 	SEXTRACTOR_MORPHO
;
; PURPOSE:
; 	Prepare files for morphological studies (e.g ellipse/iraf or R_half.pro)
; 	Run sextractor, detect the central object, mask neigbouring companion and replace them by sky background values
;  
; INPUT:
;  	  INFILE = name of the fits file  
;   MASKFILE = name of the mask file in fits with the same size than INFILE. Made from the SEG file.
;    OBJFILE = name of the final file with masked companion
;    SEGFILE = name of the Output file from sextractor showing the detected object
;    OUTFILE = name of the Output file from sextractor giving the position, flux, radius of the detected target
;
; OPTIONAL INPUT KEYWORDS:
; 	MASK_INPUT=  mask file in fits with the same size than INFILE.
;				 If not set, the code will create a mask from the SEG file.
;                The regions to mask have 0 values. 
;			     The mask has been make using the make_mask_Rhalf.pro and ds9 regions 
;   DETECT_THRESH = Detection thresold for sextractor. Default 3.5 sigma
;   ANALYSIS_THRESH = Analysis thresold for sextractor. Default 3.5 sigma
;
; OUTPUT:
; 
; 		Create  MASKFILE, OBJFILE, SEGFILE, OUTFILE files
;
; PROCEDURES CALLED : READFITS , SXADDPAR, WRITEFITS (astrolib)
;
; MODIFICATION HISTORY:
;       Created by Myriam R. 28/04/2015 
; 

PRO Sextractor_morpho, INFILE, ZP, OBJFILE, SEGFILE, MASKFILE, OUTFILE , RUN_SEX=RUN_SEX , MASK_INPUT=MASK_INPUT, DETECT_THRESH=DETECT_THRESH, ANALYSIS_THRESH=ANALYSIS_THRESH

	im = readfits(INFILE,/SILENT,header) ; Load image
	nx=n_elements(im(*,1))
	ny=n_elements(im(1,*))

	;Run Sextractor and reading output files
	
	if KEYWORD_SET(RUN_SEX) then  Run_sextractor, INFILE , ZP, SEGFILE, MASKFILE, OUTFILE , DETECT_THRESH=DETECT_THRESH, ANALYSIS_THRESH=ANALYSIS_THRESH
	seg = readfits(SEGFILE,/SILENT) ; Load the segmentation map from Sextractor
	READCOL,OUTFILE,xcc,ycc,sky,Flux,area,rad,PA,ratio,ellip, FORMAT = '(F,F,F,F,F,F,F,F,F)'

	; Detect target and contaminating objects in the segmentation map
	; Assumes that the target is at the center of the image
	Distance=sqrt((nx/2-xcc)^2+(ny/2-ycc)^2)
	temp=min(Distance,n_obj)
	index_obj = ARRAY_INDICES(Distance, n_obj)
	obj_value = seg[xcc(n_obj),ycc(n_obj)] 
	
	print,'Detect object at position:'
	print,'X='+string(xcc(n_obj))+"Y="+string(ycc(n_obj))+" PA="+string(PA(n_obj))+' Ratio a/b='+string(ratio(n_obj))
    			BsurA2=ratio(n_obj)
                Re2=sqrt(area(n_obj)/3.141592654)/2.      
                PA2=PA(n_obj) -90. ;;; PA=0 for the (0,1) coord in IDL while (1,0) for Sextractor ; counterclock
                xc2=xcc(n_obj)
                yc2=ycc(n_obj)
                Fluxtot2=Flux(n_obj)
                sky2=sky(n_obj)    
	
	print,'N# of contaminating object:' + string(n_elements(xcc) -1)
	Contaminated_index = WHERE(seg NE obj_value AND seg GT 0, n_conta)	
	IF n_conta GE 1 then Contaminated_array = ARRAY_INDICES(seg,Contaminated_index)

	if ~KEYWORD_SET(MASK_INPUT) then begin
	;Create Mask for contaminating objects
	mask=im *0.0 +1.0
	IF n_conta GE 1 then begin
		for i=0, n_elements(Contaminated_index) -1 do begin
		mask[Contaminated_array[0,i],Contaminated_array[1,i]]=0.
		endfor
	ENDIF	
	sxaddpar,header,'TYPE','MASK'
	writefits,MASKFILE,mask,header 
	endif else begin
	mask = readfits(MASK_INPUT,/SILENT) 
	endelse
 	
	; Replace by sky in the contaminated regions
	sky,im(WHERE(mask EQ 1)),skymode,skyvar,/SILENT ;estimate sky background
	obj_im=im
	IF n_conta GE 1 then obj_im(WHERE(mask EQ 0))=randomn(seed,n_elements(WHERE(mask EQ 0)))*skyvar+skymode ;replace contam obj by poisson noise 
	sxaddpar,header,'TYPE','OBJECT'
	sxaddpar,header,'XCENTER',string(xc2)
	sxaddpar,header,'YCENTER',string(yc2)
	sxaddpar,header,'PA',string(PA2)
	sxaddpar,header,'ELLIP',string(BsurA2)
	sxaddpar,header,'RADIUS',string(Re2)
	sxaddpar,header,'FLUXTOT',string(Fluxtot2)
	
	writefits,OBJFILE,obj_im,header ; Saving in file the object image without contaminating objects

END

