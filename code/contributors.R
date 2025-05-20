library(googlesheets4)
#devtools::install_github("marton-balazs-kovacs/tenzing")
library(tenzing)

DF <- read_sheet(
  # ss = "https://docs.google.com/spreadsheets/d/1EquLYV4baIjYtfF8kxs6-w-aQig32s2gRT-w4wurhhw/edit#gid=0"
  ss = "https://docs.google.com/spreadsheets/d/1eYATacyf70PwQV40XYnDdh2qY_vB5RULEAumDuNuKjQ/edit#gid=0"
)

DF$`Middle name` <- NA

# validate_contributors_table(contributors_table = DF)

colnames(DF)[1:3] <- c("Order in publication", 
                       "Firstname", "Surname")

DF <- subset(DF, !is.na(Firstname))

# remove chinese authors per request
# remove <- c(86, 87, 85)
# DF <- DF %>% filter(!(as.numeric(`Order in publication`) %in% remove))


#DF$`Email address` <- paste0("'", DF$`Email address`, "'")

# cat(print_yaml(contributors_table = DF))

# dammit marton
credit_taxonomy <-
  tibble::tibble('CRediT Taxonomy' = c("Conceptualization",
                                       "Data curation",
                                       "Formal analysis",
                                       "Funding acquisition",
                                       "Investigation",
                                       "Methodology",
                                       "Project administration",
                                       "Resources",
                                       "Software",
                                       "Supervision",
                                       "Validation",
                                       "Visualization",
                                       "Writing - original draft",
                                       "Writing - review & editing"),
                 url = c("http://credit.niso.org/contributor-roles/conceptualization/",
                         "http://credit.niso.org/contributor-roles/data-curation/",
                         "http://credit.niso.org/contributor-roles/formal-analysis/",
                         "http://credit.niso.org/contributor-roles/funding-acquisition/",
                         "http://credit.niso.org/contributor-roles/investigation/",
                         "http://credit.niso.org/contributor-roles/methodology/",
                         "http://credit.niso.org/contributor-roles/project-administration/",
                         "http://credit.niso.org/contributor-roles/resources/",
                         "http://credit.niso.org/contributor-roles/software/",
                         "http://credit.niso.org/contributor-roles/supervision/",
                         "http://credit.niso.org/contributor-roles/validation/",
                         "http://credit.niso.org/contributor-roles/visualization/",
                         "http://credit.niso.org/contributor-roles/writing-original-draft/",
                         "http://credit.niso.org/contributor-roles/writing-review-editing/"))

print_yaml <- function (contributors_table) 
{
  legacy_affiliation_cols <- c("Primary affiliation", "Secondary affiliation", "Third affiliation")
  numbered_affiliation_cols <- grep("^Affiliation \\d+$", colnames(contributors_table), 
                                    value = TRUE)
  affiliation_cols <- c(intersect(legacy_affiliation_cols, 
                                  colnames(contributors_table)), numbered_affiliation_cols)
  affiliation_data <- contributors_table %>% dplyr::select(all_of(affiliation_cols)) %>% 
    tidyr::pivot_longer(cols = everything(), values_to = "affiliation") %>% 
    dplyr::filter(!is.na(affiliation)) %>% dplyr::distinct(affiliation) %>% 
    dplyr::pull(affiliation)
  contrib_data <- contributors_table %>% abbreviate_middle_names_df() %>% 
    dplyr::rename(order = `Order in publication`, email = `Email address`, 
                  corresponding = `Corresponding author?`) %>% dplyr::arrange(order) %>% 
    dplyr::mutate(name = gsub("NA\\s*", "", paste(Firstname, 
                                                  `Middle name`, Surname)), affiliation = purrr::map_chr(dplyr::row_number(), 
                                                                                                         ~paste(which(affiliation_data %in% na.omit(unlist(contributors_table[., 
                                                                                                                                                                              affiliation_cols]))), collapse = ","))) %>% dplyr::select(dplyr::pull(credit_taxonomy, 
                                                                                                                                                                                                                                                    `CRediT Taxonomy`), name, corresponding, email, affiliation) %>% 
    dplyr::filter(name != "") %>% dplyr::mutate(name = factor(name, 
                                                              levels = name))
  contrib_data$role <- I(purrr::map(split(contrib_data, contrib_data$name), 
                                    ~names(dplyr::select(., dplyr::pull(credit_taxonomy, 
                                                                        `CRediT Taxonomy`)))[.x[1, ] == TRUE]))
  author_list <- contrib_data %>% dplyr::select(name, affiliation, 
                                                role, corresponding, email) %>% split(.$name) %>% purrr::map(as.list) %>% 
    purrr::map(function(x) {
      x$role <- x$role[[1]]
      if (isTRUE(x$corresponding)) 
        x$address <- "Enter postal address here"
      if (is.na(x$email)) 
        x$email <- NULL
      x
    })
  affiliation_list <- purrr::imap(affiliation_data, ~list(id = .y, 
                                                          institution = .x))
  yaml <- list(author = author_list, affiliation = affiliation_list)
  yaml::as.yaml(yaml, indent.mapping.sequence = TRUE) %>% gsub("\\naffiliation:", 
                                                               "\n\naffiliation:", .)
}

writeLines(print_yaml(contributors_table = DF),
           con = "author_yaml.txt")

"No. 67, Jei-Ren St., Hualien City, Taiwan"

# remove na.character 

cat(print_funding(contributors_table = DF))
