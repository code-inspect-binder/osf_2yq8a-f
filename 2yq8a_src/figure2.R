###################################################################################################
# CODE ACCOMPANYING THE PAPER "Dissecting Functional Contributions of the Social Brain to Strategic #Behavior"
# For any requests, please contact Arkady Konovalov (arkady.konovalov@gmail.com)
###################################################################################################


rm(list = ls())
library(dplyr, quietly = T)
library(lme4, quietly = T)
library(lmerTest, quietly = T)
library(sciplot)
source('myfunctions.R') # custom plotting functions

# loading data
data <- read.csv("beh_data_all.csv")

###################################################################################################
# FIGURE 2A
###################################################################################################

# LEFT PANEL: REWARD

blue = "#D0D8E7"
pink = "#F0C4C7"

p1 = tapply(data$payoff[data$social=='non-social' & data$opponent == 'sequencer'],data$id[data$social=='non-social' & data$opponent == 'sequencer'],mean)
p2 = tapply(data$payoff[data$social=='non-social' & data$opponent == 'learner'],data$id[data$social=='non-social' & data$opponent == 'learner'],mean)
p3 = tapply(data$payoff[data$social=='social' & data$opponent == 'sequencer'],data$id[data$social=='social' & data$opponent == 'sequencer'],mean)
p4 = tapply(data$payoff[data$social=='social' & data$opponent == 'learner'],data$id[data$social=='social' & data$opponent == 'learner'],mean)

d1 = tapply(data$dataset[data$social=='non-social' & data$opponent == 'sequencer'],data$id[data$social=='non-social' & data$opponent == 'sequencer'],mean)
d2 = tapply(data$dataset[data$social=='non-social' & data$opponent == 'learner'],data$id[data$social=='non-social' & data$opponent == 'learner'],mean)
d3 = tapply(data$dataset[data$social=='social' & data$opponent == 'sequencer'],data$id[data$social=='social' & data$opponent == 'sequencer'],mean)
d4 = tapply(data$dataset[data$social=='social' & data$opponent == 'learner'],data$id[data$social=='social' & data$opponent == 'learner'],mean)

means = c(mean(p1),mean(p3),mean(p2),mean(p4))
ses = c(se(p1),se(p3),se(p2),se(p4))

plot(1:4,means,ylim = c(0.35,0.82), pch = '-', cex = 2, 
     col = c(blue,blue,pink,pink), ylab = 'reward', xlab = 'condition', xlim = c(0.5,4.5))

points(rep(1,length(p1[d1==1])) + rnorm(length(p1[d1==1]),0,0.04),p1[d1==1], pch = 4, col = blue)
points(rep(2,length(p2[d1==1])) + rnorm(length(p2[d1==1]),0,0.04),p2[d1==1], pch = 4, col = blue)
points(rep(3,length(p3[d1==1])) + rnorm(length(p3[d1==1]),0,0.04),p3[d1==1], pch = 4, col = pink)
points(rep(4,length(p4[d1==1])) + rnorm(length(p4[d1==1]),0,0.04),p4[d1==1], pch = 4, col = pink)

points(rep(1,length(p1[d1==2])) + rnorm(length(p1[d1==2]),0,0.04),p1[d1==2], pch = 1, col = blue)
points(rep(2,length(p2[d1==2])) + rnorm(length(p2[d1==2]),0,0.04),p2[d1==2], pch = 1, col = blue)
points(rep(3,length(p3[d1==2])) + rnorm(length(p3[d1==2]),0,0.04),p3[d1==2], pch = 1, col = pink)
points(rep(4,length(p4[d1==2])) + rnorm(length(p4[d1==2]),0,0.04),p4[d1==2], pch = 1, col = pink)

points(1:4,means,ylim = c(0.35,0.82), pch = '-', cex = 2, 
     col = 'black', ylab = 'reward', xlab = 'condition', xlim = c(0.5,4.5))
segments(1:4,means-ses,1:4,means+ses, lwd =2)

