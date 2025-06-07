###################################################################################################
# CODE ACCOMPANYING THE PAPER "Dissecting Functional Contributions of the Social Brain to Strategic #Behavior"
# For any requests, please contact Arkady Konovalov (arkady.konovalov@gmail.com)
###################################################################################################

rm(list = ls())
library(dplyr, quietly = T)
library(lme4, quietly = T)
library(lmerTest, quietly = T)

source('myfunctions.R') # my custom plotting functions

data <- read.csv("betas_conditions.csv")


# restructure the data

ROInames = c('IPS','PR','dmPFC','lTPJ','lTP', 'nAc', 'rTPJ', 'rTPJconj', 'rTPJopp','rTPJrewcon','rTP','vmPFC')

N = nrow(data)/2
betas = matrix(data$beta,nrow = N,byrow =  T)
id = matrix(data$id,nrow = N,byrow =  T)
opponent = matrix(data$opponent,nrow = N,byrow =  T)
ROI = matrix(data$ROI,nrow = N,byrow =  T)
social = matrix(data$social,nrow = N,byrow =  T)
runs = matrix(data$run,nrow = N,byrow =  T)

fdata = data.frame(id = id[,1], social = social[,1], opponent = opponent[,1],  
                   run = runs[,1],
                   win = betas[,1], loss = betas[,2], ROI = ROI[,1])

cdata = fdata[1:360,1:4]

# ADDING BEHAVIORAL VARIABLES

bdata <- read.csv("data_fmri.csv")
bdata$id = bdata$idc - 100
bdata = bdata[bdata$payoff >=0,]

for (i in 1:nrow(cdata)){
  id = cdata$id[i]
  opponent = cdata$opponent[i]
  run = cdata$run[i]
  cdata$reward[i] = mean(bdata$payoff[bdata$id == id & bdata$opponent == opponent & bdata$run == run],na.rm = T)
  cdata$switch[i] = mean(bdata$rep[bdata$id == id & bdata$opponent == opponent & bdata$run == run],na.rm = T)
  
}

#############################################################################################
# RUNNING THE MODEL

bdata$code = bdata$id + bdata$opponent/100 + bdata$run/10

bdata$pchoice1 = c(NaN,bdata$choice[1:(nrow(bdata)-1)])
bdata$pchoice2 = c(NaN,NaN,bdata$choice[1:(nrow(bdata)-2)])
bdata$opchoice2 = c(NaN,NaN,bdata$opchoice[1:(nrow(bdata)-2)])
bdata$opchoice1 = c(NaN,bdata$opchoice[1:(nrow(bdata)-1)])

bdata$pchoice1[bdata$trial <=2] = NaN
bdata$pchoice2[bdata$trial <=2] = NaN
bdata$opchoice2[bdata$trial <=2] = NaN
bdata$opchoice1[bdata$trial <=2] = NaN

b = glmer(choice~pchoice1 +  opchoice2 + opchoice1 + pchoice2 + (1 + pchoice1 +  opchoice2 + opchoice1 + pchoice2  |code),family = 'binomial',bdata
          ,control = glmerControl(optimizer="bobyqa", tolPwrss = 1e-10, optCtrl = list(maxfun = 60000)))

cdata$bownmix = -coef(b)$code[,2]
cdata$boppmix = -coef(b)$code[,3]


fdata$bownmix = rep(cdata$bownmix,12)
fdata$boppmix = rep(cdata$boppmix,12)

fdata$beta = (fdata$win + fdata$loss)/2

#############################################################################################
# FIGURE 4C

temp = filter(fdata, ROI == 'dmPFC_roi.mat' & social == 'social' & opponent == 1)
cor.plot(temp$bownmix, temp$beta, cluster = temp$id, xlab = 'K [a.u.]', ylab = 'neural beta [a.u.]',
         pdf.name = 'dmPFC_correlation_by_subject_social_ler.pdf', width = 4, height = 4)

temp = filter(fdata, ROI == 'Precuneus_roi.mat' & social == 'social' & opponent == 1)
cor.plot(temp$bownmix, temp$beta, cluster = temp$id, xlab = 'K [a.u.]', ylab = 'neural beta [a.u.]',
         pdf.name = 'Precuneus_correlation_by_subject_social_ler.pdf', width = 4, height = 4)
#############################################################################################

N = length(ROInames)

tmap = data.frame(ROI = ROInames,beta.ler = rep(0,N), beta.seq = rep(0,N))
pmap = tmap

