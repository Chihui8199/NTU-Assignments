# Chocolate Taste Test (CTT) Neural Network
# AUthor: Neumann Chew C.H.

# Create example data CTT
ctt.data <- data.frame(ID = seq(1:7),
                       Sugar = c(0.2, 0.1, 0.2, 0.2, 0.4, 0.4, 0.6),
                       Milk = c(0.9, 0.1, 0.4, 0.5, 0.5, 0.8, 0.7),
                       Taste = c(1, 0, 0, 0, 1, 1, 1))

library(neuralnet)

set.seed(2014)        # initialise random starting weights

# 1 hidden layer with 3 hidden nodes for binary categorical target
ctt.m1 <- neuralnet(Taste ~ Sugar + Milk, data = ctt.data, hidden = 3, err.fct="ce", linear.output=FALSE)

ctt.m1$startweights   # starting weights used
ctt.m1$weights        # Final optimised weights

ctt.m1$net.result     # predicted outputs. 
ctt.m1$result.matrix  # summary.

# View final weights Neural Network diagram
plot(ctt.m1)