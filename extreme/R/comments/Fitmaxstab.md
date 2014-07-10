On considere dans cette etude les 97 sites. 

# Max mensuels hivernaux #
Dans un premier temps j ai regarde les max mensuels hivernaux (jan feb mar apr sep oct nov dec).
Ponctuellement les fits GEV sont relativement bons à mon sens.

## SANS GEV SPATIAL ##

1. SMITH

### FIT d'un Smith sur la donnee non transformee. ###
    smith<-fitmaxstab(data,locations, cov.mod="gauss",fit.marge=TRUE)
==> Tourne en rond puis erreur de session.


### FIT d'un Smith sur les donnees transformees en Frechet unitaire (marginalement). ###

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

==> Le modele converge bien. Les standard errors ne peuvent pas etre calculees...

2. SCHLATHER

### FIT d'un Schalther sur la donnee non transformee. ###
    > schlather<-fitmaxstab(data,locations, cov.mod="whitmat",fit.marge=TRUE)
==> Tourne en rond puis erreur de session.

### FIT d'un Schalther sur les donnees transformees en Frechet unitaire (marginalement). ###
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

==> Le modele converge bien. Mais il y a des warnings() qui selon moi revelent un probleme d optimisation dans l estimation des parametres.


## AVEC GEV SPATIAL ##

### Definition simple d'evolution spatial des parametres de la GEV ###
    > loc.form <- loc ~ bathy
    > scale.form <- scale ~ 1
    > shape.form <- shape ~ 1
### Fit seulement de l'evolution spatial de la GEV ###
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
### Definition des points de depart pour la fonction d optimisation ###
    > start=list(locCoeff1=c(1.83412),locCoeff2=c(0.00114),
               scaleCoeff1=c(0.8095),
               shapeCoeff1=c(-0.1264),
               nugget=c(0),range=c(8.5e+04),smooth=c(0))
===> Mais comment choisir nugget range smooth sans premiere approximation ?!
### Ce qui nous donne ###
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

# Max annuels #
Au vu de l'explosion en ressource de R (session aborted), je me suis dis que je pouvais eventuellement alleger le calcul en ne considerant que les max annuels.

### FIT d'un Smith sur la donnee non transformee. ###
    smith<-fitmaxstab(data,locations, cov.mod="gauss",fit.marge=TRUE)
==> Tourne en rond puis erreur de session.


### FIT d'un Smith sur les donnees transformees en Frechet unitaire (marginalement). ###

    > smithfrech<-fitmaxstab(datafrech,locations, cov.mod="gauss",fit.marge=FALSE)

    > smithfrech
            Estimator: MPLE 
                Model: Smith 
             Weighted: FALSE 
       Pair. Deviance: 1942671 
                  TIC: 1943053 
    Covariance Family: Gaussian 

    Estimates
      Marginal Parameters:
      Not estimated.
      Dependence Parameters:
        cov11      cov12      cov22  
    3.890e+09  5.440e+08  1.262e+09  

    Standard Errors
       cov11     cov12     cov22  
    81159361  83648298  60979828  

    Asymptotic Variance Covariance
           cov11       cov12       cov22     
    cov11   6.587e+15   5.721e+14  -9.858e+12
    cov12   5.721e+14   6.997e+15   5.071e+15
    cov22  -9.858e+12   5.071e+15   3.719e+15

    Optimization Information
      Convergence: successful 
      Function Evaluations: 90 

==> Le modele converge.

# Profiling #
J'ai essaye de faire du profiling pour voir ou est ce que le calcul se ralentissait.

