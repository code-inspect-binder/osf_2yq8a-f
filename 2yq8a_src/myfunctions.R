
# VERSION 1.0

# COLOR PALETTES

# cs = c(rgb(0.8,0.4,0,0.9),rgb(0,0.45,0.7,0.9),rgb(0.8,0.6,0.7,1),rgb(0,0.6,0.5,1),
#        rgb(0.35,0.7,0.9,0.9),
#        rgb(0.9,0.6,0,0.9),rgb(0.35,0.7,0.9,0.9),rgb(0,0,0,0.9),rgb(0.3,0.3,0.3,0.9))

alpha = 250
cs = c(rgb(44,87,166,alpha,max = 255),rgb(17,174,207,alpha,max = 255),
       rgb(106,190,69,alpha,max = 255),rgb(253,210,46,alpha,max = 255),
       rgb(244,122,47,alpha, max = 255),
       rgb(236,29,35,alpha,max = 255),rgb(114,61,151,alpha,max = 255),rgb(0,0,0,0.9),rgb(0.3,0.3,0.3,0.9))

alpha = 100
csp = c(rgb(44,87,166,alpha,max = 255),rgb(17,174,207,alpha,max = 255),
       rgb(106,190,69,alpha,max = 255),rgb(253,210,46,alpha,max = 255),
       rgb(244,122,47,alpha, max = 255),
       rgb(236,29,35,alpha,max = 255),rgb(114,61,151,alpha,max = 255),rgb(0.3,0.3,0.3,0.9),rgb(0,0,0,0.9))

csbw = c('gray90','gray80','gray70','gray60','gray50','gray40','gray30','gray20','gray10')


library(viridis)
csvir = viridis_pal(alpha = 0.6)(5)

