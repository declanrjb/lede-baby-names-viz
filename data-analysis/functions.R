library(tidyverse)
library(varhandle)
library(xfun)

read_state <- function(file) {
  df <- read_csv(file,col_names=FALSE)
  colnames(df) <- c('STATE','SEX','YEAR','NAME','COUNT')
  return(df)
}

collapse_by_key <- function(df,key_col,value_col,collapse_func) {
  unique_keys <- unique(df[[{{key_col}}]])
  result <- as.data.frame(matrix(ncol=2,nrow=length(unique_keys)))
  colnames(result) <- c(key_col,paste('COLLAPSED_',value_col,sep=''))
  result[,1] <- unique_keys
  
  for (i in 1:length(result[,1])) {
    message(i/length(result[,1]))
    temp_df <- df[which(df[[{{key_col}}]] == result[i,1]),]
    result[i,2] <- collapse_func(temp_df[[{{value_col}}]])
  }
  
  return(result)
}

name_locale_in_year <- function(year,name,df) {
  result <- df %>% 
    filter(YEAR == year) %>% 
    filter(NAME == name) %>% 
    arrange(-NAME_REGIONALITY) %>% 
    .[1,]
  return(result)
}

name_locales <- function(name,df) {
  result <- lapply(unique(df$YEAR),name_locale_in_year,name,df)
  return(do.call(rbind,result))
}

render_name <- function(regional_df,curr_name) {
  name_key <- str_to_lower(curr_name)
  if (!dir.exists(paste('names/',name_key,sep=''))) {
    dir.create(paste('names/',name_key,sep=''))
  }
  
  michael_df <- regional_df %>% 
    filter(NAME == curr_name) %>% 
    arrange(REGION) %>% 
    arrange(YEAR)
  
  for (i in 1910:2023) {
    temp_df <- michael_df[which(michael_df$YEAR == i),]
    temp_df$NAME_REGIONALITY <- temp_df$NAME_REGIONALITY * 100
    file_name <- paste('names/',name_key,'/',i,'.csv',sep='')
    temp_df %>%
      select(JS_KEY,NAME_REGIONALITY) %>%
      write.csv(file_name,row.names=FALSE)
  }
}