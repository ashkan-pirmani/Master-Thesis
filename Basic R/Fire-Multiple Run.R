library(rJava)
library(RNetLogo)
setwd("C:/Program Files/NetLogo 6.0.3/app")
nl.path<-getwd()
NLStart("C:/Program Files/NetLogo 6.0.3/app", gui = TRUE, nl.jarname = "netlogo-6.0.3.jar")
model.path <- file.path("models", "Sample Models", "Earth Science", "Fire.nlogo")
NLLoadModel(model.path)
NLCommand("setup")
density <- c(57:60)
burned <- list()
for(i in seq_along(density)){
  NLCommand("set density ", density[i], "setup")
  burned[[i]] <- NLDoReportWhile("any? turtles", 
                                 "go",
                                 c("ticks", "(burned-trees / initial-trees) * 100"),
                                 as.data.frame = TRUE, 
                                 df.col.names = c("tick", "percentburned"))
  
}
burned.dt <- data.table::rbindlist(Map(cbind, burned, density=57:60))
library(ggplot2)
ggplot(burned.dt, aes(x=tick, y=percentburned, group=factor(density), 
                      color=factor(density))) +
  geom_path(lwd=1) + theme_bw()
