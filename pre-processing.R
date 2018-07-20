## 360Giving dataviz: pre-processing script ##

# load packages ------------------------------------
library(tidyverse) ; library(stringr)

# load data ------------------------------------
# source: http://grantnav.threesixtygiving.org/api/grants.csv
raw <- read_csv("data/grantnav-20180717115129.csv")

# tidy data ------------------------------------
df <- raw %>%
  select(id = `Identifier`,
         date = `Award Date`,
         funder = `Funding Org:Name`,
         grant_amount = `Amount Awarded`,
         recipient = `Recipient Org:Name`,
         title = Title,
         description = Description,
         url = URL,
         postcode = `Recipient Org:Postal Code`) %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

# identify grants matching keywords in the description field ------------------------------------
homelessness <- mutate(df, theme =
           case_when(
             str_detect(description, paste(c("homeless", "homelessness", "rough sleeper", "Big Issue"), collapse = "|")) ~ "Homelessness",
                     TRUE ~ "Other")) %>% filter(., theme != "Other")

cycling <- mutate(df, theme =
                   case_when(
                     str_detect(description, paste(c("bicycle", "pedal cycle", "bike"), collapse = "|")) ~ "Cycling",
                     TRUE ~ "Other")) %>% filter(., theme != "Other")

mental_health <- mutate(df, theme =
                    case_when(
                      str_detect(description, "mental health") ~ "Mental Health",
                      TRUE ~ "Other")) %>% filter(., theme != "Other")

subset <- bind_rows(homelessness, cycling, mental_health)

# geocode data  ------------------------------------
# source: http://geoportal.statistics.gov.uk/datasets/ons-postcode-directory-latest-centroids
postcodes <- read_csv("data/postcode_centroids.csv") %>%
  select(postcode = pcds, lat, long)
subset <- left_join(subset, postcodes, by = "postcode")

# write data ------------------------------------
write_csv(subset, "data/threesixtygiving_data.csv")
