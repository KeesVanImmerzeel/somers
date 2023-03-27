############ Maak voorbeeld input 'example_input' (SpatRaster).

suppressPackageStartupMessages(library(dplyr))

# Lees brondata
brondata <- readRDS("data-raw/brondata.rds")

set.seed(32323)
.f <- function(x) {
  i <- sample(1:nrow(brondata), size=1)
  id_selected <- brondata$id[i]
  x <- brondata %>% dplyr::filter(id == id_selected)
  rng <- range(x$drooglegging)
  drooglegging <- runif(1, min=rng[1], max=rng[2])
  rng <- range(x$slootafstand)
  slootafstand <- runif(1, min=rng[1], max=rng[2])
  return( c("id"=id_selected, "drooglegging"=drooglegging , "slootafstand"=slootafstand) )
}

nr <- 10
nc <- 10
n <- nr*nc
r <- matrix(1:n, nrow=nr, ncol=nc) %>% terra::rast()
id <- r
drooglegging <- r
slootafstand <- r
r_ <- c(id, drooglegging, slootafstand)
example_input <- terra::app(r_, fun=.f, filename= "inst/extdata/example_input.tif", overwrite=TRUE)

# Constanten

#archetypes <- c("hV","pV","kV","hVz","kVz","V","Vz","aVz") # 1-8
#bronnen <- c("grfr", "ov", "wn") # 1-3
#type_percelen <- c("ref", "owd", "dd") # 1-3 Opmerking: definieer ook "scenarios"
#winterpeilen <- c("gelijk aan zomerpeil", "10 cm beneden zomerpeil", "20 cm beneden zomerpeil") # 1-4
#variabelen <- c("CO2-uitstoot.min", "CO2-uitstoot.mediaan", "CO2-uitstoot.max") # 1-3
#kwel_scenarios <- c("lichte kwel", "lichte wegzijging") # 1-2 Opmerking: Gegevens mbt kwel zijn alleen beschikbaar in de Overijssel dataset ("bron"="ov")
#scenarios <- c("medium_peil", "hoog_peil") # 1-2 Opmerking: alleen van toepassing bij drukdrainage ("type_perceel"="dd")

#keys <- c("archetype", "bron", "type_perceel", "winterpeil", "variabele", "kwel_scenario", "scenario")

#nr_archetype <- 1:length(archetypes); names(nr_archetype) <- archetypes
#nr_bron <- 1:length(bronnen); names(nr_bron) <- bronnen
#nr_type_perceel <- 1:length(type_percelen); names(nr_type_perceel) <- type_percelen
#nr_winterpeil <- 1:length(winterpeilen); names(nr_winterpeil) <- winterpeilen
#nr_variabele <- 1:length(variabelen); names(nr_variabele) <- variabelen
#nr_kwel_scenario <- 1:length(kwel_scenarios); names(nr_kwel_scenario) <- kwel_scenarios
#nr_scenario <- 1:length(scenarios); names(nr_scenario ) <- scenarios

#nr_key <- 1:length(keys); names(nr_key ) <- keys

#nr <- 100
#nc <- 100
#n <- nr*nc
#r <- matrix(1:n, nrow=nr, ncol=nc) %>% terra::rast()

#set.seed(32323)
#archetype <- r; terra::values(archetype) <- sample(1:length(archetypes), n, replace=TRUE)
#bron <- r; terra::values(bron) <- sample(1:length(bronnen), n, replace=TRUE)
#type_perceel <- r; terra::values(type_perceel) <- sample(1:length(type_percelen), n, replace=TRUE)
#winterpeil <- r; terra::values(winterpeil) <- sample(1:length(winterpeilen), n, replace=TRUE)
#variabele <- r; terra::values(variabele) <- sample(1:length(variabelen), n, replace=TRUE)
#kwel_scenario <- r; terra::values(kwel_scenario) <- sample(1:length(kwel_scenarios), n, replace=TRUE)
#kwel_scenario <- terra::ifel(bron == nr_bron["ov"], kwel_scenario, NA)
#scenario <- r; terra::values(scenario) <- sample(1:length(scenarios), n, replace=TRUE)
#scenario <- terra::ifel(type_perceel == nr_type_perceel["dd"], scenario, NA)

#drooglegging <- r; terra::values(drooglegging) <- runif(n, min=0.2, max=0.5)
#slootafstand <- r; terra::values(slootafstand) <- runif(n, min=41, max=60)

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

