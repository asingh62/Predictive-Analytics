# Online News Popularity
# Data Mining - Final Project Code - R Script
# Maazuddin Mohammed(G01192302), Amrita Jose(G01233664), Asmita Singh(G01212983), Yeshwanth Reddy Bommu(G01197092)


############################### PROJECT AND DATASET DESCRIPTION ##########################################

# The dataset for our project is about the Online News Popularity of Mashable articles; the source of the dataset is UCI Machine Learning Repository. 
# The dataset contains 39,797 instances and 61 attributes. The attributes contain both quantitative (like the number of images, number of videos, etc.) and qualitative (like which day it was published and which topic the article falls under) information about the article. 
# The popularity of the article is measured using the Response variable (shares attribute).  
# We want to predict the popularity of a given article based on the given attributes. 

# The goal of this analysis is to determine the popularity of a news article based on the number of shares or the number of times the article has been shared on any social network or platform. 
# The response/target variable is the number of shares which is predicted using a couple of feature/predictor variables.


############################### IMPORTANCE OF THE PROJECT ##########################################

# Accelerated growth of online news service and social media have increased the importance of learning and understanding readers' unseen behavioural patterns.
# We can predict the popularity of an online news article and determine whether it will draw significant attention. 
# Finding out the relationship between the response variable (Number of shares) and other predictors, we can build a model that helps us decide the content of articles or the timing of the release to maximize the popularity of the articles. 


############################### METHODS/MODELS USED FOR THE PROJECT ##########################################

# The following methods/models have been used to predict the popularity of news: -

#  1.  K NEAREST NEIGHBOUR(KNN)
#  2.  CLASSIFICATION AND REGRESSION TREES(CART)
#  3.  NAIVE BAYES
#  4.  RANDOM FOREST
#  5.  LOGISTIC REGRESSION
#  6.  LINEAR REGRESSION

############################### CRITERIA FOR BEST MODEL SELECTION ##########################################

# We have used both Accuracy and F1 score to determine the best model. 
# The model with the highest value of accuracy and F1 score has been selected as the best model. 


#------------------------------- CODE BEGINS HERE ----------------------------------------------------------

# Import the libraries
library(gmodels)
library(caret)
library(class)
library(pROC)
library(rpart)
library(rattle)
library(dplyr)
library(e1071)
library(tidyverse)
library(corrplot)
library(prediction)
library(ROCR)
library(randomForest)
# Read the file
setwd("C:/Users/Amrita/Documents/GMU/OR 568/Datasets/data")
#setwd("C:/Users/Asmita Singh/Documents/GMU/OR 568/data")
#setwd("C:/Users/majaa/Desktop/OR-568/Project")


news <- read.csv("OnlineNewsPopularity.csv", stringsAsFactors = FALSE)

# Basic operations
str(news)
summary(news$shares)
boxplot(news$shares)

###############################EXPLORATORY DATA ANALYSIS AND DATA CLEANING/PREPROCESSING##########################################

# Check for any missing values:
sum(is.na(news))
# The data has no missing values

# Based on the summary of the dataset above, it can be seen that there is outlier in "n_unique_tokens", "n_non_stop_words", and "n_non_stop_unique_tokens". Hence removing that observation
news <- news[!news$n_unique_tokens==701,]

# Remove url and timedelta from the dataset using subset, as url and timedelta are non predictive variables 
news <- subset(news, select = -c(url, timedelta))
news$shares<- as.numeric(news$shares)
newsexplore<-news

# Heat Map for Correlation between all variables
cormatrix <- cor(newsexplore)
heatmap(cormatrix)
#From the above heatmap it can be observed that certain groups of variables are close to each other.
#However, all variables have low correlation with the target variable - number of shares.


#Combining Plots for EDA for visual analysis
par(mfrow=c(2,2))
for(i in 2:length(news)){hist(news[,i],
                              xlab=names(news)[i] , main = paste("[" , i , "]" ,
                                                                 "Histogram of", names(news)[i])  )}
# From the above data distributions, the following can be observed:-
# 1. there is outlier in "n_unique_tokens", "n_non_stop_words", and "n_non_stop_unique_tokens"
# 2. The dataset could possibly have some missing values which might be coded as 0 and hence difficult to find
# 3. Based on the distributions, it can be seen that the data is skewed to some extent.