legend('topright',legend = c('fmri','behavioral'),pch = c(4,1), bty = 'n')
legend('topleft',legend = c('sequencer','learner'),pch = c(16,16), col = c(blue,pink), bty = 'n')

invisible(dev.copy2pdf(file = 'behavioral_reward.pdf',width=4, height=5))


# RIGHT PANEL: INTERACTION EFFECT OF OPPONENT AND CONTEXT

b1 = summary(glmer(payoff ~ opponent*social + (1|id),family = 'binomial',data[data$dataset==1,]))
b2 = summary(glmer(payoff ~ opponent*social + (1|id),family = 'binomial',data[data$dataset==2,]))
b4 = summary(glmer(payoff ~ opponent*social + (1|id),family = 'binomial',data))

par(mar=c(3,5.3,1,1))

cofs = c(-b1$coefficients[4,1],-b2$coefficients[4,1],-b4$coefficients[4,1])
ses = c(b1$coefficients[4,2],b2$coefficients[4,2],b4$coefficients[4,2])
ps = c(b1$coefficients[4,4],b2$coefficients[4,4],b4$coefficients[4,4])

plot(cofs,type = 'p', pch = 16, ylim = c(-0.1,0.6),col = c(cs[1],cs[2],'darkgray'), cex = 2,
     xlim = c(0.5,3.5),xaxt = 'n',xlab = NA, ylab = 'opponent x context interaction')
segments(1:3,cofs-ses,1:3,cofs+ses, col = c(cs[1],cs[2],'darkgray'))
abline(h = 0, lty = 2)
text(1:4,cofs+ses+0.05, labels = c('*','*','**','**'), cex = 2)

axis(1,at = c(1,2,3),labels = c('fMRI','beh','all'),xpd = NA)
axis(1, at=seq(-1 , 2000, by=200), lwd=1)

invisible(dev.copy2pdf(file = 'opponent_context_interaction.pdf',width=3.5, height=3.5))

###################################################################################################
# FIGURE 2B
###################################################################################################

# FITTING THE MODEL
data$pchoice1 = c(NaN,data$choice[1:(nrow(data)-1)])
data$pchoice2 = c(NaN,NaN,data$choice[1:(nrow(data)-2)])
data$opchoice2 = c(NaN,NaN,data$opchoice[1:(nrow(data)-2)])
data$opchoice1 = c(NaN,data$opchoice[1:(nrow(data)-1)])

data$pchoice1[data$trial <=2] = NaN
data$pchoice2[data$trial <=2] = NaN
data$opchoice2[data$trial <=2] = NaN
data$opchoice1[data$trial <=2] = NaN

b = glmer(choice ~ pchoice1 +  opchoice2 + opchoice1 + pchoice2 + (1 + pchoice1 +  opchoice2 + opchoice1 + pchoice2  |code),family = 'binomial',data
          ,control = glmerControl(optimizer="bobyqa", tolPwrss = 1e-10, optCtrl = list(maxfun = 60000)))

idata = data.frame(temp = rep(0,440))
idata$kappa = coef(b)$code[,2]
idata$gamma = coef(b)$code[,3]
idata$bopp1 = coef(b)$code[,4]
idata$bown2 = coef(b)$code[,5]
idata$codes = tapply(data$code,data$code,mean)
data$opponent = ifelse(data$opponent=='learner',1,0)
idata$opponent = tapply(data$opponent,data$code,mean)
idata$reward = tapply(data$payoff,data$code,mean, na.rm = T)
idata$id =  tapply(data$id,data$code,mean, na.rm = T)
idata$group =  tapply(data$dataset,data$code,mean, na.rm = T)
data$social = ifelse(data$social=='social',1,0)
idata$social = tapply(data$social,data$code,mean)
idata$run = tapply(data$run,data$code,mean)
idata$idop = idata$id*1000 + idata$opponent

# TOP PANEL
blue = "#D0D8E7"
pink = "#F0C4C7"

