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

# df <- validate1station(station = "61191",
#                  year = 2009,
#                  candhisdir = "input/candhis/donnees_candhis_cerema", 
#                  hymexdir = "input/GOL-buoy-hymex", 
#                  ounpdir = "input/model/MEGAGOL2015-a/ounp",
#                  plot = FALSE,
#                  plotType = "qq") #should be 'full', 'ts' or 'qq'


df <- validate1stationRangeYear(station = "61191",
                       yearmin = 2007,
                       yearmax = 2010,
                       candhisdir = "input/candhis/donnees_candhis_cerema", 
                       hymexdir = "input/GOL-buoy-hymex", 
                       ounpdir = "input/model/MEGAGOL2015-a/ounp",
                       plot = TRUE,
                       plotType = "full") #should be 'full', 'ts' or 'qq'

