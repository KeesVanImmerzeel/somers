############ Maak voorbeeld input rasters voor rSIF (SpatRaster).

suppressPackageStartupMessages(library(dplyr))

# Constanten

archetypes <- c("hV","pV","kV","hVz","kVz","V","Vz","aVz") # 1-8
bronnen <- c("grfr", "ov", "wn") # 1-3
type_percelen <- c("ref", "owd", "dd") # 1-3 Opmerking: definieer ook "scenarios"
winterpeilen <- c("gelijk aan zomerpeil", "10 cm beneden zomerpeil", "20 cm beneden zomerpeil") # 1-4
variabelen <- c("CO2-uitstoot.min", "CO2-uitstoot.mediaan", "CO2-uitstoot.max") # 1-3
kwel_scenarios <- c("lichte kwel", "lichte wegzijging") # 1-2 Opmerking: Gegevens mbt kwel zijn alleen beschikbaar in de Overijssel dataset ("bron"="ov")
scenarios <- c("medium_peil", "hoog_peil") # 1-2 Opmerking: alleen van toepassing bij drukdrainage ("type_perceel"="dd")

keys <- c("archetype", "bron", "type_perceel", "winterpeil", "variabele", "kwel_scenario", "scenario")

nr_archetype <- 1:length(archetypes); names(nr_archetype) <- archetypes
nr_bron <- 1:length(bronnen); names(nr_bron) <- bronnen
nr_type_perceel <- 1:length(type_percelen); names(nr_type_perceel) <- type_percelen
nr_winterpeil <- 1:length(winterpeilen); names(nr_winterpeil) <- winterpeilen
nr_variabele <- 1:length(variabelen); names(nr_variabele) <- variabelen
nr_kwel_scenario <- 1:length(kwel_scenarios); names(nr_kwel_scenario) <- kwel_scenarios
nr_scenario <- 1:length(scenarios); names(nr_scenario ) <- scenarios

nr_key <- 1:length(keys); names(nr_key ) <- keys
nr <- 10
nc <- 10
n <- nr*nc
r <- matrix(1:n, nrow=nr, ncol=nc) %>% terra::rast()

set.seed(32323)
archetype <- r; terra::values(archetype) <- sample(1:length(archetypes), n, replace=TRUE); names(archetype) <- "archetype"
bron <- r; terra::values(bron) <- sample(1:length(bronnen), n, replace=TRUE); names(bron) <- "bron"
type_perceel <- r; terra::values(type_perceel) <- sample(1:length(type_percelen), n, replace=TRUE); names(type_perceel) <- "type_perceel"
winterpeil <- r; terra::values(winterpeil) <- sample(1:length(winterpeilen), n, replace=TRUE); names(winterpeil) <- "winterpeil"
#variabele <- r; terra::values(variabele) <- sample(1:length(variabelen), n, replace=TRUE); names(variabele) <- "variabele"
kwel_scenario <- r; terra::values(kwel_scenario) <- sample(1:length(kwel_scenarios), n, replace=TRUE)
kwel_scenario <- terra::ifel(bron == nr_bron["ov"], kwel_scenario, 0); names(kwel_scenario) <- "kwel_scenario"
scenario <- r; terra::values(scenario) <- sample(1:length(scenarios), n, replace=TRUE)
scenario <- terra::ifel(type_perceel == nr_type_perceel["dd"], scenario, 0); names(scenario) <- "scenario"

f <- function(x) {if (x ==1) {runif(n=1, min=0.2, max=1.2)} else { runif(n=1, min=0.2, max=0.8)}}
drooglegging <- r; terra::values(drooglegging) <- apply( terra::values(bron), 1, f)
f <- function(x) {if (x ==1) {runif(n=1, min=40, max=140)} else { runif(n=1, min=40, max=80)}}
slootafstand <- r; terra::values(slootafstand) <-  apply( terra::values(bron), 1, f)

######## Save voorbeeld rasters
archetype %>% terra::writeRaster("data-raw/rSIF_example_input/archetype.tif", overwrite=TRUE)
bron %>% terra::writeRaster("data-raw/rSIF_example_input/bron.tif", overwrite=TRUE)
type_perceel %>% terra::writeRaster("data-raw/rSIF_example_input/type_perceel.tif", overwrite=TRUE)
winterpeil %>% terra::writeRaster("data-raw/rSIF_example_input/winterpeil.tif", overwrite=TRUE)
#variabele %>% terra::writeRaster("data-raw/rSIF_example_input/variabele.tif", overwrite=TRUE)
kwel_scenario %>% terra::writeRaster("data-raw/rSIF_example_input/kwel_scenario.tif", overwrite=TRUE) # alleen in dataset "ov"
scenario %>% terra::writeRaster("data-raw/rSIF_example_input/scenario.tif", overwrite=TRUE) # alleen bij drukdrainage
drooglegging %>% terra::writeRaster("data-raw/rSIF_example_input/drooglegging.tif", overwrite=TRUE)
slootafstand %>% terra::writeRaster("data-raw/rSIF_example_input/slootafstand.tif", overwrite=TRUE)

##################
# Maak id raster van voorbeeld rasters
#r_ <- c(archetype, bron, type_perceel,  winterpeil, variabele, kwel_scenario, scenario)
#names(r_) <- keys
#df <- r_ %>% as.data.frame() %>% tidyr::replace_na(list(archetype=0, bron=0, type_perceel=0,  winterpeil=0, variabele=0, kwel_scenario=0, scenario=0))
#names(df) <- keys
#ids <- df %>% dplyr::mutate_all(as.character) %>% tidyr::unite("id", archetype:scenario, remove = T, sep = "")
#ids <- ids$id
##invalid_ids <- !(ids %in% brondata$id)
#id <- r; terra::values(id) <- as.numeric(ids)

###########
#example_input <- c(id, drooglegging, slootafstand)
#names(example_input) <- c("id", "drooglegging", "slootafstand")

#example_input %>% terra::writeRaster("inst/extdata/example_input.tif", overwrite=TRUE)

