##### NetLogo Parallelization  ----

library(rJava)
library(RNetLogo)
#path where netlogo.jar file is stored - ymmv
setwd("C:/Program Files/NetLogo 6.0.3/app") 

# load the parallel package
library(parallel)

# detect the number of cores available
processors <- detectCores()
processors

# create a cluster
cl <- makeCluster(processors)
cl


### When using parallelization, everything has to be done for every processor separately.
# Therefore, make functions:

# the initialization function
prepro <- function(dummy, gui=TRUE, nl.path, model.path) {
  library(RNetLogo)
  NLStart(nl.path, gui=TRUE,nl.jarname = "netlogo-6.0.3.jar")
  NLLoadModel(model.path)
}


simfun <- function(density) {
  
  sim <- function(density) {
    NLCommand("set density ", density, "setup")
    NLDoCommandWhile("any? turtles", "go");
    ret <- NLReport("(burned-trees / initial-trees) * 100")
    return(ret)
  }
  
  lapply(density, function(x) replicate(20, sim(x)))
}



# the quit function
postpro <- function(x) {
  NLQuit()
}


### Start Cluster
#run the initialization function in each processor, which will open as many NetLogo windows as we have processors


# set variables for the start up process
# adapt path appropriate (or set an environment variable NETLOGO_PATH)
gui <- TRUE
nl.path <- Sys.getenv("NETLOGO_PATH", "C:/Program Files/NetLogo 5.3.1/app")
model.path <- "models/Sample Models/Earth Science/Fire.nlogo"


# load NetLogo in each processor/core
invisible(parLapply(cl, 
                    1:processors, 
                    prepro, 
                    gui=TRUE,
                    nl.path=nl.path, 
                    model.path=model.path)
)


### Run over these 11 densities
d <- seq(55, 65, 1)
result.par <- parSapply(cl, d, simfun) # runs the simfunfunction over  clusters varying by density
result.par

burned.df <- data.frame(density=rep(55:65,each=20), pctburned=unlist(result.par))

library(ggplot2)
ggplot(burned.df, aes(x=factor(density), y=pctburned)) + geom_boxplot(alpha=.1) + geom_point()





# Quit NetLogo in each processor/core
invisible(parLapply(cl, 1:processors, postpro))

# stop cluster
stopCluster(cl)
