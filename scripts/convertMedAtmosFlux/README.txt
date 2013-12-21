1) Convertir les fichiers origin en fichier “GMT compliant”

./javaarperafluxconverter.sh ./inputs/origin/ ./inputs/gmtcompliant/

2) Reformat depuis fichier mensuel & grille curvilineaire en fichier annuel & grille rectiligne (voir arperaorig2rec.sh pour détails)

./anyarperaorig2rec.sh ./inputs/gmtcompliant