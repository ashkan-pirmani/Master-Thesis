library(rJava)
library(RNetLogo)
setwd("C:/Program Files/NetLogo 6.0.3/app")
nl.path<-getwd()
NLStart("C:/Program Files/NetLogo 6.0.3/app", gui = TRUE, nl.jarname = "netlogo-6.0.3.jar")
model.path <- file.path("models", "Sample Models", "Earth Science", "Fire.nlogo")
NLLoadModel(model.path )
NLCommand("setup")
burned <- NLDoReportWhile("any? turtles", 
                          "go",
                          c("ticks", "(burned-trees / initial-trees) * 100"),
                          as.data.frame = TRUE, 
                          df.col.names = c("tick", "percentburned"))
plot(burned, type = "s")