# CUSTOM BARPLOT
cbarplot = function(x,y,cluster,group = NULL,main = NULL,xlab = NULL, ylab = NULL,ylim = NULL,
                    color = 'gray94',cex.lab = 1.5,pdf.name = NULL,width = 3.6, height = 3.4,labels = NULL,
                    cutoff = 1, serif = F,legend = T, x.labels = NULL, make.points = F){
  require(sciplot)
  
  topmargin = ifelse(is.null(main),1,3)
  leftmargin = ifelse(cex.lab == 1,4.3,5.3)
  bottommargin = ifelse(is.null(xlab),3,5)
  rightmargin = 1
  par(mar=c(bottommargin,leftmargin,topmargin,rightmargin))
  
  
  if (is.null(xlab)==T){
    xlab = deparse(substitute(x))
  }
  if (is.null(ylab)==T){
    ylab = deparse(substitute(y))
  }
  
  if (serif == T){
    par(family = 'serif')
  } 
  
  invisible(require(sciplot, quietly = T))
  
  # removing NA's from y
  index = as.numeric(is.na(y)==F)
  x = x[index==1]
  y = y[index==1]
  cluster = cluster[index==1]
  group = group[index==1]
  
  h = tapply(y,list(x,cluster),mean)
  means = apply(h,1,mean,na.rm = T)
  ses = apply(h,1,se,na.rm = T)
  
  if (is.null(group)){
    
    if (make.points == F){
      bp = barplot(means,col = color,xaxt="n",ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,xpd = FALSE)
      segments(bp,means-ses,bp,means+ses)
    } else {
      bp = barplot(means,col = 'white',xaxt="n",ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,xpd = FALSE,
                   border = NA)
      
      xx = bp
      unit = abs(xx[2]-xx[1])
      for (i in 1:length(xx)){
        points(rep(xx[i],length(h[i,]))+rnorm(length(h[i,]),0,unit/25),h[i,],col = csp[i],pch = 16,type = 'p',cex = 0.8)
      }
      
      points(bp,means, col = 'black', pch = 16, cex = 1.3)
      segments(bp,means-ses,bp,means+ses, col = 'black')
      
      
    }
    
    if (is.null(x.labels)==T){
      axis(1,at = bp,labels = row.names(h))
    }
    
    if (legend == T){
      legend('topleft',legend = labels, pch = c(22,22),bty = 'n',pt.bg = unique(color))
    }
    print(means)
    write.csv(means,file = paste('plot.csv',sep = ''))
    
  } else {
    groups = sort(unique(group))
    xs = sort(unique(x))
    
    means = matrix(NA,length(groups),length(xs))
    ses = matrix(NA,length(groups),length(xs))
    xx = matrix(NA,length(groups),length(xs))
    
    for (i in 1:length(groups)){
      ty = y[group == groups[i]]
      tx = x[group == groups[i]]
      tcluster = cluster[group == groups[i]]
      
      h = tapply(ty,list(tx,tcluster),mean)
      subs = rowSums(1-1*is.na(h),na.rm = T)
      subs = subs>=cutoff
      h = h[subs,]
      
      means[i,] = apply(h,1,mean,na.rm = T)
      ses[i,] = apply(h,1,se,na.rm = T)
      xx[i,] = row.names(h)
      
      print(means)
      write.csv(means,file = paste('plot_group_',i,'.csv',sep = ''))
    }
    
    if (length(color) == 1){
      if (color == F){
        colors = rep(csbw[1],length(groups))
        colors[2:length(colors)] = csbw[2:length(colors)]
      } else {
        colors = rep(csp[1],length(groups))
        colors[2:length(colors)] = csp[2:length(colors)]
      }
    } else {
      colors = color
    }
    
    
    if (make.points == F){
      bp = barplot(means,xaxt="n",beside = T,ylab = ylab,cex.lab = cex.lab,
                   xlab = xlab,main = main,ylim = ylim, col = colors,xpd = FALSE)
    } else {
      bp = barplot(means,xaxt="n",beside = T,ylab = ylab,cex.lab = cex.lab,
                   xlab = xlab,main = main,ylim = ylim, col = 'white',xpd = FALSE, border = NA)
      
      xx = bp
      unit = abs(xx[2]-xx[1])
      for (i in 1:length(xx)){
        points(rep(xx[i],length(h[i,]))+rnorm(length(h[i,]),0,unit/25),h[i,],col = csp[i],pch = 16,type = 'p',cex = 0.8)
      }
      
      points(bp,means, col = color, pch = 16, cex = 1.5)
      
      
    }
    segments(bp,means-ses,bp,means+ses)
    
   
    if (is.null(x.labels)==T){
      axis(1,at = colMeans(bp),labels = row.names(h),xpd = NA)
    } else {
      axis(1,at = colMeans(bp),labels = x.labels,xpd = NA)
    }
    axis(1, at=seq(-1 , 2000, by=200), lwd=1)
    
    if (is.null(labels)){
      labs = sort(unique(groups))
    } else {
      labs = labels
    }
    if (legend == T){
      legend('topleft',legend = labs, pch = c(22,22),bty = 'n',pt.bg = unique(colors))
    }
    
  }
  
  
  
  if (is.null(pdf.name)==F){
    invisible(dev.copy2pdf(file = pdf.name,width=width, height=height))
  }
  return(bp)
}


# CUSTOM PLOT