b = summary(lm(reward ~ kappa +  bown2 + bopp1 + gamma  ,idata[idata$opponent == 1,]))

cofs = -b$coefficients[2:5,1]
ses = b$coefficients[2:5,2]
xc = barplot(cofs, ylim = c(-0.08,0.2), col = c(pink,'gray','gray',blue), xaxt = 'n')

segments(xc,cofs-ses,xc,cofs+ses, col = 'black')
text(xc,cofs+ses+0.01, labels = c('***','*','',''), cex = 2)

axis(1,at = xc,labels = c('own t-1','own t-2','opp t-1','opp t-2'),xpd = NA)
#axis(1, at=seq(-1 , 2000, by=200), lwd=1)

invisible(dev.copy2pdf(file = 'reward_learner.pdf',width=3.5, height=3.5))

b = summary(lm(reward ~kappa +  bown2 + bopp1 + gamma   ,idata[idata$opponent == 0, ]))

cofs = -b$coefficients[2:5,1]
ses = b$coefficients[2:5,2]
xc = barplot(cofs, ylim = c(-0.08,0.2), col = c(pink,'gray','gray',blue),xaxt = 'n')

segments(xc,cofs-ses,xc,cofs+ses, col = 'black')
text(xc,cofs+ses+0.01, labels = c('','','*','**'), cex = 2)

axis(1,at = xc,labels = c('own t-1','own t-2','opp t-1','opp t-2'),xpd = NA)

invisible(dev.copy2pdf(file = 'reward_sequencer.pdf',width=3.5, height=3.5))


cor.plot(-idata$kappa[idata$opponent==1],idata$reward[idata$opponent==1], cluster = idata$id[idata$opponent==1],
         group = idata$group[idata$opponent==1], group.color = c(csp[1],csp[2],cs[5]),
         legend = T, labels = c('fMRI','behavioral'), ylim = c(0.2,0.9), xlim = c(-2,3),
         ylab = 'reward rate', xlab = expression(kappa), 
         pdf.name = 'self-kappa-learner.pdf',width = 3.5,height = 3.5)


cor.plot(-idata$gamma[idata$opponent==0],idata$reward[idata$opponent==0],cluster = idata$id[idata$opponent==0],
         group = idata$group[idata$opponent==0], group.color = c(csp[1],csp[2],cs[5]),
         legend = T, labels = c('fMRI','behavioral'),ylim = c(0.2,0.9),xlim = c(-2,3),
         ylab = 'reward rate', xlab = expression(gamma), 
         pdf.name = 'other-gamma-sequencer.pdf',width = 3.5,height = 3.5)


###################################################################################################
# FIGURE 2C
###################################################################################################

par(mfrow = c(1,2))
par(mar=c(5,3,1,1))

sdata = idata %>%
        group_by(idop) %>%
        summarise_all(mean)

blue = "#D0D8E7"
pink = "#F0C4C7"


plot(density(-sdata$kappa[sdata$social == 0 & sdata$opponent == 1]), ylim = c(0,3), main = NA, xlab = expression(kappa),cex.lab = 2, col = 'white', ylab = NA, yaxt = 'n',
     xlim = c(-2,4))

den1 = density(-sdata$kappa[sdata$social == 1 & sdata$opponent == 1])
polygon( x = den1$x,y= den1$y, col=pink)
m1 = mean(-sdata$kappa[sdata$social == 1 & sdata$opponent == 1])
segments(m1,0,m1,den1$y[abs(den1$x - m1)<0.005])

den2 = density(-sdata$kappa[sdata$social == 0 & sdata$opponent == 1])
polygon( x = den2$x,y= den2$y, col=rgb(1,1,1,alpha = 0.5))
m2 = mean(-sdata$kappa[sdata$social == 0 & sdata$opponent == 1])
segments(m2,0,m2,den2$y[abs(den2$x - m2)<0.005])