# Determining the effect of weekdays and weekends on number of shares
for (i in 31:37){
  boxplot(log(news$shares) ~ (news[,i]), xlab=names(news)[i] , ylab="shares")
}
# Observing the above box plots, it can be said that weekdays show some effect on shares.However, they can also be chosen to be not considered due to the very small effect. 
# However, weekends seem to have more considerable effect.

# Determining the effect of news categories on shares
for (i in 12:17){
  boxplot(log(news$shares) ~ (news[,i]), xlab=names(news)[i] , ylab="shares")
}
#Observing the boxplots, news categories also seem to have very small effect on the number of shares and can be ignored if required.

# Converting shares to response varaible with 1400 as median value 
news$shares <- as.factor(ifelse(news$shares >1400,1,0))

# get the number of 1's and 0's
table(news$shares)

# Results in percentage form
round(prop.table(table(news$shares)) * 100, digits = 1)

######################################################################################################################
################################# MODEL 1 - K Nearest Neighbour(KNN) #################################################

# KNN which stand for K Nearest Neighbor is a Supervised Machine Learning algorithm that classifies a new data point into the target class, depending on the features of its neighboring data points.
# K-Nearest Neighbor based classifier classifies a query instance based on the class labels of its neighbor instances where new data are classified based on stored, labeled
# instances. It classifies data points based on the points that are most similar to it and uses test data to make an “educated guess” 
# on what an unclassified point should be classified as. Online popularity news dataset.

# Data Normalization
# Normalization
normalize <- function(x) {
  return ((x - min(x))/(max(x) - min(x)))}

news.subset.n <- as.data.frame(lapply(news[,1:58], normalize))
head(news.subset.n)

# Data Splicing
set.seed(1)
news_dataset <- sample(2, nrow(news.subset.n), replace=TRUE, prob=c(0.80, 0.20))

# Creating seperate dataframe for predictors
news.training <- news[news_dataset==1, 1:58]
news.test <- news[news_dataset==2, 1:58]

# Creating seperate dataframe for 'shares' feature which is our target.
news.trainLabels <- news[news_dataset==1, 59]
news.testLabels <- news[news_dataset==2, 59]

newsdatatraining <- news[news_dataset==1, 1:59]
newsdatatest <- news[news_dataset==2, 1:59]

# Building a KNN Machine Learning model
news_pred1 <- knn(train = news.training, test = news.test, cl = news.trainLabels, k=1)
confusionMatrix(table(news_pred1 ,news.testLabels))

news_pred5 <- knn(train = news.training, test = news.test, cl = news.trainLabels, k=5)
confusionMatrix(table(news_pred5 ,news.testLabels))

news_pred10 <- knn(train = news.training, test = news.test, cl = news.trainLabels, k=10)
confusionMatrix(table(news_pred10 ,news.testLabels))

news_pred15 <- knn(train = news.training, test = news.test, cl = news.trainLabels, k=15)
confusionMatrix(table(news_pred15 ,news.testLabels))

# Model Evaluation
# Calculate the proportion of correct classification for k = 1,5,10,15
accuracy.1 <- round(sum(news.testLabels == news_pred1)/NROW(news.testLabels),2)
print(paste0("Accuracy for k=1: ", accuracy.1))
accuracy.5 <- round(sum(news.testLabels == news_pred5)/NROW(news.testLabels),2)
print(paste0("Accuracy for k=5: ", accuracy.5))
accuracy.10 <- round(sum(news.testLabels == news_pred10)/NROW(news.testLabels),2)
print(paste0("Accuracy for k=10: ", accuracy.10))
accuracy.15 <- round(sum(news.testLabels == news_pred15)/NROW(news.testLabels),2)
print(paste0("Accuracy for k=15: ", accuracy.15))

# Accuracy for k=15 is 58.18 - highest among all.

