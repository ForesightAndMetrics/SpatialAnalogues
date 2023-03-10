#First install packages below 
#Example: install.packages("terra", dependencies = TRUE)
#raster,analogues,stringr,grid,maptools,rgdal

#load libraries

library(raster)
library(analogues)
library(stringr)
library(grid)
library(maptools)
library(rgdal)

#set the place where worldclim data will be downloaded
wd <-"C:/R_worldclim"
setwd(wd)
#download worldclim data for first time
wc_prec <- raster::getData('worldclim', res=2.5,var='prec', path=wd)
wc_temp <- raster::getData('worldclim', res=2.5,var='tmean', path=wd)

#Load worldclim after downloaded
# Source of Analogue rasters
raster_ini<-'C:/R_worldclim/wc2-5/'


# selecting rain files and becomes them to rasters

#rain_files<-sort(list.files(path =raster_ini,  pattern = "^prec.*\\.bil$", full.names = T))
rain_files<-paste0(raster_ini,"prec",seq(1:12),".bil")
rain_rasters<-lapply(rain_files, FUN = raster)

#selecting mean temperature  files and become them to  rasters
#tmean_files<-list.files(path =raster_ini,  pattern = "^tmean.*\\.bil$", full.names = T)
tmean_files<-paste0(raster_ini,"tmean",seq(1:12),".bil")
tmean_rasters<-lapply(tmean_files,FUN=raster)

#stacks
wc_prec <- raster::stack(rain_rasters)
wc_temp <-raster::stack(tmean_rasters)

# Load site 
FileOfSites<-read.csv('C:/Arista/Proyectos2022/Kai/Analogos/somesites.csv',header = TRUE,sep = ",", stringsAsFactors = FALSE )   

#Path for save outputs
path_out<-'C:/R_worldclim/prueba/out/'
#Run analogues

for (i in 1:nrow(FileOfSites))
{
  
  Long<-FileOfSites[i,1]
  Lat<-FileOfSites[i,2]
  FileName<-FileOfSites[i,3]
  print(FileName)
  
  params <-  createParameters(x=Long, y=Lat, vars=c("prec","tmean"), weights=c(0.5,0.5), ndivisions=c(12,12),
                              growing.season=c(1,12),rotation="tmean",threshold=1,
                              env.data.ref=list(wc_prec,wc_temp), env.data.targ=list(wc_prec,wc_temp),
                              outfile=wd,fname=NA,writefile=FALSE)
  x <- calc_similarity(params)
  
  writeRaster(x, filename = paste0(path_out,FileName, ".tif"))
  gc()
  
}