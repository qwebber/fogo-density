

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


