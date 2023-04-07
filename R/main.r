#' Bereken vlakdekkend de CO2 uitstoot in veenweidegebieden met de SOMERS methodiek.
#'
#' @param r Raster met layers id, drooglegging (m-mv), slootafstand (m) (SpatRaster)
#' id is een code (getal) waarvan de cijfers achtereenvolgens zijn samengesteld uit:
#'
#' - archetype (1-8): 'hV','pV','kV','hVz','kVz','V','Vz','aVz'.
#'
#' - bron (1-3): <- 'grfr', 'ov', 'wn'.
#'
#' - type_perceel (1-3): 'ref', 'owd', 'dd'. Opmerking: definieer ook 'scenario' bij gebruik van 'type_perceel'.
#'
#' - winterpeil (1-4): 'gelijk aan zomerpeil', '10 cm beneden zomerpeil', '20 cm beneden zomerpeil'.
#'
#' - variabele (1-3): 'CO2-uitstoot.min', 'CO2-uitstoot.mediaan', 'CO2-uitstoot.max'.
#'
#' - kwel_scenario (0-2): 'nvt', 'lichte kwel', 'lichte wegzijging'. Opmerking: Gegevens mbt kwel zijn alleen beschikbaar in de Overijssel dataset ('bron'='ov', code=2).
#'
#' - scenario (0-2): 'nvt', 'medium_peil', 'hoog_peil'. Opmerking: alleen van toepassing bij drukdrainage ('type_perceel'='dd', code=3).
#'
#' @return CO2 uitstoot (SpatRaster)
#' @examples
#' r <- terra::rast(system.file('extdata', 'example_input.tif', package='somers', mustWork=TRUE))
#' CO2_uitstoot <- smrs_CO2_uitstoot(r)
#' @seealso \link{smrs_validate_input}
#' @export
smrs_CO2_uitstoot <- function(r) {
  n <- parallelly::availableCores()
  print(paste(n, 'cores detected. Using', n - 1))
  res <- terra::app(r, .CO2_uitstoot, cores = n-1)
  return(res)
}

#' Bereken de CO2 uitstoot bij gegeven id, drooglegging, en slootafstand conform de informatie in de tabel 'brondata'.
#'
#' @param x Named vector with id, drooglegging, slootafstand.
#' @return CO2 uitstoot; (numeric)
#    id: archetype_id (1-8), bron_id (1-3), type_perceel_id (1-3), winterpeil_id (1-4), variabele_id (1-3), kwel_scenario_id (0-2), scenario_id (0-2); (numeric)
#    drooglegging: Drooglegging (m-mv); (numeric)
#    slootafstand: (m); (numeric)
#    Opmerking: data frame brondata moet zijn gedefinieerd met de kolommen drooglegging, slootafstand, CO2uitstoot, id.
# @examples
# x <- c(id=1113300, drooglegging=1.2, slootafstand=45)
# CO2_uitstoot <- .CO2_uitstoot(x)
# pracma::interp2()
.CO2_uitstoot <-
  function(x)
  {
    id <- NULL
    bron <- dplyr::filter(brondata, id == x['id'])
    if (nrow(bron) > 0) {
      res <-
        suppressWarnings(
          akima::interp(
            bron$drooglegging,
            bron$slootafstand,
            bron$CO2uitstoot,
            xo = x['drooglegging'],
            yo = x['slootafstand'],
            extrap = FALSE,
            remove = FALSE
          )$z
        )
      res <- as.numeric(res)
      return(res)

    } else {
      return(NA)
    }
  }

#' Controleer de input voor de functie 'smrs_CO2_uitstoot()'.
#'
#' @param r Raster met layers id, drooglegging (m-mv), slootafstand (m) (SpatRaster)
#' @return foutcodes (SpatRaster):
#'
#' -  0: geldige invoer.
#'
#' - -1: ongeldige id.
#'
#' - -2: drooglegging out of range.
#'
#' - -3: slootafstand out of range.
#'
#' - -4: ongeldige raster layer naam/namen.
#'
#' - -5: onvoldoende gegevens (1 of meer layers bevatten NA).
#' @examples
#' r <- terra::rast(system.file('extdata', 'example_input.tif', package='somers', mustWork=TRUE))
#' foutcodes <- smrs_validate_input(r)
#' @seealso \link{smrs_CO2_uitstoot}
#' @export
smrs_validate_input <- function(r) {
  n <- parallelly::availableCores()
  print(paste(n, 'cores detected. Using', n - 1))
  res <- terra::app(r, .validate_input, cores = n - 1)
  names(res) <- "foutcode"
  return(res)
}

#' Controleer de input voor een berekening met smrs_CO2_uitstoot().
#' @param x Named vector with id, drooglegging, slootafstand
#' @return foutcode (numeric)
# @examples
# x <- c(id=1113300, drooglegging=1.2, slootafstand=45)
# error_code <- .validate_input(x)
.validate_input <-
  function(x)
  {
    err_code <- -5:0
    names(err_code) <-
      c(
        'not_sufficient_data',
        'invalid_names',
        'slootafstand_out_of_range',
        'drooglegging_out_of_range',
        'invalid_id',
        'no_error'
      )
    #s <- readRDS("data-raw/ids.rds")
    #x <- c(id=as.numeric(s[2]), drooglegging=1.2, slootafstand=45)
    if (!all(!is.na(x))) {
      return(as.numeric(err_code['not_sufficient_data']))
    }
    res <- all(names(x) %in% names(brondata))
    if (!res) {
      return(as.numeric(err_code['invalid_names']))
    }
    id <- NULL
    bron <- dplyr::filter(brondata, id == x['id'])
    if (nrow(bron) > 0) {
      rng <- range(bron$drooglegging)
      res <- dplyr::between(x['drooglegging'], rng[1], rng[2])
      if (!res) {
        return(as.numeric(err_code['drooglegging_out_of_range']))
      }
      rng <- range(bron$slootafstand)
      res <- dplyr::between(x['slootafstand'], rng[1], rng[2])
      if (!res) {
        return(as.numeric(err_code['slootafstand_out_of_range']))
      } else {
        return(as.numeric(err_code['no_error']))
      }

    } else {
      return(as.numeric(err_code['invalid_id']))
    }
  }




