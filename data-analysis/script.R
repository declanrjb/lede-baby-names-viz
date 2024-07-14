library(tidyverse)
source('functions.R')

state_regions <- as.data.frame(matrix(ncol=2,nrow=51))
colnames(state_regions) <- c('STATE','REGION')
state_regions$STATE <- c(state.abb,'DC')
state_regions$REGION <- c(unfactor(state.region),'South')

all_files <- list.files('namesbystate')
all_files <- all_files[file_ext(all_files) == 'TXT'] %>% paste('namesbystate/',.,sep='')

df <- all_files %>% read_state()

df <- left_join(df,state_regions,by='STATE')

pop_names <- read_csv('pop_names.csv')

test_names <- pop_names %>% 
  arrange(-COLLAPSED_COUNT) %>%
  pull(NAME) %>%
  .[1:100]

df <- df %>% filter(NAME %in% test_names)

df['REGION_YEAR_NAME'] <- paste(df$STATE,'_',df$YEAR,'_',df$NAME,sep='')
#name_by_region_df <- df %>% collapse_by_key('REGION_YEAR_NAME','COUNT',sum)
#write.csv(name_by_region_df,'name_by_region_df.csv',row.names=FALSE)
name_by_region_df <- read_csv('name_by_region_df.csv')

colnames(name_by_region_df) <- c('REGION_YEAR_NAME','REGION_BABS')
name_by_region_df['REGION'] <- str_split_i(name_by_region_df$REGION_YEAR_NAME,'_',1)
name_by_region_df['YEAR'] <- parse_number(str_split_i(name_by_region_df$REGION_YEAR_NAME,'_',2))
name_by_region_df['NAME'] <- str_split_i(name_by_region_df$REGION_YEAR_NAME,'_',3)

df['NAME_YEAR'] <- paste(df$NAME,'_',df$YEAR,sep='')
name_by_year_df <- df %>% collapse_by_key('NAME_YEAR','COUNT',sum)
colnames(name_by_year_df) <- c('NAME_YEAR','TOT_BABS')
name_by_year_df['NAME'] <- str_split_i(name_by_year_df$NAME_YEAR,'_',1)
name_by_year_df['YEAR'] <- parse_number(str_split_i(name_by_year_df$NAME_YEAR,'_',2))

regional_df <- left_join(name_by_region_df,name_by_year_df,by=c('NAME','YEAR'))

regional_df <- regional_df %>% select(NAME,YEAR,REGION,REGION_BABS,TOT_BABS)
regional_df['BABS_NORM'] <- regional_df$REGION_BABS / regional_df$TOT_BABS

write.csv(regional_df,'regional_df.csv',row.names=FALSE)

df['REGION_YEAR'] <- paste(df$STATE,'_',df$YEAR,sep='')
babs_per_region <- df %>% collapse_by_key('REGION_YEAR','COUNT',sum)
colnames(babs_per_region) <- c('REGION_YEAR','BABS_REGION_COUNT')
babs_per_year <- df %>% collapse_by_key('YEAR','COUNT',sum)
colnames(babs_per_year) <- c('YEAR','BABS_YEAR_COUNT')

babs_per_region['YEAR'] <- parse_number(str_split_i(babs_per_region$REGION_YEAR,'_',2))
babs_base_rates <- left_join(babs_per_region,babs_per_year,by='YEAR')
babs_base_rates['REGION'] <- str_split_i(babs_base_rates$REGION_YEAR,'_',1)
babs_base_rates <- babs_base_rates %>% select(REGION,YEAR,BABS_REGION_COUNT,BABS_YEAR_COUNT)
babs_base_rates['POP_BASE_RATE'] <- babs_base_rates$BABS_REGION_COUNT / babs_base_rates$BABS_YEAR_COUNT

regional_df <- left_join(regional_df,babs_base_rates,by=c('REGION','YEAR'))

colnames(regional_df) <- c('NAME','YEAR','REGION','NAME_IN_REGION','NAME_THIS_YEAR','NORM_NAME_THIS_YEAR','BABS_IN_REGION','BABS_THIS_YEAR','POP_BASE_RATE')

regional_df['NAME_REGIONALITY'] <- regional_df$NORM_NAME_THIS_YEAR / regional_df$POP_BASE_RATE

regional_df['JS_KEY'] <- regional_df$REGION %>% str_to_lower() %>% paste('us-',.,sep='')

for (i in 1:length(test_names)) {
  curr_name <- test_names[i]
  message(curr_name)
  message(i/length(test_names))
  render_name(regional_df,curr_name)
}

test_names %>% write.csv('names_list.csv',row.names=FALSE)





# old analysis
michael_df %>% 
  filter(YEAR == 1980) %>%
  select(JS_KEY,NAME_REGIONALITY) %>%
  write.csv('michael_1980.csv',row.names=FALSE)

df['KEY'] <- paste(df$REGION,'_',df$YEAR,sep='')

df['NAME_YEAR'] <- paste(df$REGION,'_',df$YEAR,sep='')

total_babs_df <- df %>% collapse_by_key('KEY','COUNT',sum)
colnames(total_babs_df) <- c('KEY','TOT_BABIES_NAMED')
df <- df %>% left_join(total_babs_df,by='KEY')

df['COUNT_NORM'] <- df$COUNT / df$TOT_BABIES_NAMED

#pop_names <- df %>%
  #collapse_by_key('NAME','COUNT',sum)

#write.csv(pop_names,'pop_names.csv',row.names=FALSE)



region_df <- lapply(test_names,name_locales,df) %>% do.call(rbind,.)