# KNN Optimization, checking the best value of k between 1:30
i=1
k.optm=1
for (i in 1:30){
  knn.mod <- knn(train = news.training, test = news.test, cl = news.trainLabels, k=i)
  k.optm[i] <- 100 * sum(news.testLabels == knn.mod)/NROW(news.testLabels)
  k=i
  cat(k,'=',k.optm[i],'')
}
# 1 = 54.26327 2 = 54.21259 3 = 56.26504 4 = 55.36551 5 = 56.74648 6 = 56.55644 7 = 56.78449 8 = 57.39263 9 = 57.59534 10 = 57.43063 11 = 57.69669 12 = 57.54466 13 = 57.8614 14 = 57.72203 15 = 58.20347 16 = 57.69669 17 = 57.96275 18 = 58.44419 19 = 58.73559 20 = 58.59622 21 = 58.82427 22 = 58.84961 23 = 58.7736 24 = 58.52021 25 = 58.87495 26 = 58.57089 27 = 58.65957 28 = 58.39351 29 = 58.82427 30 = 58.6469
# From the output we can see that for K = 25, we achieve the maximum accuracy, i.e. 58.88%.

# Accuracy plot
plot(k.optm, type="b", xlab="K- Value",ylab="Accuracy level")
# The above graph shows that for ‘K’ value of 25 we get the maximum accuracy.

# Building a KNN Machine Learning model for k=25
news_pred25 <- knn(train = news.training, test = news.test, cl = news.trainLabels, k=25)
confusionMatrix(table(news_pred25 ,news.testLabels))

# Accuracy, Precision, Recall, F-measure Calculation for k = 25
xtab = table(news_pred25, news.testLabels)
print(xtab)

accuracy.25 <- round(sum(news.testLabels == news_pred25)/NROW(news.testLabels),2)
print(paste0("Accuracy for knn, k=25: ", accuracy.25))

precision.knn = round(xtab[1,1]/sum(xtab[,1]),2)
print(paste0("Precision for knn: ", precision.knn))

recall.knn = round(xtab[1,1]/sum(xtab[1,]),2)
print(paste0("Recall for knn: ", recall.knn))

fmeasure.knn = round(2 * (precision.knn * recall.knn) / (precision.knn + recall.knn),2)
print(paste0("F-measure for knn: ", fmeasure.knn))

# knn3 nearest neighbour classification can return class votes for all classes
newsknn3 <- knn3(shares ~., newsdatatraining)

# Predict
newsknn3prob <- predict( newsknn3,newsdatatest,type="prob")

# ROC Curve
# Getting AUC, AUC confidence interval
news.knn.roc <- roc(newsdatatest$shares, newsknn3prob[,2])
plot(news.knn.roc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2), grid.col=c("grey", "black"), max.auc.polygon=TRUE, auc.polygon.col='#9ebcda', print.thres=TRUE, main="ROC for KNN")

# AUC shows the predictive ability of the model, the higher the AUC the more predictive the marker.
# In this case, AUC is 0.590, it means the model has no discrimination capacity to distinguish between the two classes.

# KNN performance after optimizing the value of k = 25
# Accuracy - 58.89 |   Precision - 0.64    |  Recall - 0.58  |  #F-Score - 0.61

#####################################################################################################################################
################################# MODEL 2 - Classification and Regression Tress (CART)  #############################################

# A Decision Tree is a supervised learning predictive model that uses a set of binary rules to calculate a target value.It is used for either classification (categorical target variable) or regression (continuous target variable). Hence, it is also known as CART (Classification & Regression Trees)
# With Classification Trees, we report the average outcome at each leaf of our tree. However, Instead of just taking the majority outcome to be the prediction, we can compute the percentage of data in a subset of each type of outcome.

# Data Splicing
set.seed(2)
news_dataset <- sample(2, nrow(news), replace=TRUE, prob=c(0.80, 0.20))

news.training <- news[news_dataset==1, 1:59]
news.test <- news[news_dataset==2, 1:59]

# Classification and Regression Trees - Fully grown trees
newscart <- rpart(shares ~., news.training, method='class')

# Plot the trees
par(xpd = NA) # Avoid clipping the text in some device
plot(newscart)
text(newscart, digits = 3)

# Predict the test data
# Make predictions on the test data
predicted.classes <- newscart %>% predict(news.test, type = "class")
head(predicted.classes)

# Compute model accuracy rate on test data
mean(predicted.classes == news.test$shares)
# The overall accuracy of our tree model is 62.86%.

# Decision Tree (CART) with Pruning

# it is easy to see that, a fully grown tree will overfit the training data and might lead to poor test set performance.
# A strategy to limit this overfitting is to prune back the tree resulting to a simpler tree with fewer splits and better interpretation at the cost of a little bias

