## Step 1.

## Read x_train data
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
## dim(x_train) returns [1] 7352 561

## Read y_train data
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
## dim(y_train) returns [1] 7352 1

## Read subject_train data
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
## dim(subject_train) returns [1] 7352 1

## Column bind all train sets since same amount of rows
## It would be harder to do once the training and test sets are merged
xy_train <- cbind(subject_train, y_train, x_train)

## Read x_test data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
# dim(x_test) returns [1] 2947 561

## Read y_test data
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
# dim (y_test) returns [1] 2947 561

## Read subject_test data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
## dim(subject_train) returns [1] 2947 1

## Column bind all test sets since same amount of rows
## Subjects ids are unique since they were split amont test and train sets
xy_test <- cbind(subject_test, y_test, x_test)

## Row bind since same amount of colmuns
## Now there are 563 variables because subject and activity are merged
data <- rbind(xy_train, xy_test)
## dim(data) returns [1] 10299 563

## Step 2.

## Read Features and get indices for mean and standard deviation
## Using grep with regular expression on names of variables
## colClasses used to make sure the text does not load as factors
features <- read.table("UCI HAR Dataset/features.txt", colClasses="character")
mean_std_features_idx <- grep("([Mm]ean|.std)",features$V2)

## Add columns elements 1,2 to the vector for subject and activity
## and add 2 to the original vector to shift the values
data <- data[,c(1,2, mean_std_features_idx + 2)]

## Step 3
## Use activity_labels.txt as the descriptive activity names 
activities <- read.table("UCI HAR Dataset/activity_labels.txt")

## Convert Activity into factor and use the labels as the levels
## Replace column values
data[[2]] <- factor(data[[2]],labels=activities$V2)

## Step 4
## Assign names to variables
new_names <- c("Subject","Activity",features$V2[mean_std_features_idx])
## Use Regular expressions to make the varible names more descriptive
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

## Step 5
## Convert subject into factors to be able to us ethe split function
data$Subject <- factor(data$Subject)

## Aggregate by subject and activity into 180 rows (6 Activities * 30 subjects)
## Omit first two columns in function because we don;t want those means
data1<-aggregate(data[,3:88], by=data[c("Subject","Activity")], FUN=mean)

## Update names of variables to make them more descriptive
names(data1)[3:88] <- paste0("SubjectActivityMean",names(data)[3:88])

## Write file to disc
write.table(data1,"Data_Step_5.txt",row.name=FALSE)
