# ========================================================================================================
# Purpose:      Rscript for Neuralnet demo.
# Author:       Neumann
# DOC:          15-03-2018
# Topics:       Neural Network with scaled continuous variables and dummied categorical X
# Data Source:  infert in base package datasets
#=========================================================================================================

data(infert)  # load dataset from R base package
help(infert)  # view documentation of the dataset infert
# Parity = Num of Births.
# Target variable is case. case = 1 (infertile) or 0 (not infertile).

library(neuralnet)
set.seed(2014)  # for random starting weights

infert$age1 <- (infert$age - min(infert$age))/(max(infert$age)-min(infert$age))
infert$parity1 <- (infert$parity - min(infert$parity))/(max(infert$parity)-min(infert$parity))

# If domain experts agree that having 2 abortions has the same impact on infertility as 3, 4 or more abortions, then treat it as continuous.
# Let's treat it as categorical and see what happens. Neuralnet cannot handle factors, unlike nnet. Thus need to manually create dummy variables.
infert$induced1 <- ifelse(infert$induced==1, 1, 0)
infert$induced2 <- ifelse(infert$induced==2, 1, 0)
infert$spontaneous1 <- ifelse(infert$spontaneous==1, 1, 0)
infert$spontaneous2 <- ifelse(infert$spontaneous==2, 1, 0)

# Neural Network comprising 1 hidden layer with 2 hidden nodes for binary categorical target
m2 <- neuralnet(case~age1+parity1+induced1+induced2+spontaneous1+spontaneous2, data=infert, hidden=2, err.fct="ce", linear.output=FALSE)
## Stop adjusting weights when all gradients of the error function were smaller than 0.01 (the default threshold).

par(mfrow=c(1,1))
plot(m2)

m2$net.result  # predicted outputs. 
m2$result.matrix  # summary. Error = 116.99
m2$startweights
m2$weights
# The generalized weight is defined as the contribution of the ith input variable to the log-odds:
m2$generalized.weights
## Easier to view GW as plots instead

par(mfrow=c(2,3))
gwplot(m2,selected.covariate="age1", min=-2.5, max=5)
gwplot(m2,selected.covariate="parity1", min=-2.5, max=5)
gwplot(m2,selected.covariate="induced1", min=-2.5, max=5)
gwplot(m2,selected.covariate="induced2", min=-2.5, max=5)
gwplot(m2,selected.covariate="spontaneous1", min=-2.5, max=5)
gwplot(m2,selected.covariate="spontaneous2", min=-2.5, max=5)
## Age is now a significant factor. Shows importance of scaling.

# Display inputs with model outputs
out <- cbind(m2$covariate, m2$net.result[[1]])
dimnames(out) <- list(NULL, c("age1","parity1","induced1", "induced2", "spontaneous1", "spontaneous2", "nn-output"))
head(out)  # shows first 6 rows of data.

# m1 (Neural Network based on unscaled X version from infert.r)
# Run infert.R to get m1 before trying to get confusion matrix.
pred.m1 <- ifelse(unlist(m1$net.result) > 0.5, 1, 0)
cat('Trainset Confusion Matrix with neuralnet (1 hidden layer, 2 hidden nodes, Unscaled X):')
table(infert$case, pred.m1)

pred.m2 <- ifelse(unlist(m2$net.result) > 0.5, 1, 0)
cat('Trainset Confusion Matrix with neuralnet (1 hidden layer, 2 hidden nodes, Scaled X):')
table(infert$case, pred.m2)

# Output dataset as infert.csv for import into SAS
write.csv(infert, file = 'infert.csv')