# We can use the following arguments in the function train() [from caret package]:
# trControl, to set up 10-fold cross validation
# tuneLength, to specify the number of possible cp values to evaluate. Default value is 3, here we’ll use 10.

# Fit the model on the training set
set.seed(2)
newscart.prune <- train(
  shares ~., data = news.training, method = "rpart",
  trControl = trainControl("repeatedcv", number = 10, repeats = 5),
  tuneLength = 10
)

# Plot model accuracy vs different values of cp (complexity parameter)
plot(newscart.prune)

# Print the results from all models
print(newscart.prune$results)

# Print the best tuning parameter cp that maximizes the model accuracy
newscart.prune$bestTune
# best cp - 0.002741897

# Plot the final tree model
par(mfrow=c(1,1),xpd = NA)
plot(newscart.prune$finalModel)
text(newscart.prune$finalModel, digits = 3)

# Results of the model:
# The kw_avg_avg is the most important split.
# It appears in there twice, so it’s, in some sense i.e. if it’s greater than a certain amount or less than a certain amount, it does different things.

# Decision rules in the model
newscart.prune$finalModel

# feature importance
newscart.prune$finalModel$variable.importance

# Predict on test data 
predicted.classes <- predict(newscart.prune,news.test)
news.Cart.Prob.Pred <- predict(newscart.prune, news.test, type="prob")

# Confusion matrix
confusionMatrix(predicted.classes, news.test$shares)

# Confusion matrix in tabular format
confMat <- table(news.test$shares,predicted.classes)

# Accuracy, Precision, Recall, F-measure Calculation
accuracy.cart <- round(sum(diag(confMat))/sum(confMat),2)
print(paste0("Accuracy for CART: ", accuracy.cart))

precision.cart = round(confMat[1,1]/sum(confMat[,1]),2)
print(paste0("Precision for CART: ", precision.cart))

recall.cart = round(confMat[1,1]/sum(confMat[1,]),2)
print(paste0("Recall for CART: ", recall.cart))

fmeasure.cart = round(2*precision.cart*recall.cart / (precision.cart + recall.cart),2)
print(paste0("F-measure for CART: ", fmeasure.cart))

# From the output above, it can be seen that the best value for the complexity parameter (cp) is 0.002741897, allowing a simpler tree, easy to interpret, 
# with an overall accuracy of 64.15%, which is comparable to the accuracy (62.86%) that we have obtained with the full tree. 
# The prediction accuracy of the pruned tree is even better compared to the full tree.

# ROC Curve
# Getting AUC, AUC confidence interval
news.cart.Roc <- roc(news.test$shares,news.Cart.Prob.Pred[,2])
plot(news.cart.Roc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.1), grid.col=c("grey", "black"), max.auc.polygon=TRUE, auc.polygon.col='#fee8c8', print.thres=TRUE)

# AUC shows the predictive ability of the model, the higher the AUC the more predictive the marker.
# In this case, AUC is 0.671, it means there is 67.1% chance that model will be able to distinguish between the two classes.

# CART performance after pruning
# Accuracy - 0.64 |   Precision - 0.66    |  Recall - 0.59  |  #F-Score - 0.62

###################################################################################################################
########################################### MODEL 3 - NAIVE BAYES ##################################################

# Naive Bayes is a probabilistic classification technique based on Bayes Theorem. The classifier assumes independence among predictor variables due to which it is called naive.
# Bayes Theorem describes the probability of an event based on prior conditions/evidence/variables that are related to the event or target variable.
# Naive Bayes Classifier is used to determine the significant predictors of popular news which is the number of shares.
# In order to do justice to its assumption of the predictor variables being independent or uncorrelated, the model is tuned in the second phase by removing the highly correlated variables.

# Data Splicing
set.seed(3)
news_dataset <- sample(2, nrow(news), replace=TRUE, prob=c(0.80, 0.20))

# Creating seperate dataframe for predictors
news.training <- news[news_dataset==1, 1:59]
news.test <- news[news_dataset==2, 1:59]

# Creating seperate dataframe for 'shares' feature which is our target.
news.trainLabels <- news[news_dataset==1, 59]
news.testLabels <- news[news_dataset==2, 59]

