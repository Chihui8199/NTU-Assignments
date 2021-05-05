# ========================================================================================================
# Purpose:      Rscript for Neuralnet demo.
# Author:       Neumann
# DOC:          15-03-2018
# Topics:       Neural Network if no scaling of continuous variables and no categorical X
# Data Source:  infert in base package datasets
#=========================================================================================================

data(infert)  # load dataset from R base package
help(infert)  # view documentation of the dataset infert
# Parity = Num of Births.
# Target variable is case. case = 1 (infertile) or 0 (not infertile).

library(neuralnet)
set.seed(2014)  # for random starting weights
# Neural Network comprising 1 hidden layer with 2 hidden nodes for binary categorical target
m1 <- neuralnet(case~age+parity+induced+spontaneous, data=infert, hidden=2, err.fct="ce", linear.output=FALSE)
## Stop adjusting weights when all gradients of the error function were smaller than 0.01 (the default threshold).

par(mfrow=c(1,1))
plot(m1)

m1$net.result  # predicted outputs
m1$result.matrix  # summary
m1$startweights
m1$weights

# The generalized weight is defined as the contribution of the ith input variable to the log-odds:
m1$generalized.weights
## Easier to view GW as plots instead

par(mfrow=c(2,2))
gwplot(m1,selected.covariate="age", min=-2.5, max=5)
gwplot(m1,selected.covariate="parity", min=-2.5, max=5)
gwplot(m1,selected.covariate="induced", min=-2.5, max=5)
gwplot(m1,selected.covariate="spontaneous", min=-2.5, max=5)
## Age is not a significant factor. Close to GW = zero.

# Display inputs with model outputs
out <- cbind(m1$covariate, m1$net.result[[1]])
dimnames(out) <- list(NULL, c("age","parity","induced", "spontaneous","nn-output"))
head(out)  # shows first 6 rows of data.

