rm(list=ls()); dev.off()
library("ggplot2")
theme_set(cowplot::theme_cowplot())
library("tidyverse")
library("cowplot")
library("matrixStats")

setwd("/home/kevinchern/projects/blangSDK/results/latest/")
w <- read.csv("samples/logIncrementalWeight.csv")
wRaw <- read.csv("samples/logWeight.csv")
column_names <- c("iteration", "particle", "logWeight")
colnames(w) <- column_names
colnames(wRaw) <- column_names
w$particle <- as.factor(w$particle)
wRaw$particle <- as.factor(wRaw$particle)
wNormed <- wRaw %>% group_by(iteration) %>% mutate(logWeight = logWeight - logSumExp(logWeight))
prop <- read.csv("monitoring/propagation.csv")

nParticles <- length(levels(w$particle))
maxIter <- max(w$iteration) + 1

plotRaw <- ggplot(wRaw, aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("Raw") +
  guides(colour=F, alpha=F)

plotInc <- ggplot(w, aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("Incremental") +
  guides(colour=F, alpha=F)

plotNorm <- ggplot(wNormed, aes(x=iteration, y=logWeight, colour=particle, alpha=.1)) +
  geom_line() + ggtitle("Normalized") +
  guides(colour=F, alpha=F)

plotESS <- ggplot(prop, aes(x=iteration, y=ess)) +
  geom_line() + ggtitle("ESS") +
  guides(colour=F, alpha=F)


jointPlot <- plot_grid(plotRaw, plotInc, plotNorm, plotESS, nrow = 4)

modelName <- paste("Mixture[-1 -2 -3 -1 2 3 2 3]", nParticles, sep="-")
title <- ggdraw() + draw_label(modelName, fontface='bold') +
  theme(plot.margin = margin(0, 0, 0, 7))

finalPlot <- plot_grid(title, jointPlot, ncol=1, rel_heights=c(0.03, 1)); finalPlot
ggsave(paste("~/projects/blangSDK/viz_scripts/", modelName, ".png", sep=""), finalPlot)