den3 = density(-sdata$kappa[sdata$social == 1 & sdata$opponent == 0])
polygon( x = den3$x,y= den3$y + 1.5, col = blue)
m3 = mean(-sdata$kappa[sdata$social == 1 & sdata$opponent == 0])
segments(m3,1.5,m3,1.5+den3$y[abs(den3$x - m3)<0.005])

den4 = density(-sdata$kappa[sdata$social == 0 & sdata$opponent == 0])
polygon( x = den4$x,y= den4$y + 1.5, col=rgb(1,1,1,alpha = 0.5))
m4 = mean(-sdata$kappa[sdata$social == 0 & sdata$opponent == 0])
segments(m4,1.5,m4,1.5+den4$y[abs(den4$x - m4)<0.005])


legend(x = -1.5,y = 3.2,legend = c('social sequencer','non-social sequencer'), pch = c(22,22),bty = 'n',pt.bg = c(blue,'white'))
legend(x = -1.5,y = 1.5,legend = c('social learner','non-social learner'), pch = c(22,22),bty = 'n',pt.bg = c(pink,'white'))


plot(density(-sdata$gamma[sdata$social == 0 & sdata$opponent == 1]), ylim = c(0,3), main = NA, xlab = expression(gamma),cex.lab = 2, col = 'white', ylab = NA,yaxt = 'n',
     xlim = c(-2,4))

den1 = density(-sdata$gamma[sdata$social == 1 & sdata$opponent == 1])
polygon( x = den1$x,y= den1$y, col=pink)
m1 = mean(-sdata$gamma[sdata$social == 1 & sdata$opponent == 1])
segments(m1,0,m1,den1$y[abs(den1$x - m1)<0.005])

den2 = density(-sdata$gamma[sdata$social == 0 & sdata$opponent == 1])
polygon( x = den2$x,y= den2$y, col=rgb(1,1,1,alpha = 0.5))
m2 = mean(-sdata$gamma[sdata$social == 0 & sdata$opponent == 1])
segments(m2,0,m2,den2$y[abs(den2$x - m2)<0.005])

den3 = density(-sdata$gamma[sdata$social == 1 & sdata$opponent == 0])
polygon( x = den3$x,y= den3$y + 1.5, col = blue)
m3 = mean(-sdata$gamma[sdata$social == 1 & sdata$opponent == 0])
segments(m3,1.5,m3,1.5+den3$y[abs(den3$x - m3)<0.006])

den4 = density(-sdata$gamma[sdata$social == 0 & sdata$opponent == 0])
polygon( x = den4$x,y= den4$y + 1.5, col=rgb(1,1,1,alpha = 0.5))
m4 = mean(-sdata$gamma[sdata$social == 0 & sdata$opponent == 0])
segments(m4,1.5,m4,1.5+den4$y[abs(den4$x - m4)<0.005])



legend(x = -1.5,y = 3.2,legend = c('social sequencer','non-social sequencer'), pch = c(22,22),bty = 'n',pt.bg = c(blue,'white'))
legend(x = -1.5,y = 1.5,legend = c('social learner','non-social learner'), pch = c(22,22),bty = 'n',pt.bg = c(pink,'white'))


invisible(dev.copy2pdf(file = 'kappa_gamma_distributions.pdf',width=7, height=4))

# regression for difference between social/non-social
b = glmer(choice ~ pchoice1*social +  opchoice2*social + opchoice1 + pchoice2 + (1 + pchoice1 +  opchoice2 + opchoice1 + pchoice2  |code),family = 'binomial',data[data$opponent == 1,]
          ,control = glmerControl(optimizer="bobyqa", tolPwrss = 1e-10, optCtrl = list(maxfun = 60000)))

b = glmer(choice ~ pchoice1*social +  opchoice2*social + opchoice1 + pchoice2 + (1 + pchoice1 +  opchoice2 + opchoice1 + pchoice2  |code),family = 'binomial',data[data$opponent == 0,]
          ,control = glmerControl(optimizer="bobyqa", tolPwrss = 1e-10, optCtrl = list(maxfun = 60000)))
