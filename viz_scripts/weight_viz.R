rm(list=ls()); dev.off()
library("ggplot2")
theme_set(cowplot::theme_cowplot())
library("tidyverse")
library("cowplot")
library("matrixStats")

setwd("/home/kevinchern/projects/blangSDK/results/latest/")
w <- read.csv("samples/logWeight.csv")
wInc <- read.csv("samples/logIncrementalWeight.csv")
prop <- read.csv("monitoring/propagation.csv")
column_names <- c("iteration", "particle", "logWeight")
colnames(w) <- column_names
colnames(wInc) <- column_names
w$particle <- as.factor(w$particle)
wInc$particle <- as.factor(wInc$particle)
w <- w %>% right_join(prop, by="iteration")
wInc <- wInc %>% right_join(prop, by="iteration")
wNorm <- wInc %>% group_by(iteration) %>% mutate(logWeight = logWeight - logSumExp(logWeight))
wCum <- wInc %>% group_by(particle) %>% mutate(logWeight = cumsum(logWeight))
prop <- prop %>%
  gather(statistic, value, c(annealingParameter, ess))


nParticles <- length(levels(w$particle))
minIter <- 0
maxIter <- max(w$iteration) 

plot_weight <- function(weightData, plotTitle, abscissa, minIter, maxIter) {
  abscissa = sym(abscissa)
  p <- ggplot(weightData %>% filter(!!abscissa >= minIter & !!abscissa <= maxIter), aes_string(x=abscissa, y="logWeight", colour="particle", alpha=.1)) +
    geom_line() + ggtitle(plotTitle) +
    guides(colour=F, alpha=F)
  return (p)
}

plot_monitoring <- function(monitorData, plotTitle, abscissa, minIter, maxIter) {
  abscissa = sym(abscissa)
  p <- ggplot(monitorData %>% filter(!!abscissa >= minIter & !!abscissa <= maxIter), aes_string(x=abscissa, y="value", colour="statistic")) +
    geom_line() + ggtitle(plotTitle) + ylim(c(0, 1)) + geom_hline(yintercept=0.5) + 
    guides(colour=F, alpha=F)
}

plotRaw <- plot_weight(w, "raw", "iteration", minIter, maxIter)
plotInc <- plot_weight(wInc, "inc", "iteration", minIter, maxIter)
plotNorm <- plot_weight(wNorm, "norm", "iteration", minIter, maxIter)
plotCum <- plot_weight(wCum, "cum", "iteration", minIter, maxIter)

plotRawAnn <- plot_weight(w, "raw", "annealingParameter", 0, 1)
plotIncAnn <- plot_weight(wInc, "inc", "annealingParameter", 0, 1)
plotNormAnn <- plot_weight(wNorm, "norm", "annealingParameter", 0, 1)
plotCumAnn <- plot_weight(wCum, "cum", "annealingParameter", 0, 1)

plotRawESS <- plot_weight(w, "raw", "ess", 0, 1)
plotIncESS <- plot_weight(wInc, "inc", "ess", 0, 1)
plotNormESS <- plot_weight(wNorm, "norm", "ess", 0, 1)
plotCumESS <- plot_weight(wCum, "cum", "ess", 0, 1)

plotMonitor <- plot_monitoring(prop, "ESS/Annealing", "iteration", minIter, maxIter)


jointPlot <- plot_grid(plotRaw,  plotRawESS,  plotRawAnn,
                       plotInc,  plotIncESS,  plotIncAnn,
                       plotNorm, plotNormESS, plotNormAnn,
                       plotCum,  plotCumESS,  plotCumAnn,
                       plotMonitor, plotMonitor, plotMonitor,
                       nrow=5, ncol=3)

modelName <- paste("TBD", nParticles, sep="-")
title <- ggdraw() + draw_label(modelName, fontface='bold') +
  theme(plot.margin = margin(0, 0, 0, 7))

finalPlot <- plot_grid(title, jointPlot, ncol=1, rel_heights=c(0.03, 1)); finalPlot
ggsave(paste("~/projects/blangSDK/viz_scripts/", modelName, ".png", sep=""), finalPlot)

