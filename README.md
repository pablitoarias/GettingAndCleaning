---
title: "README"
author: "Pablo Arias"
date: "Wednesday, November 12, 2014"
output: html_document
---

This is files describes how run_analysis.R works base on steps for the assingment

###Step 1: Merge the training and the test sets to create one data set.

First, the X (variables), y (activities) and subject.txt files for the train are read using read.table with default settings. The default is good enough because the parameters are spaced with white spaces and no header information is provided on the files
```
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
```
*Note: Initeritia data was not included based on suggestions on [David's Project FAQ](https://class.coursera.org/getdata-009/forum/thread?thread_id=58)*

After verifying that all data.frams had the same number of rows the data.frames are merged with the cbind() command
```
xy_train <- cbind(subject_train, y_train, x_train)
```
The same is done with the test set
```
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
xy_test <- cbind(subject_test, y_test, x_test)
```
Finally, because both xy_train and xy_test have the same amount of columns they ar emerged with rbind. We end up with a data.frame of dimensions: 10299x563
```
data <- rbind(xy_train, xy_test)
```

###Step 2: Extract only the measurements on the mean and standard deviation for each measurement. 

To accomplish this the features table is read with colClasses="character" (to prevent from it being imported as factors) and then it is parsed to find indices withing the vector that match the words Mean, mean or std. This is done with the grep command and a regular expresion. The second column of features (fature$V2) contains all the names of the variables
```
features <- read.table("UCI HAR Dataset/features.txt", colClasses="character")
mean_std_features_idx <- grep("([Mm]ean|.std)",features$V2)
```
Beacuse mean_std_features_idx only has 563 elements, (the reference number to all the features we care about) we need to add two references at the begging for Subject and Activity columns and need to add the value of two to shift the references. With that vector we can finally extract the data we are interested in
```
data <- data[,c(1,2, mean_std_features_idx + 2)]
```
We end up with only 86 of the features we cared about

###Step 3: Use descriptive activity names to name the activities in the data set
Considering the names in activity_labels.txt to be descriptive enough, the file is read and the data.frame is updated using the factors function on the activity column(data[[2]]) and the activities read used as the labels. This will replace the numbers with the factors labels on all the rows
```
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
data[[2]] <- factor(data[[2]], labels=activities$V2)
```
###Step 4: Appropriately label the data set with descriptive variable names.
I chose to extend the abreviated names used in the features file longer complete names. With the sub and gsub function replacements are done one by one. A vector is created with two names for the first two columns and the features extracted previously. The names are parsed and transformed
```
new_names <- c("Subject","Activity",features$V2[mean_std_features_idx])
new_names <- sub("^t","TimeDomain", new_names)
new_names <- sub("^f","FrequencyDomain", new_names)
new_names <- sub("Acc","Acceleration", new_names)
new_names <- sub("Mag","Magnitude", new_names)
new_names <- sub("-mean\\(\\)","Mean", new_names)
new_names <- sub("-std\\(\\)","StandardDeviation", new_names)
new_names <- sub("meanFreq\\(\\)","MeanFrequency", new_names)
new_names <- sub("\\-X","XAxis", new_names)
new_names <- sub("\\-Y","YAxis", new_names)
new_names <- sub("\\-Z","ZAxis", new_names)
#Angle Names fixing
new_names <- sub("\\(t","(TimeDomain", new_names)
new_names <- sub("gravity","Gravity", new_names)
new_names <- sub("Gravity\\)","GravityMean\\)", new_names) ## Appears to be a typo in features.txt
new_names <- sub("Mean\\)\\,","Mean\\,", new_names) ## Appears to be a typo in features.txt
new_names <- sub("angle","Angle", new_names)
new_names <- sub("X,","XAxis,", new_names)
new_names <- sub("Y,","YAxis,", new_names)
new_names <- sub("Z,","ZAxis,", new_names)
#Update names
names(data)<-new_names
```
###Step 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
Since this requires to generate means for each activity each subject, the first step is to factorize the subject field and then call the aggregate function on those two factors: subject and activity (previously factorized) with the FUNCTION mean
```
data$Subject <- factor(data$Subject)
data1 <- aggregate(data[,3:88], by=data[c("Subject","Activity")], FUN=mean)
```
This generates a data.frame with 180 rows (6 Activities x 30 Subjects) and 88 columns for all the means of all the variables we care about. 
To further clarify what this data means, the "SubjectActivityMean" prefix is added to columns 3 to 88, to end up with what I consider a Tidy dataset. Hope the reviewers agree :)  Finally the data is written as requiered with row.name=FALSE
```
names(data1)[3:88] <- paste0("SubjectActivity",names(data)[3:88])
write.table(data1,"Data_Step_5.txt",row.name=FALSE)
```
