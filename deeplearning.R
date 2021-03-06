# Install packages/ Set wd different from default
library(keras)
setwd("E:/Data_analysis/Ai_ctg")

# Read data
data <- read.csv("Cardiotocographic.csv", header = T)
str(data)

# Change to matrix
data <- as.matrix(data)
dimnames(data) <- NULL

# Normalize
data[, 1:21] <- normalize(data[, 1:21])
data[,22] <- as.numeric(data[,22]) -1
summary(data)

# Data partition
set.seed(1234)
ind <- sample(2, nrow(data), replace = T, prob = c(0.7, 0.3))
training <- data[ind==1, 1:21]
test <- data[ind==2, 1:21]
trainingtarget <- data[ind==1, 22]
testtarget <- data[ind==2, 22]

# One Hot Encoding
trainLabels <- to_categorical(trainingtarget)
testLabels <- to_categorical(testtarget)
print(testLabels)

# Create sequential model
model <- keras_model_sequential()
model %>%
         layer_dense(units=8, activation = 'relu', input_shape = c(21)) %>%
         layer_dense(units = 3, activation = 'softmax')
summary(model)

# Compile
model %>%
         compile(loss = 'categorical_crossentropy',
                 optimizer = 'adam',
                 metrics = 'accuracy')

# Fit model
history <- model %>%
         fit(training,
             trainLabels,
             epoch = 200,
             batch_size = 32,
             validation_split = 0.2)
plot(history)

# Evaluate model with test data
model %>%
         evaluate(test, testLabels)

# Prediction & confusion matrix - test data
prob <- model %>%
         predict_proba(test)

pred <- model %>%
        predict_classes(test)
table(Predicted = pred, Actual = testtarget)

cbind(prob, pred, testtarget)

# Fine-tune model

