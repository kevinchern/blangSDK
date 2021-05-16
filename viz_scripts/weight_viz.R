rm(list=ls()); dev.off()
library("ggplot2")
theme_set(cowplot::theme_cowplot())
library("tidyverse")
library("cowplot")
library("matrixStats")

subsetSize <- 18
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
propTidy <- prop %>%
  gather(statistic, value, c(annealingParameter, ess))


nParticles <- length(levels(w$particle))
minIter <- 0
maxIter <- max(w$iteration) 

plot_weight <- function(weightData, plotTitle, abscissa, minIter, maxIter, subsetParticles) {
  abscissa = sym(abscissa)
  p <- ggplot(weightData %>%
                filter(particle %in% subsetParticles) %>%
                filter(!!abscissa >= minIter & !!abscissa <= maxIter), aes_string(x=abscissa, y="logWeight", colour="particle", alpha=.1)) +
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

plot_monitoring2 <- function(monitorData, plotTitle, abscissa, ordinate) {
  p <- ggplot(monitorData, aes_string(x=abscissa, y=ordinate)) +
    geom_line() + ggtitle(plotTitle) + ylim(c(0, 1)) + geom_hline(yintercept=0.5) +
    guides(colour=F, alpha=F)
}

subsetParticles <- sample(unique(w$particle), subsetSize)
sortedParticles <- unlist((wCum %>% filter(iteration == maxIter) %>% group_by(particle) %>% arrange(-logWeight))["particle"])
subsetParticles <- union((union(head(sortedParticles, subsetSize / 3), tail(sortedParticles, subsetSize / 3))), sample(sortedParticles, subsetSize / 3))

plotRaw <- plot_weight(w, "raw", "iteration", minIter, maxIter, subsetParticles)
plotInc <- plot_weight(wInc, "inc", "iteration", minIter, maxIter, subsetParticles)
plotNorm <- plot_weight(wNorm, "norm", "iteration", minIter, maxIter, subsetParticles)
plotCum <- plot_weight(wCum, "cum", "iteration", minIter, maxIter, subsetParticles)

plotRawAnn <- plot_weight(w, "raw", "annealingParameter", 0, 1, subsetParticles)
plotIncAnn <- plot_weight(wInc, "inc", "annealingParameter", 0, 1, subsetParticles)
plotNormAnn <- plot_weight(wNorm, "norm", "annealingParameter", 0, 1, subsetParticles)
plotCumAnn <- plot_weight(wCum, "cum", "annealingParameter", 0, 1, subsetParticles)

plotRawESS <- plot_weight(w, "raw", "ess", 0, 1, subsetParticles)
plotIncESS <- plot_weight(wInc, "inc", "ess", 0, 1, subsetParticles)
plotNormESS <- plot_weight(wNorm, "norm", "ess", 0, 1, subsetParticles)
plotCumESS <- plot_weight(wCum, "cum", "ess", 0, 1, subsetParticles)

plotMonitor <- plot_monitoring(propTidy, "ESS/Annealing", "iteration", minIter, maxIter)
plotESSAnn <- plot_monitoring2(prop, "test", "annealingParameter", "ess")
plotAnnESS <- plot_monitoring2(prop, "test", "ess", "annealingParameter")


jointPlot <- plot_grid(plotRaw,     plotRawAnn, # plotRawESS,
                       plotCum,     plotCumAnn, # plotCumESS,
                       plotInc,     plotIncAnn, # plotIncESS,
                       plotNorm,    plotNormAnn,# plotNormESS,
                       plotMonitor, plotESSAnn, # plotAnnESS,
                       nrow=5, ncol=2)

modelName <- paste("TMP", nParticles, sep="-")
title <- ggdraw() + draw_label(modelName, fontface='bold') +
  theme(plot.margin = margin(0, 0, 0, 7))

finalPlot <- plot_grid(title, jointPlot, ncol=1, rel_heights=c(0.03, 1)); finalPlot
ggsave(paste("~/projects/blangSDK/viz_scripts/", modelName, ".png", sep=""), finalPlot)

