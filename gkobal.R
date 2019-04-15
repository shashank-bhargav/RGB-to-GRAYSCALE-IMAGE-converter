library(ggplot2)
library(leaflet)
library(treemap)
library(corrplot)
library(tm)
library(tidytext)
library(tidyr)
library(wordcloud)
library(knitr)
library(kableExtra)
library(formattable)
library(dplyr)
library(topicmodels)


df <- read.csv("globalterrorismdb_0718dist.csv",header = TRUE,sep = ",",stringsAsFactors = FALSE)
#killing worldwide
df %>% filter(nkill>0) ->dfk
treemap(dfk, 
        index=c("iyear"), 
        vSize = "nkill",  
        palette = "Reds",  
        title="Killings in Global Terrorism", 
        fontsize.title = 14 
)

#killing by country 
treemap(dfk, 
        index=c("country_txt"), 
        vSize = "nkill",  
        palette = "Reds",  
        title="Killings in Global Terrorism", 
        fontsize.title = 14 
)

#killings by country and years
treemap(dfk, #Your data frame object
        index=c("country_txt", "iyear"),  
        type = "value",
        vSize = "nkill", 
        vColor="nwound",
        palette = "RdBu", 
        title="Killings in Global terrorism  (Countries/Years) - size is proportional with the number of killings", 
        title.legend = "Number of wounded",
        fontsize.title = 10 
)
#killing per year and region
dfk %>% group_by(iyear,region_txt) %>% summarise(nkills = sum(nkill)) %>% ungroup() -> dfyr
colnames(dfyr)<-c("Year","Region","Killed")
ggplot(data = dfyr, aes(x = Year, y = Killed, colour = Region)) +       
  geom_line() + geom_point() + theme_bw()

#killings perprovince /state year
dfk %>% group_by(provstate) %>% summarise(nk = sum(nkill)) %>% 
  top_n(50, wt=nk) %>% ungroup -> dfkp_top

dfk %>% filter(provstate %in% dfkp_top$provstate) %>% group_by(provstate, iyear) %>% 
  summarise(nk = sum(nkill), nw = sum(nwound)) %>% ungroup -> dfkp
treemap(dfkp,
        index = c("provstate","iyear"),
        type = "value",
        vSize = "nk",
        vColor = "nw",
        palette = "RdBu",
        title = "killings in province/years - size is proportional with the number of killings(top 50 regions only",
        title.legend = "number of wounded",
        fontsize.title = 10
        )

#killings per cities and years
dfk %>% group_by(provstate) %>% summarise(nk = sum(nkill)) %>% 
  top_n(50, wt=nk) %>% ungroup -> dfkp_top

dfk %>% filter(provstate %in% dfkp_top$provstate) %>% group_by(provstate, iyear) %>% 
  summarise(nk = sum(nkill), nw = sum(nwound)) %>% ungroup -> dfkp


treemap(dfkp, 
        index=c("provstate", "iyear"),  
        type = "value",
        vSize = "nk", 
        vColor="nw",
        palette = "RdBu", 
        title="Killings in Provinces/Years - size is proportional with the number of killings (top 50 regions only)", 
        
        title.legend = "Number of wounded",
        fontsize.title = 10 
)

#amercian citizen killed 

df %>% filter(nkillus > 0) -> dfk_us
treemap(dfk_us,
        index=c("country_txt", "iyear"),  
        type = "value",
        vSize = "nkillus",  
        vColor="nwoundus",
        palette = "RdBu",  
        title="Killings in Global terrorism - US Citizens (Countries/Years) - size is proportional with the number of killings", 
        title.legend = "Number of wounded US citizens",
        fontsize.title = 12
)
# amercian killings per year and region
dfk_us %>% group_by(iyear,region_txt) %>% summarise(nkills = sum(nkillus)) %>% ungroup() -> dfyr
colnames(dfyr)<-c("Year","Region","Killed")
ggplot(data = dfyr, aes(x = Year, y = Killed, colour = Region)) +       
  geom_line() + geom_point() + theme_bw()

#amercian citizen wounded

df %>% filter(nwoundus > 0) -> dfw_us
treemap(dfw_us,
        index = c("country_txt","iyear"),
        type = "value",
        vSize = "nwoundus",
        vColor = "nkillus",
        palette = "RdBu",
        title = "Wounded in Global terrorism - US Citizens (Countries/Years) - size ~  number of wounded", 
        title.legend = "number of killed US citizens",
        fontsize.title = 11
        )
