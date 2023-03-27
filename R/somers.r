#' somers: De effecten van maatregelen op de CO2 -uitstoot in veenweidegebieden.
#'
#' Achtergrond documentatie:
#'
#' \href{https://www.nobveenweiden.nl/wp-content/uploads/2022/12/SOMERS-1.0-hoofdrapport-2022-v4.0.pdf}{Subsurface Organic Matter Emission Registration System (SOMERS)}
#'
#' Functies:
#'
#' \code{\link{smrs_CO2_uitstoot}}
#'
#' \code{\link{smrs_validate_input}}
#'
#'
#' @docType package
#' @name somers
#'
#' @importFrom magrittr %>%
#'
#' @importFrom dplyr filter
#' @importFrom dplyr between
#'
#' @importFrom akima interp
#'
#' @importFrom terra app
#' @importFrom terra rast
#'
#' @importFrom parallelly availableCores
#'
NULL

