# SANS GEV SPATIAL #

1. SMITH 
## FIT d'un Smith sur la donnee non transformee. ##
    smith<-fitmaxstab(data,locations, cov.mod="gauss",fit.marge=TRUE)
==> Tourne en rond puis erreur de session.


## FIT d'un Smith sur les donnees transformees en Frechet unitaire (marginalement). ##

    > smithfrech<-fitmaxstab(datafrech,locations, cov.mod="gauss",fit.marge=FALSE)
    Warning message:
    In smithfull(data, coord, ..., fit.marge = fit.marge, iso = iso,  :
      Observed information matrix is singular. No standard error will be computed.

    > smithfrech
            Estimator: MPLE 
                Model: Smith 
             Weighted: FALSE 
       Pair. Deviance: 15117017 
                  TIC: NA 
    Covariance Family: Gaussian 

    Estimates
      Marginal Parameters:
      Not estimated.
      Dependence Parameters:
        cov11      cov12      cov22  
    6.531e+09  1.450e+09  1.921e+09  

    Optimization Information
      Convergence: successful 
      Function Evaluations: 208 

==> Le modele converge bien. Les standard errors ne peuvent pas etre calculees mais c est normal.

2. SCHLATHER
## FIT d'un Schalther sur la donnee non transformee. ##
   > schlather<-fitmaxstab(data,locations, cov.mod="whitmat",fit.marge=TRUE)
> Tourne en rond puis erreur de session.

## FIT d'un Schalther sur les donnees transformees en Frechet unitaire (marginalement). ##
    > schlatherfrech.whitmat <- fitmaxstab(datafrech,locations, cov.mod="whitmat",fit.marge=FALSE)
    There were 30 warnings (use warnings() to see them)

    > warnings()
    Warning messages:
    1: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    2: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    3: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    4: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    5: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    6: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    7: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    8: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    9: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    10: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    11: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    12: In funS1(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    13: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    14: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    15: In funS1(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    16: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    17: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    18: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    19: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    20: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    21: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    22: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    23: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    24: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    25: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    26: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    27: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    28: In nplk(p[1], p[2], p[3], ...) : underflow occurred in 'gammafn'
    29: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'
    30: In nplk(p[1], p[2], p[3], ...) : value out of range in 'gammafn'


    > schlatherfrech.whitmat
            Estimator: MPLE 
                Model: Schlather 
             Weighted: FALSE 
       Pair. Deviance: 15305201 
                  TIC: 15307696 
    Covariance Family: Whittle-Matern 

    Estimates
      Marginal Parameters:
      Assuming unit Frechet.

      Dependence Parameters:
       nugget      range     smooth  
    1.096e-07  8.770e+04  7.663e-01  

    Standard Errors
       nugget      range     smooth  
    3.480e-03  1.268e+04  7.666e-02  

    Asymptotic Variance Covariance
            nugget      range       smooth    
    nugget   1.211e-05  -3.765e+01   2.528e-04
    range   -3.765e+01   1.609e+08  -9.118e+02
    smooth   2.528e-04  -9.118e+02   5.877e-03

    Optimization Information
      Convergence: successful 
      Function Evaluations: 249

==> Le modele converge bien. Mais il y a des warnings() qui selon moi revele un probleme d optimisation dans l estimation des parametres.


# AVEC GEV SPATIAL #

## Definition simple d'evolution spatial des parametres de la GEV ##
    > loc.form <- loc ~ bathy
    > scale.form <- scale ~ 1
    > shape.form <- shape ~ 1
## Fit seulement de l evolution spatial de la GEV ##
    > spatgevbath<-fitspatgev(data=data,covariables=marg.cov,loc.form=loc.form,scale.form=scale.form,shape.form=shape.form)
    > spatgevbath
                Model: Spatial GEV model
       Deviance: 103941.4 
            TIC: 104211.9 

        Location Parameters:
    locCoeff1  locCoeff2  
      1.83412    0.00114  
           Scale Parameters:
    scaleCoeff1  
         0.8095  
           Shape Parameters:
    shapeCoeff1  
        -0.1264  

    Standard Errors
      locCoeff1    locCoeff2  scaleCoeff1  shapeCoeff1  
      4.499e-02    2.559e-05    1.654e-02    1.071e-02  

    Asymptotic Variance Covariance
                 locCoeff1   locCoeff2   scaleCoeff1  shapeCoeff1
    locCoeff1     2.024e-03  -6.252e-07   1.389e-04   -8.812e-05 
    locCoeff2    -6.252e-07   6.548e-10   1.625e-07   -6.814e-08 
    scaleCoeff1   1.389e-04   1.625e-07   2.734e-04   -2.972e-05 
    shapeCoeff1  -8.812e-05  -6.814e-08  -2.972e-05    1.146e-04 

    Optimization Information
      Convergence: successful 
      Function Evaluations: 143

On va donc se servir de ces premieres estimations pour ajuster un modèle de schlather avec GEV spatial.
## Definition des points de depart pour la fonction d optimisation ##
    > start=list(locCoeff1=c(1.83412),locCoeff2=c(0.00114),
               scaleCoeff1=c(0.8095),
               shapeCoeff1=c(-0.1264),
               nugget=c(0),range=c(8.5e+04),smooth=c(0))
===> Mais comment choisir nugget range smooth sans premiere approximation ?!
## Ce qui nous donne ##
    > schlather.whitmat.bathy<-fitmaxstab(data,locations,cov.mod="whitmat",
                                              loc.form, scale.form, shape.form,
                                              marg.cov=marg.cov,
                                        start=start)
    There were 21 warnings (use warnings() to see them)
    > warnings()
    Warning messages:
    1: In schlatherform(data, coord, cov.mod = cov.mod, ...,  ... :
      negative log-likelihood is infinite at starting values
    2: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    3: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    4: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    5: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    6: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    7: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    8: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    9: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    10: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    11: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    12: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    13: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    14: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    15: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    16: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      value out of range in 'gammafn'
    17: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    18: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    19: In nplk(p[1], p[2], p[3], p[4], p[5], p[6], p[7], ...) :
      underflow occurred in 'gammafn'
    20: In schlatherform(data, coord, cov.mod = cov.mod, ...,  ... :
      optimization may not have succeeded
    21: In schlatherform(data, coord, cov.mod = cov.mod, ...,  ... :
      Observed information matrix is singular. No standard error will be computed.

    > schlather.whitmat.bathy
            Estimator: MPLE 
                Model: Schlather 
             Weighted: FALSE 
       Pair. Deviance: 2e+15 
                  TIC: NA 
    Covariance Family: Whittle-Matern 

    Estimates
      Marginal Parameters:
        Location Parameters:
    locCoeff1  locCoeff2  
         1415       1414  
           Scale Parameters:
    scaleCoeff1  
           1414  
           Shape Parameters:
    shapeCoeff1  
           1413  
      Dependence Parameters:
       nugget      range     smooth  
        0.994  86413.541     17.763  

    Optimization Information
      Convergence: 0 
      Function Evaluations: 56 
===> Ne converge pas 