# Training Naive Bayes Model
nbmodel <- naiveBayes(news.trainLabels ~ ., data=news.training)
nbmodel
# From the training data results it can be seen than 49.48% of the articles are popular

# Predicting on test data
nbprediction <- predict(nbmodel,news.test)
nbprob <- predict(nbmodel,news.test,type="raw",drop=F)

# Confusion matrix to check accuracy
confnb<-table(nbprediction,news.testLabels)
confnb
# We were able to classify 3740 out of 4062 "not popular" cases correctly
# We were able to classify 3529 out of 3870 "popular" cases correctly
# Hence the ability of Naive Bayes to predict the articles that are not popular is 92.07% and the ability to predict popular articles is 91.19%
# Hence the overall accuracy is 91.64%. This value is directly calculated using below method
Accuracy <- sum(diag(confnb))/sum(confnb)
summary(confnb)

# Following is another code for confusion matrix
conf<-confusionMatrix(nbprediction,news.testLabels)

# Precision
nbprecision<-conf$byClass['Pos Pred Value'] 
nbprecision

# Recall
nbrecall<-conf$byClass['Sensitivity']
nbrecall

# F score
nb_fscore<-2*((nbprecision*nbrecall)/(nbprecision+nbrecall))
nb_fscore

# Naive Bayes Initial Performance
#Accuracy - 91.64%  |   #F-Score - 0.918    |  Precision - 0.916  |  Recall - 0.92

# Improving model by feature selection(removing higly correlated variables)
# Scaling the numeric values first in order to determine high correlations
scalednews <- scale(newsexplore, center=TRUE, scale = TRUE)
x<- cor(scalednews)
newscor<- findCorrelation(x, 0.30)

# Variables with high correlations that should be filtered
newscor

# New dataset
filterednewsdata<- news[, -(newscor)]
str(filterednewsdata)
#Hence the dataset has 27 variables after filtering out all the highly correlated variables that could cause multicollinearity

# Dividing the filtered data into training and test sets in 80:20 train:test ratio
set.seed(3)
filterednews_dataset <- sample(2, nrow(filterednewsdata), replace=TRUE, prob=c(0.80, 0.20))
filterednews.training <- filterednewsdata[filterednews_dataset==1, 1:27]
filterednews.test <- filterednewsdata[filterednews_dataset==2, 1:27]
filterednews.trainLabels <- filterednewsdata[filterednews_dataset==1, 27]
filterednews.testLabels <- filterednewsdata[filterednews_dataset==2, 27]

# Training Naive Bayes Model using filtered training data
nbmodel2<-naiveBayes(filterednews.trainLabels ~ ., data=filterednews.training)
nbmodel2

# From the training data results it can be seen than 49.24% of the articles are popular
# Predicting on test data
nbprediction2<-predict(nbmodel2,filterednews.test)
nbprob2<-predict(nbmodel2,filterednews.test,type="raw")

# Confusion matrix to check accuracy
confnb2<-table(nbprediction2,filterednews.testLabels)
confnb2
# We were able to classify 3912 out of 4062 "not popular" cases correctly
# We were able to classify 3859 out of 3870 "popular" cases correctly
# Hence the ability of Naive Bayes to predict the articles that are not popular is 96.3% and the ability to predict popular articles is 99.7%
# Hence the overall accuracy is 97.97%. This value is directly calculated using below method
(Accuracy <- sum(diag(confnb2))/sum(confnb2))
summary(confnb2)
#Hence it can be seen that the accuracy improved by after tuning the model

conf2<-confusionMatrix(nbprediction2,filterednews.testLabels)

# Precision of tuned model
nbprecision2<-conf2$byClass['Pos Pred Value'] 
nbprecision2

# Recall of tuned model
nbrecall2<-conf2$byClass['Sensitivity']
nbrecall2

# F score of tuned model
nb_fscore2<-2*((nbprecision2*nbrecall2)/(nbprecision2+nbrecall2))
nb_fscore2

# Naive Bayes Performance of Tuned Model 
# Accuracy - 97.97%  |   #F-Score - 0.979    |  Precision - 0.997 |  Recall - 0.96

