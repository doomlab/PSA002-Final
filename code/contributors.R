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

cat(print_yaml(contributors_table = DF))

"No. 67, Jei-Ren St., Hualien City, Taiwan"

cat(print_funding(contributors_table = DF))
