rm(list=ls()); dev.off()
library("ggplot2")
theme_set(cowplot::theme_cowplot())
library("tidyverse")
library("cowplot")
library("matrixStats")

setwd("/home/kevinchern/projects/blangSDK/results/latest/")
w <- read.csv("samples/logWeight.csv")
wInc <- read.csv("samples/logIncrementalWeight.csv")
column_names <- c("iteration", "particle", "logWeight")
colnames(w) <- column_names
colnames(wInc) <- column_names
w$particle <- as.factor(w$particle)
wInc$particle <- as.factor(wInc$particle)
wNormed <- wInc %>% group_by(iteration) %>% mutate(logWeight = logWeight - logSumExp(logWeight))
wCum <- wInc %>% group_by(particle) %>% mutate(logWeight = cumsum(logWeight))
prop <- read.csv("monitoring/propagation.csv")

nParticles <- length(levels(w$particle))
minIter <- 0
maxIter <- max(w$iteration) 

plotRaw <- ggplot(w %>% filter(iteration >= minIter & iteration <= maxIter), aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("Raw") +
  guides(colour=F, alpha=F)

plotInc <- ggplot(wInc %>% filter(iteration >= minIter & iteration <= maxIter), aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("Incremental") +
  guides(colour=F, alpha=F)

plotNorm <- ggplot(wNormed %>% filter(iteration >= minIter & iteration <= maxIter), aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("Normalized") +
  guides(colour=F, alpha=F)

plotCum <- ggplot(wCum %>% filter(iteration >= minIter & iteration <= maxIter), aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("CumSum") +
  guides(colour=F, alpha=F)

plotESS <- ggplot(prop %>% filter(iteration >= minIter & iteration <= maxIter), aes(x=iteration, y=ess)) +
  geom_line() + ggtitle("ESS") + ylim(c(0, 1)) + geom_hline(yintercept=0.5, colour="red") + 
  guides(colour=F, alpha=F)

plotAnneal <- ggplot(prop %>% filter(iteration >= minIter & iteration <= maxIter), aes(x=iteration, y=annealingParameter)) +
  geom_line() + ggtitle("Annealing") +
  guides(colour=F, alpha=F)


jointPlot <- plot_grid(plotRaw, plotInc, plotNorm, plotCum, plotAnneal, plotESS, nrow=3, ncol=2)

modelName <- paste("TBD", nParticles, sep="-")
title <- ggdraw() + draw_label(modelName, fontface='bold') +
  theme(plot.margin = margin(0, 0, 0, 7))

finalPlot <- plot_grid(title, jointPlot, ncol=1, rel_heights=c(0.03, 1)); finalPlot
ggsave(paste("~/projects/blangSDK/viz_scripts/", modelName, ".png", sep=""), finalPlot)