# map with citizen killed
p <- leaflet(data = dfk_us) %>%
addTiles() %>%
  addMarkers(lat=dfk_us$latitude, lng=dfk_us$longitude, clusterOptions = markerClusterOptions(),
             popup= paste("<strong>Date: </strong>", dfk_us$iday,"/",dfk_us$imonth,"/", dfk_us$iyear,
                          "<br><br><strong>Place: </strong>", dfk_us$city,"-",dfk_us$country_txt,
                          "<br><strong>Killed: </strong>", dfk_us$nkill,
                          "<br><strong>Wounded: </strong>", dfk_us$nwound

# amercian woundrd                           
dfw_us %>% group_by(iyear,region_txt) %>% summarise(nwounds = sum(nwoundus)) %>% ungroup() -> dfyr
colnames(dfyr)<-c("Year","Region","Wounded")
ggplot(data = dfyr, aes(x = Year, y = Wounded, colour = Region)) +       
  geom_line() + geom_point() + theme_bw()


# type of attack
df %>% group_by(iyear,attacktype1_txt) %>% summarise(n = length(iyear)) %>% ungroup() -> dfya
colnames(dfya)<-c("Year","Type of attack","Number of events")
ggplot(data = dfya, aes(x = Year, y = `Number of events`, colour = `Type of attack`)) + 
  geom_line() + geom_point() + theme_bw()

# events alternative classifiaction
df %>% filter(alternative_txt != "") %>% group_by(alternative_txt) %>% 
  summarise(n = length(alternative_txt))  %>% ungroup() -> dfa
ggplot(data = dfa, aes(x = reorder(alternative_txt,n), y = n)) +  
  geom_bar(stat="identity", fill="tomato", colour="black") +
  coord_flip() + theme_bw(base_size = 10)  +
  labs(title="", x ="Alternative classification", y = "Number of events")

#suicide attacks 
df %>% filter(suicide==1) -> dfs
treemap(dfs,
        index=c("iyear","country_txt"), 
        type = "value",
        vSize = "nkill",  
        vColor="nwound",
        palette = "RdBu",  
        title="Suicide attacks - size is proportional with the number of kills", 
        title.legend = "Number of wounded",
        fontsize.title = 14
)

leaflet(data = dfs) %>%
  addTiles() %>%
  addMarkers(lat=dfs$latitude, lng=dfs$longitude, clusterOptions = markerClusterOptions(),
             popup= paste("<strong>Date: </strong>", dfs$iday,"/",dfs$imonth,"/", dfs$iyear,
                          "<br><br><strong>Place: </strong>", dfs$city,"-",dfs$country_txt,
                          "<br><strong>Killed: </strong>", dfs$nkill,
                          "<br><strong>Wounded: </strong>", dfs$nwound,
                          "<br><strong>Killed US citizens: </strong>", dfs$nkillus,
                          "<br><strong>Wounded US citizens: </strong>", dfs$nwoundus
             ))

dfs %>% group_by(iyear,region_txt) %>% summarise(nkills = sum(nkill)) %>% ungroup() -> dfyr
colnames(dfyr)<-c("Year","Region","Killed")
ggplot(data = dfyr, aes(x = Year, y = Killed, colour = Region)) +       
  geom_line() + geom_point() + theme_bw()


# terror attack with ransom
df %>% filter(ransompaid > 0) ->dfr
treemap(dfr,
        index=c("country_txt", "iyear"), 
        type = "value",
        vSize = "ransompaid", 
        vColor="ransomamt",
        palette = "RdBu",  
        title="Ransom paid in Global terrorism  - size is proportional with the ransom paid", 
        title.legend = "Ransom demand",
        fontsize.title = 12
)

#map with ransom demand
leaflet(data = dfr) %>%
  addTiles() %>%
  addMarkers(lat=dfr$latitude, lng=dfr$longitude, clusterOptions = markerClusterOptions(),
             popup= paste("<strong>Date: </strong>", dfr$iday,"/",dfr$imonth,"/", dfr$iyear,
                          "<br><br><strong>Place: </strong>", dfr$city,"-",dfr$country_txt,
                          "<br><strong>Killed: </strong>", dfr$nkill,
                          "<br><strong>Wounded: </strong>", dfr$nwound,
                          "<br><strong>Killed US citizens: </strong>", dfr$nkillus,
                          "<br><strong>Wounded US citizens: </strong>", dfr$nwoundus,
                          "<br><strong>Suicide attack(0-No/1-Yes): </strong>", dfr$suicide,
                          "<br><strong>Ransom paid: </strong>", dfr$ransompaid,
                          "<br><strong>Ransom note: </strong>", dfr$ransomnote,
                          "<br><strong>Hostages/kidnapped: </strong>", dfr$nhostkid,
                          "<br><strong>Hostages/kidnapped outcome: </strong>", dfr$hostkidoutcome_txt
             ))
# ransom demand grouped by region and year 

dfr %>% group_by(iyear,region_txt) %>% summarise(ransomsum=sum(ransompaid)) %>% ungroup()-> dfyr
colnames(dfyr) <- c("year","region","ransom")
ggplot(data = dfyr,aes(x=year,y=ransom,colour=region))+
  geom_line()+ geom_point() + theme_bw()

# hostage / kiddnaping events with ransom 

df %>% filter(!is.na(ransomnote)) -> dfho
dfho %>% filter(ransompaid > 0) -> dfho1
treemap(dfho1, 
        index=c("hostkidoutcome_txt","country_txt"), 
        type = "value",
        vSize = "ransompaid",  
        vColor="nhostkid",
        palette = "RdBu",  
        title="Ransom paid in Global terrorism  - size is proportional with the ransom paid", 
        title.legend = "Number of hostages/kidnapped",
        fontsize.title = 12 
)

dfho1 %>% group_by(iyear,region_txt) %>% summarise(nhostkidnp = sum(nhostkid)) %>% ungroup() -> dfyr
colnames(dfyr)<-c("Year","Region","Hostages_Kidnapped")
ggplot(data = dfyr, aes(x = Year, y = Hostages_Kidnapped, colour = Region)) +       
  geom_line() + geom_point() + theme_bw() +
  labs(title="Hostages and Kidnapped when there is a ransom note", x ="Year", y = "Hostages and Kidnapped")


# hostage/kiddnaping events outcome
treemap(dfo, 
        index=c("hostkidoutcome_txt","country_txt"),  
        type = "value",
        vSize = "cnt",  
        vColor="sum",
        palette = "RdBu",  
        title="Outcome of hostage events in Global terrorism - size is proportional with the number of events", 
        title.legend = "Number of hostages or kidnapped in the events",
        fontsize.title = 12
)

# corrleation between values
terrorCor <- df[,c("iyear","imonth","iday","country", "nkill", "ransompaid","ransompaidus",
                   "nhostkidus","nhours","ndays")]
terrorCor <- na.omit(terrorCor)
correlations <- cor(terrorCor)
p <- corrplot(correlations, method="circle")



# ransom note text analysis
df %>% filter(!is.na(ransomnote)) -> dfn0
dfn0 %>% filter(ransomnote != "") -> dfn
text <- dfn$ransomnote
myCorpus <- Corpus(VectorSource(text))
myCorpus = tm_map(myCorpus, content_transformer(tolower))


# remove puncuatation
myCorpus = tm_map(myCorpus, removePunctuation)

# remove numbers
myCorpus = tm_map(myCorpus, removeNumbers)

# remove stopwords for english

myCorpus = tm_map(myCorpus, removeWords,c(stopwords("english"), stopwords("SMART")))


# create dm
myDtm = TermDocumentMatrix(myCorpus,
                           control = list(minWordLength = 3))
# frquent term and association
freqTerms <- findFreqTerms(myDtm, lowfreq=1)
m <- as.matrix(myDtm)

# calculate the frequency
v <- sort(rowSums(m), decreasing=TRUE)
myNames <- names(v)
d <- data.frame(word=myNames, freq=v)
wctop <-wordcloud(d$word, d$freq, min.freq=10, colors=brewer.pal(9,"Set1"))

# summary cluster dendogram
mydata.df <- as.data.frame(inspect(removeSparseTerms(myDtm,sparse = 0.99)))

mydata.df.scale <- scale(mydata.df)
d <- dist(mydata.df.scale, method = "euclidean") 
fit <- hclust(d,method = "ward.D")
plot(fit, xaxt = 'n', yaxt='n', xlab = "Word clustering using ward.D method", ylab = "",
     main="Cluster Dendogram for words used in summary description")
groups <- cutree(fit, k=5)
rect.hclust(fit, k=5, border="blue")
















































































































































































































































































