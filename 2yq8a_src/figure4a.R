###################################################################################################
# CODE ACCOMPANYING THE PAPER "Dissecting Functional Contributions of the Social Brain to Strategic #Behavior"
# For any requests, please contact Arkady Konovalov (arkady.konovalov@gmail.com)
###################################################################################################

rm(list = ls())
library(dplyr, quietly = T)
library(lme4, quietly = T)
library(lmerTest, quietly = T)
source('myfunctions.R') # my custom plotting functions

data <- read.csv("betas_model_based.csv")

ROInames = c('precuneus','dmPFC','left TPJ','left temporal pole', 'nucleus accumbens', 'right TPJ', 'right temporal pole','vmPFC','TPJ opponent','TPJ reward x context')

data$social = round(data$id/100)
data$social = factor(data$social,labels = c('non-social','social'))


par(mfrow = c(3,4))

ROIs = unique(data$ROI)
ylims = rbind(c(-1,2),c(-4,2),c(-3,2),c(-3,2),c(-1,6),c(-2,3),c(-2,2),c(-4,2),c(-2,4),c(-2,4),
              c(-2,4),c(-2,4))
N = length(ROIs)

tmap = data.frame(ROI = ROIs,social = rep(0,N), nonsocial = rep(0,N))
pmap = tmap


for (i in 1:12){
  
  temp = data[data$ROI == ROIs[i] & data$contrast == 'signPE',]
  
  b = cbarplot(temp$social,temp$beta,cluster = temp$id, ylim = ylims[i,], main = ROIs[i],
               ylab = 'beta [a.u.]', xlab = NA, color = csp[c(4,3)], legend = F)
  
  tt = t.test(temp$beta[temp$social == 'social'],mu = 0)
  tmap$social[i] = round(tt$statistic,1)
  pmap$social[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'non-social'],mu = 0)
  tmap$nonsocial[i] = round(tt$statistic,1)
  pmap$nonsocial[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'social'],temp$beta[temp$social == 'non-social'])
  pmap$dif[i] = round(tt$p.value,3)
  
  tt = t.test(temp$beta,mu = 0)
  pmap$both[i] = round(tt$p.value,3)
}

tmap1 = tmap[c(7,4,3,11,5,2,6),]
pmap1 = pmap[c(7,4,3,11,5,2,6),]

p.adjust(c(pmap1$social),method = 'fdr')



tmap = data.frame(ROI = ROIs,social = rep(0,N), nonsocial = rep(0,N))
pmap = tmap


for (i in 1:12){
  
  temp = data[data$ROI == ROIs[i] & data$contrast == 'PE',]
  
  b = cbarplot(temp$social,temp$beta,cluster = temp$id, ylim = ylims[i,], main = ROIs[i],
               ylab = 'beta [a.u.]', xlab = NA, color = csp[c(4,3)], legend = F)
  
  tt = t.test(temp$beta[temp$social == 'social'],mu = 0)
  tmap$social[i] = round(tt$statistic,1)
  pmap$social[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'non-social'],mu = 0)
  tmap$nonsocial[i] = round(tt$statistic,1)
  pmap$nonsocial[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'social'],temp$beta[temp$social == 'non-social'])
  pmap$dif[i] = round(tt$p.value,3)
  
  tt = t.test(temp$beta,mu = 0)
  pmap$both[i] = round(tt$p.value,3)
}

tmap2 = tmap[c(7,4,3,11,5,2,6),]
pmap2 = pmap[c(7,4,3,11,5,2,6),]

p.adjust(c(pmap1$social),method = 'fdr')

tmap = data.frame(ROI = ROIs,social = rep(0,N), nonsocial = rep(0,N))
pmap = tmap

for (i in 1:12){
  
  temp = data[data$ROI == ROIs[i] & data$contrast == 'react',]
  
  b = cbarplot(temp$social,temp$beta,cluster = temp$id, ylim = ylims[i,], main = ROIs[i],
               ylab = 'beta [a.u.]', xlab = NA, color = csp[c(4,3)], legend = F)
  
  tt = t.test(temp$beta[temp$social == 'social'],mu = 0)
  tmap$social[i] = round(tt$statistic,1)
  pmap$social[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'non-social'],mu = 0)
  tmap$nonsocial[i] = round(tt$statistic,1)
  pmap$nonsocial[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'social'],temp$beta[temp$social == 'non-social'])
  pmap$dif[i] = round(tt$p.value,3)
  
  tt = t.test(temp$beta,mu = 0)
  pmap$both[i] = round(tt$p.value,3)
}

tmap3 = tmap[c(7,4,3,11,5,2,6),]
pmap3 = pmap[c(7,4,3,11,5,2,6),]

p.adjust(c(pmap1$social),method = 'fdr')


tmap = data.frame(ROI = ROIs,social = rep(0,N), nonsocial = rep(0,N))
pmap = tmap


for (i in 1:12){
  
  temp = data[data$ROI == ROIs[i] & data$contrast == 'value_dif2',]
  
  b = cbarplot(temp$social,temp$beta,cluster = temp$id, ylim = ylims[i,], main = ROIs[i],
               ylab = 'beta [a.u.]', xlab = NA, color = csp[c(4,3)], legend = F)
  
  tt = t.test(temp$beta[temp$social == 'social'],mu = 0)
  tmap$social[i] = round(tt$statistic,1)
  pmap$social[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'non-social'],mu = 0)
  tmap$nonsocial[i] = round(tt$statistic,1)
  pmap$nonsocial[i] = round(tt$p.value,4)
  
  tt = t.test(temp$beta[temp$social == 'social'],temp$beta[temp$social == 'non-social'])
  pmap$dif[i] = round(tt$p.value,3)
  
  tt = t.test(temp$beta,mu = 0)
  pmap$both[i] = round(tt$p.value,3)
}

tmap4 = tmap[c(7,4,3,11,5,2,6),]
pmap4 = pmap[c(7,4,3,11,5,2,6),]

p.adjust(c(pmap1$social),method = 'fdr')

tmap = cbind(tmap1,tmap2[,2:3],tmap3[,2:3],tmap4[,2:3])
pmap = cbind(pmap1,pmap2[,2:3],pmap3[,2:3],pmap4[,2:3])

# 
write.csv(tmap,file = 'tmap_model_based.csv',row.names = F)
write.csv(pmap,file = 'pmap_model_based.csv',row.names = F)