cplot = function(x,y,cluster,show.se = T, group = NULL, bins = NULL, ceil = F, main = NULL,xlab = NULL, ylab = NULL,
                 ylim = NULL, xlim = NULL, cutoff = 1, color = F, cex = 1, cex.lab = 1.5, se.lwd = 1, lwd = 1, labels = NULL,pdf.name = NULL,
                 width = 3.6, height = 3.4,add = F,maxbin = NULL,group.rev = NULL,shift = 0,minbin = NULL, yaxt=NULL, xaxt = NULL,
                 hline = NULL, vline = NULL,lty2 = 2, pch = 16,pch2 = 18, leg.pch = NULL,png.name = NULL, lty = 1,
                 legend.pos = 'topleft', legend = F, pch.values = F, text = NULL, jitter = 0, no.lines= F, show.raw  = F){


  topmargin = ifelse(is.null(main),1,3)
  leftmargin = ifelse(cex.lab == 1,4.3,5.3)
  par(mar=c(5,leftmargin,topmargin,1))
  if (color == F){
    colors = rep('black',8)
  } else if (color == T) {
    colors = cs
  } else {
    colors = color
  }
  
  if (is.null(xlab)==T){
    xlab = deparse(substitute(x))
  }
  if (is.null(ylab)==T){
    ylab = deparse(substitute(y))
  }
  
  if (is.null(bins) == F){
    if (ceil == F){
    x = bins*round(x/bins)
    } else {
    x = bins*floor(x/bins)
    x = x+bins
    }
  }
  
  if (is.null(maxbin) == F){
    y = y[x <= maxbin]
    cluster = cluster[x <= maxbin]
    group = group[ x<= maxbin]
    x = x[x <= maxbin]
  }
  
  if (is.null(minbin) == F){
    y = y[x >= minbin]
    cluster = cluster[x >= minbin]
    group = group[ x>= minbin]
    x = x[x >= minbin]
  }
  
  # setting x range
  if (is.null(xlim) == T){
    h = tapply(y,list(x,cluster),mean,na.rm = T)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    xx = as.numeric(row.names(h))
    xlim = c(min(xx[!is.na(xx)]),max(xx[!is.na(xx)]))
  } else {
    xlim = xlim
  }
  
  
  # setting y range
  if (is.null(ylim) == T){
    h = tapply(y,list(x,cluster),mean,na.rm = T)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    ylim = c(0.9*min(h,na.rm = T),1.1*max(h,na.rm = T))
  } else {
    ylim = ylim
  }
  
  
  require(sciplot)
  
  if (is.null(group)){
    h = tapply(y,list(x,cluster),mean)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
   
    
    means = apply(h,1,mean,na.rm = T)
    ses = apply(h,1,se,na.rm = T)
    xx = as.numeric(row.names(h))
    
    
    if (add == F){
    plot(xx+shift,means,col = colors,type = ifelse(no.lines == F,'o','p'),ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = pch,lwd = lwd,xlim = xlim ,yaxt = yaxt, cex = cex,xaxt=xaxt)
      
    } else {
    points(xx+shift,means,col = colors,type = ifelse(no.lines == F,'o','p'),pch = pch,lwd = lwd,lty = lty2, cex = cex)
    }
    
    if (show.raw == T){
      for (r in 1:length(xx)){
        points(rep(xx[r]+shift, length(h[r,])),h[r,], col = 'gray80',pch  = 'x')
      }
      points(xx+shift,means,col = colors,type = ifelse(no.lines == F,'o','p'),pch = pch,lwd = lwd, cex = cex)
    }
    
    if (show.se == T){
      segments(xx+shift,means-ses,xx+shift,means+ses,col = colors, lwd = se.lwd)
    }
    
  } else {
    
    groups = sort(unique(group))
    if (is.null(group.rev)==F){groups = rev(groups)}
    
    for (i in 1:length(groups)){
      ty = y[group == groups[i]]
      tx = x[group == groups[i]]
      tcluster = cluster[group == groups[i]]
      
      h = tapply(ty,list(tx,tcluster),mean)
      subs = rowSums(1-1*is.na(h),na.rm = T)
      subs = subs>=cutoff
      h = h[subs,]
     
      means = apply(h,1,mean,na.rm = T)
      ses = apply(h,1,se,na.rm = T)
      xx = as.numeric(row.names(h))
      
      if (i == 1){
        if (add == F){
        if (pch.values == T){
            pch = toString(groups[i])
          }
        plot(xx,means,col = colors[1],type = ifelse(no.lines == F,'o','p'),ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = pch,lwd = lwd,xlim = xlim,yaxt = yaxt, lty = lty, cex = cex)
        } else {
        if (pch.values == T){
            pch = toString(groups[i])
          }
        points(xx,means,col = colors[1],type = ifelse(no.lines == F,'o','p'),pch = pch,lwd = lwd, lty = lty, cex = cex)
        }
        if (show.se == T){
          segments(xx,means-ses,xx,means+ses,col = colors[1], lwd = se.lwd)
        }
        
        if (show.raw == T){
          points(xx+shift+jits,h, col = 'gray',pch  = 'x')
        }
        
      } else {
        if (length(groups)>2){
          ltype = 1
          pch2 = 16
        } else {
          ltype = 2
          pch2 = pch2
        }
        if (pch.values == T){
          pch2 = toString(groups[i])
        }
        jits = runif(length(xx),-jitter,jitter)
        points(xx+shift+ jits,means,col = colors[i],type = ifelse(no.lines == F,'o','p'),ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = pch2,lty = 2,lwd = lwd, cex = cex)
        if (show.se == T){
          segments(xx+shift+jits,means-ses,xx+shift+jits,means+ses,col = colors[i], lwd = se.lwd)
        }
        
        if (show.raw == T){
          points(xx+shift+jits,h, col = 'gray',pch  = 'x')
        }
      }
      
    }
    
    if (is.null(labels)){
      labs = groups
    } else {
      labs = labels
    }
    if (add == F & legend == T){
      legend(legend.pos,legend = labs, pch = c(pch,pch2),bty = 'n',col = colors)
    }
    
    if (is.null(text)==F){
      legend('topleft',legend = text, pch = NA,bty = 'n')
    }
  }
  
  if (is.null(hline) == F){
    abline(h=hline,col = 'black',lty = lty2)
  }
  
  if (is.null(vline) == F){
    abline(v=vline,col = 'black',lty = lty2)
  }
  
  if (is.null(pdf.name)==F){
    invisible(dev.copy2pdf(file = pdf.name,width=width, height=height))
  }
  
  if (is.null(png.name) == F){
    invisible(dev.copy(png,file = png.name,width=width, height=height, units= 'in', res = 300))
    invisible(dev.off())
  }
  
}

