# INPUT:
# <<cat_C_hat.mat>>, which is a 2D matrix, with 9*(dM+1) rows. 
# the last column of cat_C_hat is from raw(untransformed) images.
# the other columns correspond to the MM transform, with gamma from 0.1 to 1.0 respectively.
# Rows store the spatio-chromatic covariance estimates from pixel distance 0 to dM of all 9 color channel combinations.
# Rows are in the order of c^0_RR, c^1_RR, ..., c^dM_RR, c^0_RG, ..., c^dM_RG, ..., c^dM_BB.

library(R.matlab)
library(jointDiag)

path<-"~" #the absolute path of cat_C_hat.mat's folder
setwd(path)
pathname <- file.path(path,"cat_C_hat.mat")
dt <- readMat(pathname)
cat_C_hat <- dt$y

comp_JD_obj <- function(cat_C_hat, dM){
  
  n <- ncol(cat_C_hat) #the number of transform to be measured
  JD_obj_track <- matrix(-1,n,200)
  JD_obj <- 1:n
  
  for(j in 1:n){
    
    #data preparation
    C_hat <- matrix(cat_C_hat[,j], 281, 9)
    C <- array(data = 0, dim = c(3,3,(dM+1)))
    for(i in 1:(dM+1)){C[,,i] <- matrix(C_hat[i, ],3,3)}
    
    #jointly diagolize
    r <- ffdiag(C) #FFDiag joint diagonalization algorithm
    
    #get JD-obj
    JD_obj_track[j,1:length(r$criter)] <- r$criter
    JD_obj[j] <- JD_obj_track[j,length(r$criter)]
    
  }
  
  return(JD_obj)
  
}


#model selection
JD_obj_dM <- matrix(NA, 280, ncol(cat_C_hat))

for (dM in 1:280) {
  print(dM)
  JD_obj_dM[dM,] <- comp_JD_obj(cat_C_hat, dM)
}

int <- 2:11 #we do not consider gamma = 0.1, because it is almost a constant transform
opt_gamma <- apply(JD_obj_dM[,int], 1, which.min) + 1


#visualization
plot(1:280, opt_gamma, 'p', pch='.', cex=3, xaxt = "n", yaxt = "n", xlab = "pixel distance", ylab = expression(gamma))
axis(1, at=c(5,22,41,58,71,89,117,171,262))
axis(2, at=2:10, labels = seq(0.2,1.0,0.1))


dM <- 70
pdf(paste0(dM,'.pdf'),13.6875,9.375)
plot(seq(0.2,1.0,0.1), JD_obj_dM[dM, 2:10], 'b', pch='.', cex=5, xlab = expression(gamma), ylab = "JD-obj(MM)", main = paste0('dM = ',dM))
points(seq(0.2,1.0,0.1)[which.min(JD_obj_dM[dM, 2:10])],min(JD_obj_dM[dM, 2:10]), col='red')
abline(h=JD_obj_dM[dM,11])
text(0.95,JD_obj_dM[dM,11] + max(JD_obj_dM[dM,2:10])*0.025,"JD-obj(raw)")
dev.off()

