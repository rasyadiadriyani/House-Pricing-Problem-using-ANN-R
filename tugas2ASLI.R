require(data.table)
require(stringr)
require(lubridate)
require(zoo)
require(lightgbm)


train <- read.csv("ml2/train.csv", header = TRUE)
test <- read.csv("ml2/test.csv", header = TRUE)
train <- train[,c("OverallQual", "GrLivArea", "TotalBsmtSF", "GarageCars",
                  "FullBath", "SalePrice")]

train <- train[,c("OverallQual", "GrLivArea", "TotalBsmtSF", "GarageCars",
                  "FullBath", "SalePrice")]

test <- test[,c("OverallQual", "GrLivArea", "TotalBsmtSF", "GarageCars",
                  "FullBath")]

train_o <- train

summary(train$SalePrice) 
summary(train$OverallQual) 
summary(train$GrLivArea)
summary(train$TotalBsmtSF)
summary(train$GarageCars)
summary(train$FullBath)

summary(test$SalePrice) 
summary(test$OverallQual) 
summary(test$GrLivArea)
summary(test$TotalBsmtSF)
summary(test$GarageCars)
summary(test$FullBath)

summary(test$TotalBsmtSF)
test$TotalBsmtSF[which(is.na(test$TotalBsmtSF))] <- 988.0

summary(test$GarageCars)
test$GarageCars[which(is.na(test$GarageCars))] <- 2.0
train_o <- train

UDF <- function(x) {
  (x -min(x))/ (max(x)- min(x))
}

train <- as.data.frame(apply(train, 2, UDF))
test <- as.data.frame(apply(test, 2, UDF))

index <- sample(nrow (train), round(0.6 * nrow(train)))

train.wp <- train[index,]
test.wp <- train[-index,]

library(neuralnet)

allVars <- colnames(train)
predictorVars <- allVars[!allVars%in%"SalePrice"]
predictorVars <- paste(predictorVars, collapse = "+")
form = as.formula(paste("SalePrice~", predictorVars, collapse = "+"))

nn_model <- neuralnet(formula = form, train.wp, hidden = c(4,2), linear.output = TRUE)

nn_model$net.result
plot(nn_model)

prediction1 <- compute(nn_model, test)
str(prediction1)

UDF_2 <- function(prediction) {
     prediction1$net.result * (max(train_o$SalePrice)-min(train_o$SalePrice)) + min(train_o$SalePrice)
}

ActualPrediction <-  prediction1$net.result * (max(train_o$SalePrice)-min(train_o$SalePrice)) + min(train_o$SalePrice)

table(ActualPrediction)

submit.df <- data.frame(Id = rep(1461:2919), SalePrice= ActualPrediction)
write.csv(submit.df, file = "ml2/Submission_20171130_4.csv", row.names = FALSE)

mydata <- train[, c("OverallQual", "GrLivArea", "TotalBsmtSF", "GarageCars",
                     "FullBath", "SalePrice")]

train_ <- round(cor(mydata),2)
head(train_)
library(reshape2)
melted_train <- melt(train_)
head(melted_train)
library(ggplot2)
ggplot(data = melted_train, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()
head(mydata)