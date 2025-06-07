###################################################################################################
# CODE ACCOMPANYING THE PAPER "Dissecting Functional Contributions of the Social Brain to Strategic #Behavior"
# For any requests, please contact Arkady Konovalov (arkady.konovalov@gmail.com)
###################################################################################################


rm(list = ls())
library(dplyr, quietly = T)
library(lme4, quietly = T)
library(lmerTest, quietly = T)
source('myfunctions.R') # my custom plotting functions


ROInames = c('IPS','PR','dmPFC','lTPJ','lTP', 'nAc', 'rTPJ', 'rTPJconj', 'rTPJopp','rTPJrewcon','rTP','vmPFC')

data <- read.csv("betas_conditions.csv")

par(mfrow = c(1,1))

ROIs = unique(data$ROI)
ROIs = ROIs[c(2,3,4,5,6,7,11)]
ROInames = ROInames[c(2,3,4,5,6,7,11)]

N = length(ROIs)
tmap = data.frame(ROI = ROIs,reward = rep(0,N), opponent = rep(0,N), context = rep(0,N),
                   opponent.context  = rep(0,N), 
                  reward.context  = rep(0,N),reward.opponent  = rep(0,N), triple = rep(0,N))

pmap = tmap

ylims = rbind(c(-2,1),c(-2,1),c(-1,1),c(-1,1),c(-1,3),c(-1,1),c(-1,1))

for (i in 1:7){

temp = data[data$ROI == ROIs[i],]


temp$payoff = factor(temp$payoff,labels = c('loss','win'))
temp$opponent = factor(temp$opponent,labels = c('sequencer','learner'))

temp$condition = paste(temp$social,temp$payoff)

blue = "#D0D8E7"
pink = "#F0C4C7"

b = cbarplot(temp$condition,temp$beta,cluster = temp$id, group = temp$opponent, ylim = ylims[i,], main = ROInames[i],
         ylab = 'beta [a.u.]', xlab = NA, color = c(blue,pink), legend = T)

axis(1, at = colMeans(b), labels = c('loss','win','loss','win')) 
axis(1, at = c(3.5,9.5), labels = paste("\n", c('non-social','social')), padj = 1, lwd.ticks = 0) 

pdf.name = paste('output/',ROInames[i],'.pdf',sep = '')
invisible(dev.copy2pdf(file = pdf.name,width=5, height=5))

b1 = summary(lmer(beta ~ payoff + opponent + social+  (1 |id:run),temp))

tmap[i,2:4] = as.numeric(b1$coefficients[2:4,4])
pmap[i,2:4] = as.numeric(b1$coefficients[2:4,5])

b2 = summary(lmer(beta ~ opponent*social+payoff*social + opponent*payoff +  (1|id:run),temp))

tmap[i,5:7] = as.numeric(b2$coefficients[5:7,4])
pmap[i,5:7] = as.numeric(b2$coefficients[5:7,5])

b3 = summary(lmer(beta ~ opponent*social*payoff + (1|id:run),temp))

tmap[i,8] = as.numeric(b3$coefficients[8,4])
pmap[i,8] = as.numeric(b3$coefficients[8,5])


}

tmap = tmap[c(6,3,2,7,3,1,5),]
pmap = pmap[c(6,3,2,7,3,1,5),]


write.csv(tmap,file = 'tmap_heatmap.csv')
write.csv(pmap,file = 'pmap_heatmap.csv')
