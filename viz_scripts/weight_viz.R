rm(list=ls()); dev.off()
library("ggplot2")
theme_set(cowplot::theme_cowplot())
library("tidyverse")
library("cowplot")
library("matrixStats")

subsetSize <- 3 * 333
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

logRunningMean <- function(x) {
  return (logSumExp(x) - log(length(x)))
}


subsetParticles <- sample(unique(w$particle), subsetSize)
sortedParticles <- unlist((wCum %>% filter(iteration == maxIter) %>% group_by(particle) %>% arrange(-logWeight))["particle"])
subsetParticles <- union((union(head(sortedParticles, subsetSize / 3), tail(sortedParticles, subsetSize / 3))), sample(sortedParticles, subsetSize / 3))

plotRaw <- plot_weight(w, "raw", "iteration", minIter, maxIter, subsetParticles)
plotInc <- plot_weight(wInc, "inc", "iteration", minIter, maxIter, subsetParticles)
plotNorm <- plot_weight(wNorm, "norm", "iteration", minIter, maxIter, subsetParticles)
plotCum <- plot_weight(wCum, "cum", "iteration", minIter, maxIter, subsetParticles) + stat_summary(geom = "line", fun = logRunningMean, colour="black", size=1, alpha=1.0)

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
                       #plotInc,     plotIncAnn, # plotIncESS,
                       #plotNorm,    plotNormAnn,# plotNormESS,
                       plotMonitor, plotESSAnn, # plotAnnESS,
                       nrow=3, ncol=2)

modelName <- paste("TMP", nParticles, "TMP", sep="-")

title <- ggdraw() + draw_label(modelName, fontface='bold') +
  theme(plot.margin = margin(0, 0, 0, 7))

finalPlot <- plot_grid(title, jointPlot, ncol=1, rel_heights=c(0.03, 1)); finalPlot
save_plot(paste("~/projects/blangSDK/viz_scripts/", modelName, ".pdf", sep=""), finalPlot, 
       base_height=20, base_width=16, dpi = 150)

#logESS <- function(weights) {
#  logess <- logSumExp(weights) * 2  - logSumExp(weights * 2) - log(length(weights))
#  ess <- exp(logess)
#  return (ess)
#}
#
#sortedPs <- wCum %>% filter(iteration == max(wCum$iteration)) %>% arrange(logWeight)
#logESS(sortedPs$logWeight[1:10000])
#logESS(sortedPs$logWeight[2000:8000])
#library("gganimate")
#gifplot <- ggplot(wCum, aes(x=logWeight)) + geom_histogram(bins=200) + transition_manual(iteration); animate(gifplot)

observedTrajectory <- wCum %>%
  group_by(iteration) %>%
  summarise(logRunningMean = logRunningMean(logWeight))

trainingTrajectory <- observedTrajectory %>% 
  filter(iteration <= 0.3 * maxIter) 

quadraticFit <- lm(logRunningMean ~ poly(iteration, 2, raw=TRUE), trainingTrajectory)
splineFit <- smooth.spline(trainingTrajectory)
fittedQuadraticTrajectory <- data.frame(iteration=1:maxIter, logRunningMean=predict(quadraticFit, data.frame(iteration=1:maxIter)))
fittedSplineTrajectory <- data.frame(predict(splineFit, 1:maxIter)); colnames(fittedSplineTrajectory) <- c("iteration", "logRunningMean")

ggplot() +
  geom_line(data=observedTrajectory, aes(x=iteration, y=logRunningMean, colour="ObservedTrajectory")) +
  geom_line(data=fittedSplineTrajectory,    aes(x=iteration, y=logRunningMean, colour="FittedSplineTrajectory"))
  # geom_line(data=fittedQuadraticTrajectory, aes(x=iteration, y=logRunningMean, colour="FittedQuadraticTrajectory"))


################################
# Spline trajectory estimation #
################################
df1 <- read.csv("~/projects/blangSDK/results/all/2021-05-19-01-16-53-UnBbaS8R.exec/samples/logIncrementalWeight.csv")
df2 <- read.csv("~/projects/blangSDK/results/all/2021-05-19-01-19-22-JwN6jHm1.exec/samples/logIncrementalWeight.csv") 
df3 <- read.csv("~/projects/blangSDK/results/all/2021-05-19-01-20-27-IorKzlwX.exec/samples/logIncrementalWeight.csv")
df4 <- read.csv("~/projects/blangSDK/results/all/2021-05-19-01-21-06-arNxSSoU.exec/samples/logIncrementalWeight.csv")
colnames(df1) <- column_names
colnames(df2) <- column_names
colnames(df3) <- column_names
colnames(df4) <- column_names
df1 <- df1 %>%
  group_by(particle) %>%
  mutate(logWeight = cumsum(logWeight))
df2 <- df2 %>%
  group_by(particle) %>%
  mutate(logWeight = cumsum(logWeight))
df3 <- df3 %>%
  group_by(particle) %>%
  mutate(logWeight = cumsum(logWeight))
df4 <- df4 %>%
  group_by(particle) %>%
  mutate(logWeight = cumsum(logWeight))
df1$ds <- 1
df2$ds <- 2
df3$ds <- 3
df4$ds <- 4
df <- rbind(df1, df2, df3, df4)
runningDf <- df %>%
  filter(iteration <= 100) %>% 
  group_by(iteration, ds) %>%
  summarise(logRunningMean = logRunningMean(logWeight))
fit <- smooth.spline(x=runningDf$iteration, y=runningDf$logRunningMean)
ggplot(runningDf, aes(x=iteration, y=logRunningMean, colour=as.factor(ds))) + geom_line() + 
 geom_line(data=data.frame(predict(fit, 1:1000)), aes(x=x, y=y, colour="aaa"))





  
  




