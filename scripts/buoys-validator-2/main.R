source("validate1station.R")

# "61002" = "Lion",
# "61004" = "Porquerolles",
# "61005" = "Cap Corse",
# "61187" = "Nice",
# "61188" = "Banyuls",
# "61190" = "Sete",
# "61191" = "Leucate",
# "61289" = "Le Planier",
# "61431" = "Espiguette",

df2 <- validate1station(station = "61431",
                 year = 2009,
                 candhisdir = "input/candhis/donnees_candhis_cerema", 
                 hymexdir = "input/GOL-buoy-hymex", 
                 ounpdir = "input/model/MEGAGOL2015-a/ounp",
                 plot = TRUE,
                 plotType = "ts")