# CUSTOM VIOLIN PLOT

vplot = function(x,y,cluster,show.se = T, group = NULL, bins = NULL, ceil = F, main = NULL,xlab = NULL, ylab = NULL,
                 ylim = NULL, xlim = NULL, cutoff = 1, color = F, cex = 1, cex.lab = 1.5, se.lwd = 1, lwd = 1, labels = NULL,pdf.name = NULL,
                 width = 3.6, height = 3.4,add = F,maxbin = NULL,group.rev = NULL,shift = 0,minbin = NULL, yaxt=NULL, xaxt = NULL,
                 hline = NULL, vline = NULL,lty2 = 2, pch = 16,pch2 = 18, leg.pch = NULL,png.name = NULL, lty = 1,
                 legend.pos = 'topleft', legend = F, pch.values = F, text = NULL, jitter = 0, no.lines= F, show.raw  = F){
  
  
  topmargin = ifelse(is.null(main),1,3)
  leftmargin = ifelse(cex.lab == 1,4.3,5.3)
  par(mar=c(5,leftmargin,topmargin,1))
  if (color == F){
    colors = rep('black',8)
  } else if (color == T) {
    colors = cs
  } else {
    colors = color
  }
  
  if (is.null(xlab)==T){
    xlab = deparse(substitute(x))
  }
  if (is.null(ylab)==T){
    ylab = deparse(substitute(y))
  }
  
  rawx = x
  rawy = y
  
  if (is.null(bins) == F){
    if (ceil == F){
      x = bins*round(x/bins)
    } else {
      x = bins*floor(x/bins)
      x = x+bins
    }
  }
  
  if (is.null(maxbin) == F){
    y = y[x <= maxbin]
    cluster = cluster[x <= maxbin]
    group = group[ x<= maxbin]
    x = x[x <= maxbin]
  }
  
  if (is.null(minbin) == F){
    y = y[x >= minbin]
    cluster = cluster[x >= minbin]
    group = group[ x>= minbin]
    x = x[x >= minbin]
  }
  
  # setting x range
  if (is.null(xlim) == T){
    h = tapply(y,list(x,cluster),mean,na.rm = T)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    xx = as.numeric(row.names(h))
    xlim = c(min(xx[!is.na(xx)]),max(xx[!is.na(xx)]))
  } else {
    xlim = xlim
  }
  
  
  # setting y range
  if (is.null(ylim) == T){
    h = tapply(y,list(x,cluster),mean,na.rm = T)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    ylim = c(0.9*min(h,na.rm = T),1.1*max(h,na.rm = T))
  } else {
    ylim = ylim
  }
  
  
  require(sciplot)
  
  h = tapply(y,list(x,cluster),mean)
  subs = rowSums(1-1*is.na(h),na.rm = T)
  subs = subs>=cutoff
  h = h[subs,]
    
    
  means = apply(h,1,mean,na.rm = T)
  ses = apply(h,1,se,na.rm = T)
  xx = as.numeric(row.names(h))
  
  unit = xx[2]-xx[1]
  plot(rep(xx[1],length(h[1,])) + runif(length(h[1,]),-unit/25,unit/25),h[1,],col = rgb(0,0,0,0.2),pch = 16,type = 'p',ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,lwd = lwd,xlim = xlim ,yaxt = yaxt, xaxt=xaxt)
  
  for (i in 2:length(xx)){
   
    points(rep(xx[i],length(h[i,]))+rnorm(length(h[i,]),-unit/25,unit/25),h[i,],col = rgb(0,0,0,0.2),pch = 16,type = 'p')
  }
  

  points(xx+shift,means,col = colors,type = 'p',ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = '—',lwd = lwd,xlim = xlim ,yaxt = yaxt, cex = 2,xaxt=xaxt)
  
  if (show.se == T){
    segments(xx+shift,means-ses,xx+shift,means+ses,col = colors, lwd = se.lwd)
  }
   
  if (is.null(hline) == F){
    abline(h=hline,col = 'black',lty = lty2)
  }
  
  if (is.null(vline) == F){
    abline(v=vline,col = 'black',lty = lty2)
  }
  
  if (is.null(pdf.name)==F){
    invisible(dev.copy2pdf(file = pdf.name,width=width, height=height))
  }
  
  if (is.null(png.name) == F){
    invisible(dev.copy(png,file = png.name,width=width, height=height, units= 'in', res = 300))
    invisible(dev.off())
  }
  
}