# ROC Curve for Naive Bayes
nb.roc <- roc(filterednews.testLabels,nbprob2[,2])
plot(nb.roc,print.auc=TRUE,auc.polygon=TRUE,grid=c(0.1, 0.2),
     grid.col=c("green", "red"), max.auc.polygon=TRUE,
     auc.polygon.col="grey", print.thres=TRUE ,main="ROC for Naive Bayes")

######################################################################################################################
########################################### MODEL 4 - RANDOM FOREST ##################################################

library(randomForest)
set.seed(4)

# Spliting the Data into Train and test. Since the dataset is large the split is 80% for training and 20% for test. 
news_dataset <- sample(2, nrow(news), replace=TRUE, prob=c(0.80, 0.20))

# Training and Test datasets.
news.training <- news[news_dataset==1,]
news.test <- news[news_dataset==2,]

# Training and Test labels.
news.trainLabels <- news[news_dataset==1, 59]
news.testLabels <- news[news_dataset==2, 59]

# Building a Random Forest model with all predictor variables.
rf <- randomForest(shares~., data = news.training,importance= T)

# Looking at the model performance.
print(rf)

# Checking the attributes that can be accessed by the random forest model.
attributes(rf)

# Looking at the confusion matrix.
rf$confusion

# Find the important predictors in the model.
rf$importance

# Plotting the Top 10 Important predictors.
varImpPlot(rf, sort= T, n.var=10, main= 'Top 10 Important variables')

# Predictors most used in building the model.
varUsed(rf)

# Building a model object for predictions of the model.
library(caret)
pred1<-predict(rf, news.test)

# Confusion Matrix
acc<-confusionMatrix(pred1,news.testLabels)
conf_mat<-acc$table
conf_mat

# Storing the accuaracy
Random_forest_accuracy<-round(sum(diag(conf_mat))/sum(conf_mat),2)
print(paste0("Accuracy for Random Forest: ", Random_forest_accuracy))

# Precision
rf_precision<-round(conf_mat[1,1]/sum(conf_mat[,1]),2)
print(paste0("Precision for Random Forest: ", rf_precision))

# Recall
rf_recall<-round(conf_mat[1,1]/sum(conf_mat[1,]),2)
print(paste0("Recall for Random Forest: ", rf_recall))

# F-Score
rf_fscore<- round(2*(rf_precision*rf_recall)/(rf_precision+rf_recall),2)
rf_fscore

# Plotting the Error rate
plot(rf)

######################################################################################################################
########################################### MODEL 5 - LOGISTIC REGRESSION ############################################
set.seed(5)

# Spliting the Data into Train and test. Since the dataset is large the split is 80% for training and 20% for test. 
news_dataset <- sample(2, nrow(news), replace=TRUE, prob=c(0.80, 0.20))

# Training and Test datasets.
news.training <- news[news_dataset==1,]
news.test <- news[news_dataset==2,]

# Training and Test labels.
news.trainLabels <- news[news_dataset==1, 59]
news.testLabels <- news[news_dataset==2, 59]

# Building a logistic regression model with all predictors.
model1=glm( shares~.,data =news.training,family='binomial')

# Looking at the models performace
summary(model1)

## we get the important features for the data but lets improve the model further and reduce the non significant features.

# Build a predict model with type response to calcualte accuracy and misclassification rate.
t1= predict(model1,news.test,type = 'response')
head(t1)

# Histogram of Predict response to find approporiate cut off.
hist(t1)

# Creating a confusion matrix
test1<- ifelse(t1>0.5,1,0)
testtable=table(test1,news.testLabels)
testtable

# calculating the Misclassification Rate
misClassificationrate=1-sum(diag(testtable))/sum(testtable)
misClassificationrate

# Calcualting Accuracy of the model.
accuracyrate=round(sum(diag(testtable))/sum(testtable),2)
accuracyrate

#Storing the accuracy 
logistic_accuracy<-accuracyrate
logistic_accuracy

# precision
logistic_precision<- round(testtable[1,1]/sum(testtable[,1]),2)
print(paste0("Precision for Logistic regression is: ", logistic_precision))

# Recall
logistic_recall<- round(testtable[1,1]/sum(testtable[,1]),2)
print(paste0("Recall for Logistic Regression: ", logistic_recall))

# F-Score
logistic_fscore<- round(2*(logistic_precision*logistic_recall)/(logistic_precision+logistic_recall),2)
print(paste0("F-Score for Logistic Regression: ", logistic_fscore))

