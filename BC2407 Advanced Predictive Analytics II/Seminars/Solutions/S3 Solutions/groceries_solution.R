# Purpose: arules on Groceries and useful functions
# Author: Chew C. H.
# Dataset: Groceries in arules Rpackage

library(arules)
data(Groceries)
class(Groceries)  ## transactions data type.

inspect(Groceries)

# Use data.frame so as to view the contents more easily as a table.
groceries.df <- as(Groceries, "data.frame")

# Get frequent itemsets via the ECLAT algo based on minsupp and max num of items.
frequent.items <- eclat(Groceries, parameter = list(supp = 0.05, maxlen = 10))
inspect(frequent.items)
itemFrequencyPlot(Groceries, topN=10, type="relative", main="Top 10 Item Frequency")

# Get association rules that satisfy minsupp & min conf
rules <- apriori (Groceries, parameter = list(supp = 0.001, conf = 0.5, minlen = 2))
inspect(rules)
rules.df <- as(rules, "data.frame")

# Get high conf rules programatically instead of sort confidence in df
rules.conf <- sort(rules, by="confidence")
rules.conf.df <- as(rules.conf, "data.frame")


# Q1: In rules.df, what's the difference betw support vs coverage?
# Ans: support = rule support = P(contains X and Y),
#      Coverage = Antecedent Support = P(contains X)


# Q2: Generate rules that has rolls/buns in RHS, supp >= 0.001 and confidence >= 0.65. i.e. To recommend rolls/buns.
rules.rhs.buns <- apriori(Groceries, parameter = list(supp = 0.001, conf = 0.65, minlen = 2),
                  appearance = list (default="lhs", rhs="rolls/buns"))
rules.rhs.buns.df <- as(rules.rhs.buns, "data.frame")


# Q3: Select a subset of rules from line 20 that contains yogurt in LHS and coverage > 2%.
rules.lhs.yogurt <- subset(rules, subset = lhs %pin% "yogurt" & coverage > 0.02)
rules.lhs.yogurt.df <- as(rules.lhs.yogurt, "data.frame")
## View R documentation: ?subset and ?rules


# Q4: Get the Support, Conf and Lift for 2 specific rules:
#       {curd,yogurt} => {whole milk} and {rolls/buns} => {butter}
rules.results <- new("rules", 
               lhs = encode(list(c("curd", "yogurt"), c("rolls/buns")),
                            itemLabels = itemLabels(Groceries)),
               rhs = encode(list(c("whole milk"), c("butter")),
                            itemLabels = itemLabels(Groceries)))

quality(rules.results) <- interestMeasure(rules.results, 
                                    measure = c("support", "confidence", "lift"),
                                    transactions = Groceries)

inspect(rules.results)


# Q5: How many redundant rules are generated in line20? Remove them from the rules.
sum(is.redundant(rules))
rules.clean <- rules[!is.redundant(rules)]
rules.clean.df <- as(rules.clean, "data.frame")
#=================================== END =======================================