# POLYGON PLOT

pplot = function(x,y,cluster,group = NULL, bins = NULL, ceil = F, main = NULL,
                 xlab = NULL, ylab = NULL,ylim = NULL, xlim = NULL, cutoff = 1, 
                 color = F,cex.lab = 1.5,lwd = 1, labels = NULL,pdf.name = NULL,
                 width = 3.6, height = 3.4,add = F,maxbin = NULL,group.rev = NULL,
                 shift = 0,minbin = NULL,hline = NULL, vline = NULL,lty2 = 2, legend = T,
                 pch = 16,pch2 = 18, leg.pos = 'topleft', leg.pch = 16,leg.colors = NULL){
  
  topmargin = ifelse(is.null(main),1,3)
  leftmargin = ifelse(cex.lab == 1,4.3,5.3)
  par(mar=c(5,leftmargin,topmargin,1))
  if (color == F){
    colors = c('black','black')
  } else if (color == T) {
    colors = csp
  } else {
    colors = color
  }
  
  if (is.null(xlab)==T){
    xlab = deparse(substitute(x))
  }
  if (is.null(ylab)==T){
    ylab = deparse(substitute(y))
  }
  
  if (is.null(bins) == F){
    if (ceil == F){
      x = bins*round(x/bins)
    } else {
      x = bins*floor(x/bins)
      x = x#+bins
    }
  }
  
  if (is.null(maxbin) == F){
    y = y[x <= maxbin]
    cluster = cluster[x <= maxbin]
    group = group[ x<= maxbin]
    x = x[x <= maxbin]
  }
  
  if (is.null(minbin) == F){
    y = y[x >= minbin]
    cluster = cluster[x >= minbin]
    group = group[ x>= minbin]
    x = x[x >= minbin]
  }
  
  # setting x range
  if (is.null(xlim) == T){
    h = tapply(y,list(x,cluster),mean)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    xx = as.numeric(row.names(h))
    xlim = c(min(xx),max(xx))
  } else {
    xlim = xlim
  }
  
  # setting y range
  if (is.null(ylim) == T){
    h = tapply(y,list(x,cluster),mean)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    ylim = c(0.9*min(h),1.1*max(h))
  } else {
    ylim = ylim
  }
  
  require(sciplot)
  
  if (is.null(group)){
    h = tapply(y,list(x,cluster),mean)
    subs = rowSums(1-1*is.na(h),na.rm = T)
    subs = subs>=cutoff
    h = h[subs,]
    
    
    means = apply(h,1,mean,na.rm = T)
    ses = apply(h,1,se,na.rm = T)
    xx = as.numeric(row.names(h))
    if (add == F){
      plot(xx+shift,means,col = colors,type = 'b',ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = pch,lwd = lwd,xlim = xlim)
    } else {
      points(xx+shift,means,col = colors,type = 'b',pch = pch,lwd = lwd,lty = 2)
    }
    polygon(c(xx,rev(xx)),c(means-ses,rev(means+ses)),col=colors,border=NA)
  } else {
    
    groups = sort(unique(group))
    if (is.null(group.rev)==F){groups = rev(groups)}
    
    for (i in 1:length(groups)){
      ty = y[group == groups[i]]
      tx = x[group == groups[i]]
      tcluster = cluster[group == groups[i]]
      
      h = tapply(ty,list(tx,tcluster),mean)
      subs = rowSums(1-1*is.na(h),na.rm = T)
      subs = subs>=cutoff
      h = h[subs,]
      
      means = apply(h,1,mean,na.rm = T)
      ses = apply(h,1,se,na.rm = T)
      xx = as.numeric(row.names(h))
      
      if (i == 1){
        plot(xx,means,col = colors[1],type = 'l',ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = 16,lwd = lwd,xlim = xlim)
        polygon(c(xx,rev(xx)),c(means-ses,rev(means+ses)),col=colors[1],border=NA)
        points(xx,means,type = 'l',col = cs[i])
        
      } else {
      
        points(xx,means,col = colors[i],type = 'l',ylab = ylab,cex.lab = cex.lab,xlab = xlab,main = main,ylim = ylim,pch = pch2,lty = 1,lwd = lwd)
        polygon(c(xx,rev(xx)),c(means-ses,rev(means+ses)),col=colors[i],border=NA)
        points(xx,means,type = 'l',col = cs[i])
      }
      
    }
    
    if (is.null(labels)){
      labs = groups
    } else {
      labs = labels
    }
    if (legend == T){
      if (is.null(leg.colors) == T){
        legend(leg.pos,legend = labs, pch = leg.pch,bty = 'n',col = cs)
      } else {
        legend(leg.pos,legend = labs, pch = leg.pch,bty = 'n',col = leg.colors)
      }
    }
    
  }
  
  if (is.null(hline) == F){
    abline(h=hline,col = 'black',lty = lty2)
  }
  
  if (is.null(vline) == F){
    abline(v=vline,col = 'black',lty = lty2)
  }
  
  if (is.null(pdf.name)==F){
    invisible(dev.copy2pdf(file = pdf.name,width=width, height=height))
  }
}