# Buliding an ROC curve
t1= predict(model1,news.test,type = 'response')
t1= prediction(t1, news.testLabels)
roc<-performance(t1,'tpr','fpr')

plot(roc,colorize=T,main='ROC Curve',ylab='Sensitivity',xlab='1-Specificity')
abline(a=0,b=1)

# Area under the curve
auc <- performance(t1,'auc')
auc <- unlist(slot(auc,'y.values'))
auc <- round(auc,3)
auc
legend(0.6,0.4,auc,title = 'AUC',cex = 0.8)

#######################################################################################################
####################################### MODEL 6 - SVM #################################################

#While performing the SVM model, we were running out of memory and R kept crashing hence we could not publish the result for the model or do any further analysis.

#library(e1071)
#install.packages('kernlab')
#library(kernlab) 
#svm <- ksvm(shares~. , data=news.training, kernel="vanilladot")


#pred <- predict(svm, news.test)
#pred1= ifelse(pred>0.5,1, 0)
#pred_cm<- table(pred1, news.testLabels)
#pred_cm


######################################################################################################################
########################################### MODEL 7 - LINEAR REGRESSION ##############################################

# Linear regression is used to predict the value of an outcome variable Y based on one or more input predictor variables X. 
# The aim is to establish a linear relationship between the predictor variable(s) and the response variable, so that, we can estimate the value of the response Y, when only the predictors (Xs) values are known.

# Read the file
setwd("C:/Users/Asmita Singh/Documents/GMU/OR 568/data")
newslinear <- read.csv("OnlineNewsPopularity.csv", stringsAsFactors = FALSE)
str(newslinear)

# Preprocessing the data for linear regression
newslinear = newslinear[!newslinear$n_unique_tokens==701,]
newslinear <- subset(newslinear, select = -c(url, timedelta))

# Dividing into train and test data
set.seed(6)
news_dataset <- sample(2, nrow(newslinear), replace=TRUE, prob=c(0.80, 0.20))

train.newslinear <- newslinear[news_dataset==1, 1:59]
test.newslinear <- newslinear[news_dataset==2, 1:59]

# Model 1 - Fitting a linear model with all the variables
fit_model1 <- lm(shares ~ ., data = train.newslinear)
summary(fit_model1)

# Model 1 - Predict the test data
pred_model1 = predict(fit_model1, test.newslinear)

# Model 1 - Calculating RMSE
# sqrt(mean((test.newslinear$shares - pred_model1)^2))
sqrt(mean(fit_model1$residuals^2))

# This model has a low R-square value, we can use a transformation on the model
newslinear$shares <- log(newslinear$shares)

# Dividing the data again into train and test data
newsTrain <- sample(nrow(newslinear),as.integer(nrow(newslinear)*0.80))
train.newslinear = newslinear[newsTrain,]
test.newslinear = newslinear[-newsTrain,]

# Model 2 - fitting a linear model on the transformed target variable
fit_model2 <- lm(shares ~ ., data = train.newslinear)
summary(fit_model2)

# Model 3 - Using stepwise regression step() to include only statistically significant variables in the model
fit_model3 <- step(fit_model2)
summary(fit_model3)

# Model 3 - Predict the test data
pred_model3 = predict(fit_model3, test.newslinear)
summary(pred_model3)

# Make predictions and compute the R2, RMSE and MAE
data.frame( R2 = R2(pred_model3, test.newslinear$shares),
            RMSE = RMSE(pred_model3, test.newslinear$shares),
            MAE = MAE(pred_model3, test.newslinear$shares))

# Linear Regression Performance
# Adjusted R2 - 0.1231597  |   #RMSE - 0.8736005    |  MAE - 0.6451786

# We thus get an optimized model with R-square value of approximately 0.1231 and 
# Root mean square error of approximately 0.87. This model includes only the statiscal variables.
# This model can only explain 12.31% variance in the data which is not good.

# Diagnostic plots
par(mfrow = c(2, 2))
plot(fit_model3)

# Linearity of the data
# The linearity assumption can be checked by inspecting the Residuals vs Fitted plot (1st plot):
plot(fit_model3, 1)
# There is a pattern in the residual plot. This suggests that we cannot assume linear relationship between the predictors and the outcome variables.