for(i in 1:length(unique(fdata$ROI))){

  temp = fdata[fdata$ROI == unique(fdata$ROI)[i],]
  
  b2 = summary(lmer(bownmix  ~  beta + (1 |id),temp[temp$opponent == 1 & temp$social == 'social',]))
  
  tmap[i,2] = as.numeric(b2$coefficients[2,4])
  pmap[i,2] = as.numeric(b2$coefficients[2,5])
  

  b3 = summary(lmer(bownmix  ~  beta + (1 |id),temp[temp$opponent == 0 & temp$social=='social',]))
  
  tmap[i,3] = as.numeric(b3$coefficients[2,4])
  pmap[i,3] = as.numeric(b3$coefficients[2,5])
  
}

p.adjust(pmap$beta.seq,method = 'fdr')

tmap1 = tmap[c(7,4,3,11,5,2,6),]
pmap1 = pmap[c(7,4,3,11,5,2,6),]

# write.csv(tmap,file = 'output/tmap_kappa_social_combined.csv')
# write.csv(pmap,file = 'output/pmap_kappa_social_combined.csv')


tmap = data.frame(ROI = ROInames,beta.ler = rep(0,N), beta.seq = rep(0,N))
pmap = tmap


for(i in 1:length(unique(fdata$ROI))){
  
  temp = fdata[fdata$ROI == unique(fdata$ROI)[i],]
  
  
  b2 = summary(lmer(boppmix  ~  beta + (1 |id),temp[temp$opponent == 1 & temp$social == 'social',]))
  
  tmap[i,2] = as.numeric(b2$coefficients[2,4])
  pmap[i,2] = as.numeric(b2$coefficients[2,5])
  
  
  b3 = summary(lmer(boppmix  ~  beta + (1 |id),temp[temp$opponent == 0 & temp$social=='social',]))
  
  tmap[i,3] = as.numeric(b3$coefficients[2,4])
  pmap[i,3] = as.numeric(b3$coefficients[2,5])
  
}

tmap2 = tmap[c(7,4,3,11,5,2,6),]
pmap2 = pmap[c(7,4,3,11,5,2,6),]


tmap = data.frame(ROI = ROInames,beta.ler = rep(0,N), beta.seq = rep(0,N))
pmap = tmap

for(i in 1:length(unique(fdata$ROI))){
  
  temp = fdata[fdata$ROI == unique(fdata$ROI)[i],]
  
  b2 = summary(lmer(bownmix  ~  beta + (1 |id),temp[temp$opponent == 1 & temp$social == 'non-social',]))
  
  tmap[i,2] = as.numeric(b2$coefficients[2,4])
  pmap[i,2] = as.numeric(b2$coefficients[2,5])
  
  
  b3 = summary(lmer(bownmix  ~  beta + (1 |id),temp[temp$opponent == 0 & temp$social=='non-social',]))
  
  tmap[i,3] = as.numeric(b3$coefficients[2,4])
  pmap[i,3] = as.numeric(b3$coefficients[2,5])
  
}

tmap3 = tmap[c(7,4,3,11,5,2,6),]
pmap3 = pmap[c(7,4,3,11,5,2,6),]



tmap = data.frame(ROI = ROInames,beta.ler = rep(0,N), beta.seq = rep(0,N))
pmap = tmap


for(i in 1:length(unique(fdata$ROI))){
  
  temp = fdata[fdata$ROI == unique(fdata$ROI)[i],]
  
  
  b2 = summary(lmer(boppmix  ~  beta + (1 |id),temp[temp$opponent == 1 & temp$social == 'non-social',]))
  
  tmap[i,2] = as.numeric(b2$coefficients[2,4])
  pmap[i,2] = as.numeric(b2$coefficients[2,5])
  
  
  b3 = summary(lmer(boppmix  ~  beta + (1 |id),temp[temp$opponent == 0 & temp$social=='non-social',]))
  
  tmap[i,3] = as.numeric(b3$coefficients[2,4])
  pmap[i,3] = as.numeric(b3$coefficients[2,5])
  
}

tmap4 = tmap[c(7,4,3,11,5,2,6),]
pmap4 = pmap[c(7,4,3,11,5,2,6),]


tmap = cbind(tmap1,tmap2[,2:3],tmap3[,2:3],tmap4[,2:3])
pmap = cbind(pmap1,pmap2[,2:3],pmap3[,2:3],pmap4[,2:3])

write.csv(tmap,file = 'tmap_brain_beh.csv',row.names = F)
write.csv(pmap,file = 'pmap_brain_beh.csv',row.names = F)