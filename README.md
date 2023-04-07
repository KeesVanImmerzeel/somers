
## R-package 'somers'

<!-- badges: start -->
<!-- badges: end -->

Bereken vlakdekkend de CO2 uitstoot met de [SOMERS](https://www.nobveenweiden.nl/wp-content/uploads/2022/12/SOMERS-1.0-hoofdrapport-2022-v4.0.pdf) methodiek (*versie 1.0*). De informatie die hiervoor wordt gebruikt is:

* Archetype (bodemtype): 'hV','pV','kV','hVz','kVz','V','Vz','aVz'.

* Bron (dataset): 'grfr', 'ov', 'wn' (Groningen/Friesland, Overijssel, West Nederland).

* Type perceel (maatregel): 'ref', 'owd', 'dd' (referentie, onderwaterdrainage, drukdrainage).

* Winterpeil: 'gelijk aan zomerpeil', '10 cm beneden zomerpeil', '20 cm beneden zomerpeil'.

* Variabele: 'CO2-uitstoot.min', 'CO2-uitstoot.mediaan', 'CO2-uitstoot.max'.

* Kwel scenario: 'lichte kwel', 'lichte wegzijging'. *Gegevens met betrekking tot kwel zijn alleen beschikbaar in de dataset van Overijssel.*

* Scenario (bij drukdrainage): 'medium_peil', 'hoog_peil'. *Dit gegeven is alleen relevant bij de toepassing van drukdrainage als maatregel.*

De CO2 uitstoot wordt door middel van interpolatie berekend als functie van de **slootafstand** en de **ontwateringsdiepte**.  


# Achtergrond
Met het registratiesysteem SOMERS (Soil Organic Matter Emission Registration System) zijn 
[rekenregels](https://www.nobveenweiden.nl/rekenregels-somers/) bepaald die als indicatieve ondersteuning kunnen dienen bij het bepalen van de effecten van voorgestelde maatregelen op de broeikasgasuitstoot in het veenweidegebied.

Het zijn inschattingen voor ‘karakteristieke’ situaties in drie verschillende gebieden in Nederland. De modellen waarmee deze rekenregels zijn opgesteld hebben als hoofddoel het monitoren van de reductie van emissie van broeikasgassen, en kijken dus naar veenweidegebieden met een peilbesluit in heel Nederland.

De rekenregels dienen als *indicatieve* ondersteuning bij het bepalen van de effecten van voorgestelde maatregelen op de CO2 -uitstoot in het veenweidegebied. Daarnaast bieden de rekenregels ook een onzekerheidsmarge en dienen ze als handvat voor ruimtelijke verschillen van de effecten van maatregelen. 


# Installatie

Installeer de ontwikkel versie van 'somers' vanuit [GitHub](https://github.com/) met:

``` r
# install.packages('devtools')
devtools::install_github('KeesVanImmerzeel/somers')
```

# Voorbeeld

Met een voorbeeld raster 'example_input.tif' wordt hieronder met de routine `smrs_CO2_uitstoot()` vlakdekkend de CO2 uitstoot berekend. 

``` r
library(somers)
r <- terra::rast(system.file('extdata', 'example_input.tif', package='somers', mustWork=TRUE))
CO2_uitstoot <- smrs_CO2_uitstoot(r)
```

Inspiratie voor het samenstellen van een invoer raster en het gebruik van deze package kunt u vinden in de folder `data-raw` waarin het document `example_for_use.r` is opgenomen.

De correctheid van een raster kan worden gecontroleerd met de functie `smrs_validate_input()`:

``` r
library(somers)
r <- terra::rast(system.file('extdata', 'example_input.tif', package='somers', mustWork=TRUE))
foutcodes <- smrs_validate_input(r)
```

De betekenis van de resulterende foutcodes is als volgt

| Foutcode |                       Betekenis                      |
|:--------:|:----------------------------------------------------:|
|     0    |                    geldige invoer.                   |
|    -1    |                     ongeldige id.                    |
|    -2    |              drooglegging out of range.              |
|    -3    |              slootafstand out of range.              |
|    -4    |          ongeldige raster layer naam/namen.          |
|    -5    | onvoldoende gegevens (1 of meer layers bevatten NA). |


## Details


**Interpolatie**

Voor de interpolatie wordt gebruik gemaakt van de [akima](https://cran.r-project.org/web/packages/akima/index.html) r-package.  

Er vindt geen extrapolatie plaats bij het berekenen van de CO2-uitstoot. De grenzen waarbinnen interpolatie kan plaatsvinden op basis van de slootafstand en ontwateringsdiepte zijn afhankelijk van de beschikbare informatie in de desbetreffende data set:

| Bron (data set) | Code | Drooglegging (m-mv) | Slootafstand (m) |
|:---------------:|:----:|:-------------------:|:----------------:|
|       grfr      |   1  |       0.2-1.2       |      40-140      |
|        ov       |   2  |       0.2-0.8       |       40-80      |
|        wn       |   3  |       0.2-0.8       |       40-80      |

Als een opgegeven slootafstand en/of ontwateringsdiepte buiten deze grenzen ligt, wordt geen CO2 uitstoot berekend: het resultaat is dan NA.


**Invoer**

Met de functie 'smrs_CO2_uitstoot' wordt de CO2 uitstoot berekend. De invoer parameter van deze functie is een raster (type 'SpatRaster', zie [terra](https://cran.r-project.org/web/packages/terra/index.html) package) met de volgende layers:

* **id**: Code (integer) voor de selectie van de tabellen van de datasets van SOMERS (zie hieronder).
* **drooglegging**: Drooglegging (m-mv).
* **slootafstand**: Slootafstand (m).


**id**

De 'id' is een getal bestaande uit 7 cijfers volgens de onderstaande tabel.

| Cijfer # |          Parameter          |                                       Waarden                                      |
|:--------:|:---------------------------:|:----------------------------------------------------------------------------------:|
|     1    |     archetype(bodemtype)    | 1='hV',2='pV',3='kV',4='hVz',5='kVz',6='V',7='Vz',8='aVz'                          |
|     2    |        bron (dataset)       |  1='grfr', 2='ov', 3='wn' (resp. (Groningen/Friesland, Overijssel, West Nederland) |
|     3    |   type perceel (maatregel)  | 1='ref', 2='owd', 3='dd' (resp. referentie, onderwaterdrainage, drukdrainage).     |
|     4    |          winterpeil         | 1='gelijk aan zomerpeil', 2='10 cm beneden zomerpeil', 3='20 cm beneden zomerpeil' |
|     5    |          variabele          | 1='CO2-uitstoot.min', 2='CO2-uitstoot.mediaan', 3='CO2-uitstoot.max'               |
|     6    |        kwel scenario        | 0=niet van toepassing, 1='lichte kwel', 2='lichte wegzijging'                      |
|     7    | scenario (bij drukdrainage) | 0=niet van toepassing, 1='medium_peil', 2='hoog_peil'                              |


**Bodemcode 'aVc'**

Niet alle bodemtype codes komen voor in het 'LETTER' veld van de bodemkaart. Opgemerkt wordt dat bodemkundig de code 'aVc' valt onder de 'madeveengronden'. Dit is code 'aVz' (8) in het model. Met andere woorden: daar waar in de bodemkaart de code 'aVc' voorkomt kan deze voor de bepaling van de CO2 uitstoot volgens SOMERS worden 'vertaald' naar de code 'aVz' (8). Hou er wel rekening mee dat er een verschil is wat betreft de veendikte. Bij 'aVz' bodems is de veendikte kleiner dan in 'aVz' bodems (resp. 50 cm en 70 cm). Als dus de uitstoot van de 'aVz' bodems wordt gebruikt op locaties waar feitelijk een 'aVc' bodem aanwezig is, leidt dat mogelijk tot een *onderschatting* van de CO2 emissie.


**Beperkingen**

Niet in iedere dataset is elke parameter combinatie opgenomen. De onderstaande tabel geeft een overzicht van de parameter waarden per dataset.

| Parameter | dataset 1 (grfr) | dataset 2 (ov) | dataset 3 (wn) |
|:---:|:---:|:---:|:---:|
| archetype(bodemtype) | 1='hV',2='pV',3='kV',4='hVz',5='kVz',6='V',7='Vz',8='aVz' | 1='hV',2='pV',3='kV',4='hVz',5='kVz',6='V',7='Vz',8='aVz' | 1='hV',2='pV',3='kV',4='hVz',5='kVz',6='V',7='Vz',8='aVz' |
| Slootafstand (m) | 40-140 | 40-80 | 40-80 |
| Kwel scenario | 0=niet van toepassing | 1='lichte kwel', 2='lichte wegzijging' | nvt |
| Type Perceel | 1='ref', 2='owd', 3='dd' | 1='ref', 2='owd', 3='dd' | 1='ref', 2='owd', 3='dd' |
| Scenario | 0=niet van toepassing, 1='medium_peil', 2='hoog_peil' | 0=niet van toepassing | 0=niet van toepassing |
| Drooglegging (m-mv) | 0.2 - 1.2 | 0.2 - 0,8 | 0.2 - 0,8 |
| Winterpeil | 1='gelijk aan zomerpeil', 3='20 cm beneden zomerpeil' | 1='gelijk aan zomerpeil', 2=10 cm beneden zomerpeil | 1='gelijk aan zomerpeil', 2='10 cm beneden zomerpeil' |

Als er geen informatie aanwezig is bij een gespecificeerde combinatie van (archetype, bron, Type Perceel, Winterpeil, Kwel scenario,  Scenario), dan geeft de routine `smrs_validate_input()` een foutcode -1 (ongeldige id). deze routine geeft teven een foutcode als de gespecificeerde drooglegging en/of slootafstand buiten de range is van hetgeen is opgenomen in de dataset (bron): foutcodes resp. -2 en -3. De routine `smrs_CO2_uitstoot()` geeft in dat geval geen uitvoer (--> NA als resultaat).