# Homogeneity of variance
# This assumption can be checked by examining the scale-location plot, also known as the spread-location plot.
plot(fit_model3, 3)
# The residuals are not spread equally along the ranges of predictors, violation of Homogeneity of variance

# Normality of residuals
# The QQ plot of residuals can be used to visually check the normality assumption. The normal probability plot of residuals should approximately follow a straight line.
# In our model, not all the points fall approximately along this reference line, so we cannot assume normality.
plot(fit_model3, 2)

# Cook's distance
plot(fit_model3, 4)
# Residuals vs Leverage
plot(fit_model3, 5)
# There is no outlier in the data.

# Repeated K-fold cross-validation
# The process of splitting the data into k-folds can be repeated a number of times, this is called repeated k-fold cross validation.
# The final model error is taken as the mean error from the number of repeats.
# The following uses 10-fold cross validation with 3 repeats:

# 10-fold cross validation with repeats
# Define training control
set.seed(6)
train.control <- trainControl(method = "repeatedcv", 
                              number = 10, repeats = 5)
# Train the model
model <- train(shares ~., data = newslinear, method = "lm",
               trControl = train.control)

# Summarize the results
print(model)

#Resampling results:
#   RMSE    |   Rsquared |   MAE      
# 0.8711685 | 0.1236544  | 0.6438536

# We find that after using 10-fold cross-validation, our model accounts for 12.36% of the variance (R-squared = 0.1236544) in the data.
# We can see that the R-squared for the whole sample was approximately equal to the Cross validation results (i.e., both accounted for 12% of the variance in the shares)
# Hence we can conclude that linear regression is not a good choice for this dataset as the Adjusted R2 is very low and it does not follow the model assumptions.

#------------------------------- CODE ENDS HERE ----------------------------------------------------------


############################### FINAL RESULTS ##############################################

accuracy.25 = 0
accuracy.cart= 0
Accuracy= 0
Random_forest_accuracy= 0
logistic_accuracy= 0

precision.knn =0
precision.cart =0
nbprecision2 =0 
rf_precision =0
logistic_precision =0

recall.knn =0
recall.cart =0
nbrecall2 =0
rf_recall =0
logistic_recall =0

fmeasure.knn =0 
fmeasure.cart =0
nb_fscore2 =0
rf_fscore =0
logistic_fscore =0

Models<- c("KNN","CART","NAIVE BAYES","RANDOM FOREST","LoGISTIC REGRESSION")

Accuracies<- c(accuracy.25,accuracy.cart,Accuracy,Random_forest_accuracy,logistic_accuracy)
Precisions<- c(precision.knn,precision.cart,nbprecision2,rf_precision,logistic_precision)
Recall<- c(recall.knn,recall.cart,nbrecall2,rf_recall,logistic_recall)
f_Measure<- c(fmeasure.knn,fmeasure.cart,nb_fscore2,rf_fscore,logistic_fscore)

Final_table<- data.frame(Models,Accuracies,Precisions, Recall, f_Measure)
Final_table











#---------------------------------------------------------------------------------------------#
# MODEL                   |    ACCURACY    |    F MEASURE    |    R SQUARED     |    RMSE
#---------------------------------------------------------------------------------------------#
# K NEAREST NEIGHBOUR(KNN)|      58.89%    |      0.61       |     ------       |     ------            
# --------------------------------------------------------------------------------------------#
# CART                    |      64.15%    |      0.62       |     ------       |     ------    
# --------------------------------------------------------------------------------------------#
# NAIVE BAYES             |      97.97%    |      0.979      |     ------       |     ------     
# --------------------------------------------------------------------------------------------#
# RANDOM FOREST           |      67%       |      0.67       |     ------       |     ------     
# --------------------------------------------------------------------------------------------#
# LOGISTIC REGRESSION     |      65%       |      0.68       |     ------       |     ------  
# --------------------------------------------------------------------------------------------#
# LINEAR REGRESSION       |     ------     |      ------     |      12.36%      |     0.87    
# --------------------------------------------------------------------------------------------#



#From the above results, it can be seen that Naive Bayes has the best accuracy and F measure, thus indicating that it is the best classifier to predict online news popularity.
#Hence the best model for classifying the dataset is Naive Bayes.