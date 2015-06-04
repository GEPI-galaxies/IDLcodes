FUNCTION img2profile,img,angle,center,width

  hsize = (SIZE(img))[1]
  vsize = (SIZE(img))[2]

  img_rot=ROT(img,angle,1.,center[0],center[1],MISSING=0,/INTERP)
  
  profile_n=img_rot[0:hsize-1,center[1]-width:center[1]+width]
  IF width GT 0 THEN profile=TOTAL(profile_n,2)/(SIZE(profile_n))[2] ELSE profile=profile_n

  RETURN,profile

END