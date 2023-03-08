library(googlesheets4)
#devtools::install_github("marton-balazs-kovacs/tenzing")
library(tenzing)

DF <- read_sheet(
  ss = "https://docs.google.com/spreadsheets/d/1EquLYV4baIjYtfF8kxs6-w-aQig32s2gRT-w4wurhhw/edit#gid=0"
)

DF$`Middle name` <- NA

validate_contributors_table(contributors_table = DF)

colnames(DF)[1:3] <- c("Order in publication", 
                       "Firstname", "Surname")

cat(print_yaml(contributors_table = DF))

"No. 67, Jei-Ren St., Hualien City, Taiwan"