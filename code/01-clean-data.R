

## load libraries
library(data.table)

## load data
df <- fread("input/Fogo.csv")

## change name of id column
setnames(df, "collar ID of group members", "id")

## 

## convert date
df$date <- as.POSIXct(df$date, format = c("%d-%b-%y"))
df[, idate := as.IDate(date)]
df[, yr := year(idate)]
df[, mnth := month(idate)]
df[, doy := yday(idate)]

## subset to spring only 
df <- df[doy > 143 & doy < 182]

## add row number
df$rowid <- 1:length(df$id)

## subset to 2016 only
df16 <- df[yr == "2016"]

## generate new rows for unique collar IDs
df16 <- df16 %>% # Application of separate_rows() function
  separate_rows(id, sep=" & ") 

setDT(df16)

## remove calves
unique(df16$id)

## remove calves
df16$id[df16$id == "FO2016016"] <- ""
df16$id[df16$id == "FO2016017"] <- ""
df16$id[df16$id == "FO2016018"] <- ""
df16$id[df16$id == "FO2016019"] <- ""
df16$id[df16$id == "FO2016020"] <- ""

#### calculate density estimate per day #### 

## remove calves from group size count 
df16$group_size <- df16$group_size - df16$calf

## new column for presence/absence of collar
df16[, boolean := id == "FO2016010" | id == "FO2016008" |
       id == "FO2016001" | id == "FO2016012" |
       id == "FO2016014" | id == "FO2016015" | 
       id == "FO2016004" | id == "FO2016005" |
       id == "FO2016003" | id == "FO2016011" |
       id == "FO2016002" | id == "FO2016009"]

## convert boolean to 1/0
df16$boolean[df16$boolean == "TRUE"] <- 1
df16$boolean[df16$boolean == "FALSE"] <- 0

## calculate number of collars per group
df16[, collar_group_size := sum(boolean), by = "rowid"]

## new data file with group size and number of collars per day
df16_sum <- df16[, sum(group_size), by = "doy"]
df16_sum$collar_gs <- df16[, sum(collar_group_size), by = "doy"]$V1
setnames(df16_sum, "V1", "gs")

## total number of animals
df16_sum$total <- 300

## total number of collars
df16_sum$all_collars <- 14

## collars seen/caribou seen
df16_sum$prop <- df16_sum$collar_gs/df16_sum$gs



ggplot(df16_sum) +
  geom_point(aes(doy, gs))