# clustering

cl   <- function(dat,fm, cluster){
  require(sandwich, quietly = TRUE)
  require(lmtest, quietly = TRUE)
  M <- length(unique(cluster))
  N <- length(cluster)
  K <- fm$rank
  dfc <- (M/(M-1))*((N-1)/(N-K))
  uj  <- apply(estfun(fm),2, function(x) tapply(x, cluster, sum));
  vcovCL <- dfc*sandwich(fm, meat=crossprod(uj)/N)
  coeftest(fm, vcovCL) }



GLM.cl <- function(FitModel, cluster)
{
  bread <-vcov(FitModel);
  library(sandwich);
  est.fun <- estfun(FitModel);
  meat <- t(est.fun)%*%est.fun;
  sandwich <- bread%*%meat%*%bread;    
  library(lmtest);
  coeftest(FitModel, sandwich);
  robust <- sandwich(FitModel, meat=crossprod(est.fun)/nrow(est.fun));  
  
  fc <- cluster;
  m <- length(unique(fc));
  k <- length(coef(FitModel));
  u <- estfun(FitModel);
  u.clust <- matrix(NA, nrow=m, ncol=k);
  
  for(j in 1:k)
  {
    u.clust[,j] <- tapply(u[,j], fc, sum);
  }
  
  dim(u); 
  dim(u.clust); 
  
  cl.vcov <- bread %*% ((m / (m-1)) * t(u.clust) %*% (u.clust)) %*% bread;
  coeftest(FitModel, cl.vcov);
}




