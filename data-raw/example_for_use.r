# option: 1='CO2-uitstoot.min', 2='CO2-uitstoot.mediaan', 3='CO2-uitstoot.max', 4='validate_input'
write_CO2_uitstoot_raster <-
  function(option,
           archetype,
           bron,
           type_perceel,
           winterpeil,
           kwel_scenario,
           scenario,
           drooglegging,
           slootafstand,
           fnames) {
    if (option < 1) {
      return()
    }
    
    # Maak 'variable raster' (gebaseerd op 'option').
    variabele <- archetype
    
    if (option < 4) {
      terra::values(variabele) <- option
    } else
    {
      terra::values(variabele) <- 1
    }
    
    # Maak id raster.
    keys <-
      c(
        "archetype",
        "bron",
        "type_perceel",
        "winterpeil",
        "variabele",
        "kwel_scenario",
        "scenario"
      )
    r <-
      c(archetype,
        bron,
        type_perceel,
        winterpeil,
        variabele,
        kwel_scenario,
        scenario)
    names(r) <- keys
    df <-
      r %>% as.data.frame() %>% tidyr::replace_na(
        list(
          archetype = 0,
          bron = 0,
          type_perceel = 0,
          winterpeil = 0,
          variabele = 0,
          kwel_scenario = 0,
          scenario = 0
        )
      )
    names(df) <- keys
    ids <-
      df %>% dplyr::mutate_all(as.character) %>% tidyr::unite("id", archetype:scenario, remove = T, sep = "")
    ids <- ids$id
    #print( head(ids, 25))
    #invalid_ids <- !(ids %in% brondata$id)
    #if (length(invalid_ids)>0) {
    #  print("Invalid id's:")
    #  print(head(invalid_ids, 25))
    #}
    id <- archetype
    terra::values(id) <- as.numeric(ids)
    
    # Maak invoer raster.
    r <- c(id, drooglegging, slootafstand)
    names(r) <- c("id", "drooglegging", "slootafstand")
    
    if (option < 4) {
      r %>% somers::smrs_CO2_uitstoot() %>% idf::write_raster(fnames[option], overwrite = TRUE)
      #test <- somers::smrs_CO2_uitstoot(r)
      #str(test)
    } else {
      res <- r %>% somers::smrs_validate_input() 
      res %>% idf::write_raster(fnames[option], overwrite =
                                                                  TRUE)
      #print(terra::values(res$foutcode))
    }
  }