## En stoppant le calcul (full estimation) avec donnee max annuelle ##
    > Rprof("example.prof")
    > smith<-fitmaxstab(data,locations, cov.mod="gauss",fit.marge=TRUE)

    > Rprof(NULL)
    > summaryRprof("example.prof")
    $by.self
                    self.time self.pct total.time total.pct
    ".C"                15.80    76.77      15.80     76.77
    "FUN"                1.34     6.51       2.12     10.30
    "apply"              1.06     5.15       4.36     21.19
    "unlist"             1.00     4.86       1.02      4.96
    "getwd"              0.18     0.87       0.18      0.87
    "fitextcoeff"        0.14     0.68       6.22     30.22
    "match.arg"          0.14     0.68       0.60      2.92
    "pmatch"             0.14     0.68       0.14      0.68
    "aperm.default"      0.12     0.58       0.12      0.58
    "eval"               0.08     0.39       0.42      2.04
    "match"              0.06     0.29       0.08      0.39
    "any"                0.06     0.29       0.06      0.29
    "array"              0.04     0.19       0.04      0.19
    "c"                  0.04     0.19       0.04      0.19
    "is.data.frame"      0.04     0.19       0.04      0.19
    "is.factor"          0.04     0.19       0.04      0.19
    "is.na"              0.04     0.19       0.04      0.19
    "match.call"         0.04     0.19       0.04      0.19
    "sum"                0.04     0.19       0.04      0.19
    "smithfull"          0.02     0.10      20.58    100.00
    ".deparseOpts"       0.02     0.10       0.24      1.17
    "as.double"          0.02     0.10       0.02      0.10
    "double"             0.02     0.10       0.02      0.10
    "grepl"              0.02     0.10       0.02      0.10
    "lapply"             0.02     0.10       0.02      0.10
    "matrix"             0.02     0.10       0.02      0.10
    "mode"               0.02     0.10       0.02      0.10
    "sys.parent"         0.02     0.10       0.02      0.10

On voit bien que le modèle passe du temps dans la fonction ecrite en .C. Nous n avons pas la main dessus.

## Avec l estimation des parametres de dependance uniquement, marge transformee par ailleurs, avec donnee max annuelle ##
    > Rprof("example.prof")
    > smithfrech<-fitmaxstab(datafrech,locations, cov.mod="gauss",fit.marge=FALSE)
    > Rprof(NULL)
    > summaryRprof("example.prof")

    $by.self
                    self.time self.pct total.time total.pct
    ".C"                55.94    92.22      55.94     92.22
    "FUN"                1.38     2.27       2.26      3.73
    "apply"              1.04     1.71       4.24      6.99
    "unlist"             0.66     1.09       0.68      1.12
    "fitextcoeff"        0.16     0.26       6.20     10.22
    "array"              0.16     0.26       0.16      0.26
    ".deparseOpts"       0.12     0.20       0.26      0.43
    "deparse"            0.10     0.16       0.52      0.86
    "aperm.default"      0.10     0.16       0.10      0.16
    "as.double"          0.10     0.16       0.10      0.16
    "matrix"             0.10     0.16       0.10      0.16
    "match"              0.08     0.13       0.12      0.20
    "pmatch"             0.08     0.13       0.08      0.13
    "match.arg"          0.06     0.10       0.72      1.19
    "eval"               0.06     0.10       0.64      1.06
    "double"             0.06     0.10       0.06      0.10
    [...]

    $by.total
                        total.time total.pct self.time self.pct
    "fitmaxstab"             60.64     99.97      0.00     0.00
    "smithfull"              60.64     99.97      0.00     0.00
    ".C"                     55.94     92.22     55.94    92.22
    "nplk"                   53.96     88.95      0.00     0.00
    "<Anonymous>"            53.70     88.53      0.00     0.00
    ".External2"             53.68     88.49      0.00     0.00
    "fn"                     53.68     88.49      0.00     0.00
    "optim"                  53.68     88.49      0.00     0.00
    "fitcovmat"               6.22     10.25      0.00     0.00
    "fitextcoeff"             6.20     10.22      0.16     0.26
    "apply"                   4.24      6.99      1.04     1.71
    "FUN"                     2.26      3.73      1.38     2.27
Nous avons le meme comportement. Nous pouvons note que la fonction .C est appellée par nplk visiblement.

N.B. On peut avoir de beaux schemas de profiling par :
    require(profr)
    require(ggplot2)
    x = profr(smithfrech<-fitmaxstab(datafrech,locations, cov.mod="gauss",fit.marge=FALSE))
    ggplot(x
ou
    plotProfileCallGraph(readProfileData("example.prof"),score = "total")