cor.plot = function(x,y,cluster = NULL, group = NULL, line = T,stats = T,main = NULL,xlab = NULL, ylab = NULL,ylim = NULL, xlim = NULL,cex.lab = 1.5,pdf.name = NULL, width = 5, height = 4.5, color = 'grey80', group.color = csp, labels = NULL, legend = F, stats.pos = 'topleft',method = 'pearson'){
  topmargin = ifelse(is.null(main),1,3)
  leftmargin = ifelse(cex.lab == 1,4.3,5.3)
  par(mar=c(5,leftmargin,topmargin,1))
  
  if (is.null(xlab)==T){
  xlab = deparse(substitute(x))
  }
  if (is.null(ylab)==T){
  ylab = deparse(substitute(y))
  }
  
  if (is.null(cluster)==F){
    x = tapply(x,cluster,mean,na.rm=T)
    y = tapply(y,cluster,mean,na.rm=T)
    if (is.null(group) == F){
    group = tapply(group,cluster,mean,na.rm=T)
    }
  }
  
  if (is.null(xlim) == T){
    xlim = c(min(x,na.rm = T)-0.05*(max(x,na.rm = T)-min(x,na.rm = T)),max(x,na.rm = T)+0.05*(max(x,na.rm = T)-min(x,na.rm = T)))
  }
  if (is.null(ylim) == T){
    ylim = c(min(y,na.rm = T)-0.05*(max(y,na.rm = T)-min(y,na.rm = T)),max(y,na.rm = T)+0.05*(max(y,na.rm = T)-min(y,na.rm = T)))
  }
  
  if (is.null(group) ==T ){
     plot(x,y,pch = 21,xlab = xlab,ylab = ylab,xlim = xlim,ylim = ylim,main = main, bg = color,cex.lab = cex.lab)
  } else {
    groups = sort(unique(group))
    for (i in 1:length(groups)){
      ty = y[group == groups[i]]
      tx = x[group == groups[i]]
      
      if (i == 1){
        plot(tx,ty,pch = 21,xlab = xlab,ylab = ylab,xlim = xlim,ylim = ylim,main = main, bg = group.color[1],cex.lab = cex.lab)
      } else {
        points(tx,ty,pch = 21, bg = group.color[i])
      }
      
    }
  }
  if (line == T){
    #points(x,predict(lm(y~x)),type = 'l')
    
    b = lm(y~x)
    curve(x*b$coef[2]+b$coef[1],add = T,from = min(x,na.rm = T)-100,to = max(x,na.rm = T)+100,lty = 3)
  }
  
  b = cor.test(x,y, method = method)
  
  if (stats == T){
    one =  paste('r =',round(b$e,2))
    pval = round(b$p.value,3)
    two = paste('p =',round(b$p.value,3))
    if (pval<0.001) {two = 'p < 0.001'}
    legend(stats.pos,legend = c(one,two),bty = 'n')
  }
  
  if (is.null(labels) & is.null(group) == F){
    labs = sort(unique(group))
  } else {
    labs = labels
  }
  
  if (legend == T){
    legend('bottomright',legend = labs, pch = 21,bty = 'n',pt.bg = group.color)
  }
  
  
  if (is.null(pdf.name)==F){
    if (is.null(main)==F){height = height + 0.5}
    invisible(dev.copy2pdf(file = pdf.name,width=width, height=height))
  }
  print(b)
}



