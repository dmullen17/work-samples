## Clean up datateam rightsholders 

library(dataone)
library(tidyverse)
library(httr)

cn <- dataone::CNode('PROD')
mn_prod <- dataone::getMNode(cn,'urn:node:ARCTIC')

## Query metadata
all_objects <- query(mn_prod,
                     list(q = "formatType:METADATA",
                          fl = "rightsHolder",
                          start ="0",
                          rows = "1000000"),
                     as="data.frame")

## Select all unique rightsholders
orcids <- unique(all_objects$rightsHolder)

## Add 'http://' to strings that are missing it
orcids <- ifelse(grepl("^orcid\\.org\\/[0-9]{4}-[0-9]{4}-[0-9]{4}-[[:alnum:]]{4}", orcids),
                 paste0("http://", orcids), orcids)

## Add http://orcid.org to strings that are missing it 
orcids <- ifelse(grepl("^[[:alnum:]]{4}-[0-9]{4}-[0-9]{4}-[[:alnum:]]{4}", orcids),
                 paste0("http://orcid.org/", orcids), orcids)

## Split double and triple orcids in one line using helper
## concatentate to the end of the vector 
for (i in seq_along(orcids)) {
  if (nchar(orcids[i]) == 72) {
    orcids <- c(orcids[-i], str_cut(orcids[i], 2))
  }
  if (nchar(orcids[i]) == 108) {
    orcids <- c(orcids[-i], str_cut(orcids[i], 3))
  }
} 

## Tidy Data - extract names using helper and add whitespace
orcids <- as_tibble(orcids) %>%
  rename(orcid_id = value) %>%
  mutate(name = sapply(orcid_id, function(x) get_orcid_name(x))) %>%
  mutate(name = str_pad(name, max(nchar(name)), "right"))

## Add '- [ ]' to create checkboxes github issue
text <- paste("- [ ]", orcids$name, orcids$orcid_id, "\n")
# print for copy/pasting
cat(text)


## Helper functions ============================================================
str_cut <- function(str, n_cuts) {
  n <- nchar(str)
  interval <- n/n_cuts 
  
  start <- seq(1, n, interval)
  stop <- seq(interval, n+1, interval)
  
  results <- substring(str, start, stop)
  
  return(results)
}


get_orcid_name <- function(orcid_url) {
  name <- tryCatch(httr::GET(orcid_url), silent = TRUE, error = function(e) {return(NA)})

  suppressWarnings(if (length(name) == 1) return("Not found"))

  name <- httr::content(name, "text") %>%
    stringr::str_extract("<title>.*<") %>%
    stringr::str_split(" ") %>%
    unlist() %>%
    stringr::str_remove("<title>")
  name <- paste(name[1], name[2])
  
  return(name)
}