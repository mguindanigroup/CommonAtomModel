Rcpp::sourceCpp("Functions/CAM/newCAM.cpp")

# Chang with the name of the model
model <- "NDP"




time      <- timescale <- matrix(NA,30,3)
PSMs <- psm <- list()
CLUs <- clu <- list()

gt <- rep(1:6,2)
# Distributional Clusters -------------------------------------------------
gt_distr   <- rep(1:6,2)
DC_GT_PSM  <- mcclust::comp.psm(rbind(gt_distr,gt_distr))
maxGTD <- StatPerMeCo::Frobenius(
  matrix(0,nrow(DC_GT_PSM),ncol(DC_GT_PSM)),
  matrix(1,nrow(DC_GT_PSM),ncol(DC_GT_PSM)))

perc <- nclu <- aran <- frob <- matrix(NA,30,3)
for(K in 1:3){

  for(i in 1:30){
  path <-   paste0("Competitors/Results_",model,"/out_",model,"_S1a_n",K*25,"_",i,".RDS")
  obj  <-   readRDS(path)
  time[i,K] <- as.numeric(obj$time)
  timescale[i,K] <- attr(obj$time,which = "units")

  Z <- t(obj$model$zj[,,1])
  psm[[i]] <- PSM(Z)

  clu[[i]]  <- mcclust.ext::minVI(psm[[i]],method = "greedy")$cl
  nclu[i,K] <- length(unique(clu[[i]]))
  aran[i,K] <- mcclust::arandi(clu[[i]],gt_distr)
  frob[i,K] <- StatPerMeCo::Frobenius(psm[[i]],DC_GT_PSM)/maxGTD
  cat(i)
}
  # CLUs[[K]] <- clu
  # PSMs[[K]] <- psm
}
savepath     <- paste0("Competitors/Results_",model)
savepathtime <- paste0(savepath,"/Time_",model,"_S1a.RDS")
savepathres  <- paste0(savepath,"/Results_",model,"_S1a.RDS")


time <- ifelse(timescale=="hours", time*60, time)
time <- ifelse(timescale=="days", time*60*24, time)
Times <- list(time)
RES <- list(numclust=nclu,ARI=aran,NFD=frob)

saveRDS(Times,savepathtime)
saveRDS(RES,savepathres)