panel.cor = function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  p = cor.test(x, y)$p.value
  r = abs(cor.test(x, y)$estimate)
  r2 = cor.test(x, y)$estimate
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt2 <- format(c(r2, 0.123456789), digits = digits)[1]
  txt <- paste0(prefix, txt)
  p.txt <- format(c(p, 0.123456789), digits = digits)[1]
  p.txt <- paste0(prefix, p.txt)
  if(missing(cex.cor)) cex.cor <- 0.7/strwidth(txt)
  
  text(0.5, 0.75, paste('r =',txt2), cex = 1.3) #cex.cor * r )
  text(0.5, 0.25, paste('p =',p.txt), cex = 1.3) # cex.cor * (1-p) )
}

cor.matrix = function(M){
  pairs(M, lower.panel = panel.smooth, upper.panel = panel.cor)
}

dprime = function(H,FA){
zH <- qnorm(H)
zFA <- qnorm(FA)
## d-prime:
return(zH - zFA)  # d'
}

aprime = function(H,FA){
  if (is.nan(H) | is.nan(FA)) {
    return(NaN) 
  } else {
    if (H >= FA) {
      return(.5 + (H-FA)*(1+H-FA)/(4*H*(1-FA)))
    } else {
      return(.5 - (FA-H)*(1+H-FA)/(4*FA*(1-H)))
    }
  }
}

cfreqplot = function(data,x,cluster, main = NULL, xlim = NULL, ylim = NULL){
  
  library(tidyverse)
  library(sciplot)
  
  test = temp %>% 
    group_by({{cluster}}, {{x}}) %>% 
    summarise(no = n()) %>% 
    spread ({{x}}, no)
  
  df = test[,2:ncol(test)]
  df = df/rowSums(df,na.rm = T)
  xx = barplot(colMeans(df,na.rm = T), col = 'gray94', main = main,
               ylim = ylim)
  ses = apply(df,2,se,na.rm = T)
  segments(xx,colMeans(df,na.rm = T)-ses,xx,colMeans(df,na.rm = T)+ses)
}



reg.plot = function(model, x.labels = NULL, main = NULL, cex.lab = 1.5, xlab = NULL,
                    pdf.name = NULL,width = 3.6, height = 3.4){
  
  topmargin = ifelse(is.null(main),1,3)
  leftmargin = ifelse(cex.lab == 1,4.3,5.3)
  bottommargin = 3
  rightmargin = 1
  par(mar=c(bottommargin,leftmargin,topmargin,rightmargin))
  
  means = summary(model)$coefficients[,1]
  ses = summary(model)$coefficients[,2]
  
  signs = as.numeric(means > 0)
  ps = summary(model)$coefficients[,4]
  
  stars = rep(0,length(means))
  stars[ps>0.05] = ''
  stars[ps<0.05] = '*'
  stars[ps<0.01] = '**'
  stars[ps<0.001] = '***'
  
  yy = signs*(means + ses + 0.1) + (1-signs)*(means - ses - 0.1)
  
  
  
  xx = barplot(means, col = csp, ylab = 'coefficient size [st.u.]', xaxt="n",
               main = main, ylim = c(min(means) - max(ses) - 0.3,max(means)+ max(ses) + 0.3))
  segments(xx,means - ses,xx, means + ses)
  text(xx,yy,labels = stars, cex = 1.1)
  
  if (is.null(x.labels)==F){
    axis(1,at = xx,labels = x.labels)
  }
  
  if (is.null(pdf.name)==F){
    if (is.null(main)==F){height = height + 0.5}
    invisible(dev.copy2pdf(file = pdf.name,width=width, height=height))
  }
}

sig = function(x){
  sig = 1/(1+exp(-x))
  return(sig)
}