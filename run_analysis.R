# One of the most exciting areas in all of data science right now is wearable computing - 
# see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to 
# develop the most advanced algorithms to attract new users. The data linked to from the 
# course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone.
# A full description is available at the site where the data was obtained:#
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
# Here are the data for the project:
#
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
# You should create one R script called run_analysis.R that does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.

# check for directory, else create
if(!file.exists("./data")){dir.create("./data")}
# allocating the URL
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# download file
if(!file.exits("./data/getdata_projectfiles_UCI HAR Dataset.zip"))
{
    download.file(fileUrl, destfile="./data/getdata_projectfiles_UCI HAR Dataset.zip")
    setwd("./data/")
    unzip("getdata_projectfiles_UCI HAR Dataset.zip")
    
}

# getting the features variables
features <- read.table("UCI HAR Dataset/features.txt")

# reading test data 
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

# reading training data 
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

# combining test and train data
merged_subject <- rbind(subject_test, subject_train)
merged_X <- rbind(X_test, X_train)
merged_Y <- rbind(Y_test, Y_train)

# storing variable names in a vector
x_column_names <- as.character(features$V2)
x_column_names <- make.names(x_column_names, unique=TRUE)


#setting column names of the merged datasets
names(merged_X) <- x_column_names
names(merged_subject) <- c('Subject')

merged_data <- merged_X
names(merged_data) <- x_column_names
merged_data <- cbind(merged_Y, merged_data)
merged_data <- cbind(merged_subject, merged_data)

# extract dataset for only the mean and standard deviation
sub_data <- select(merged_data, Subject, V1, contains(".mean."), contains(".std."))


# convert the subject and activities columns to factors
sub_data$Subject <- as.factor(sub_data$Subject)
sub_data$V1 <- as.factor(sub_data$V1)

# use descriptive activity names to name the activites in the data set
sub_data$V1 <- mapvalues(sub_data$V1, from = c("1", "2", "3", "4", "5", "6"), 
                         to = c("Walking", "WalkingUpStairs", "WalkingDownStairs", "Sitting", "Standing", "Lying"))


# Cleansing the names
names(sub_data) <- str_replace_all(names(sub_data), "[.][.]", "")
names(sub_data) <- str_replace_all(names(sub_data), "BodyBody", "Body")
names(sub_data) <- str_replace_all(names(sub_data), "tBody", "Body")
names(sub_data) <- str_replace_all(names(sub_data), "fBody", "FFTBody")
names(sub_data) <- str_replace_all(names(sub_data), "tGravity", "Gravity")
names(sub_data) <- str_replace_all(names(sub_data), "fGravity", "FFTGravity")
names(sub_data) <- str_replace_all(names(sub_data), "Acc", "Acceleration")
names(sub_data) <- str_replace_all(names(sub_data), "Gyro", "AngularVelocity")
names(sub_data) <- str_replace_all(names(sub_data), "Mag", "Magnitude")
for(i in 3:68) {if (str_detect(names(sub_data)[i], "[.]std")) 
{names(sub_data)[i] <- paste0("StandardDeviation", str_replace(names(sub_data)[i], "[.]std", ""))}}
for(i in 3:68) {if (str_detect(names(sub_data)[i], "[.]mean")) 
{names(sub_data)[i] <- paste0("Mean", str_replace(names(sub_data)[i], "[.]mean", ""))}}
names(sub_data) <- str_replace_all(names(sub_data), "[.]X", "XAxis")
names(sub_data) <- str_replace_all(names(sub_data), "[.]Y", "YAxis")
names(sub_data) <- str_replace_all(names(sub_data), "[.]Z", "ZAxis")


# creating a tidy data set
split_subdata <- split(select(sub_data, 3:68), list(sub_data$Subject, sub_data$V1))
# iterate over each item in the resulting list, and use apply to calculate the mean of each column
mean_subdata <- lapply(split_subdata, function(x) apply(x, 2, mean, na.rm=TRUE))
# The output from lapply is a list. Convert this back to a data frame.
tidy_subdata <- data.frame(t(sapply(mean_subdata,c)))
# The subject and activity factors are still combined, and are now row names instead of columns. Split them 
# using strsplit, then add them to a separate data frame that can be combined with the tidy data set using cbind.
factors <- data.frame(t(sapply(strsplit(rownames(tidy_subdata), "[.]"),c)))
tidy_subdata <- cbind(factors, tidy_subdata)
# Give the subject and activity columns friendly names, and convert them to factors.
tidy_subdata <- dplyr::rename(tidy_subdata,TestSubject = X1, Activity = X2)
tidy_subdata$TestSubject <- as.factor(tidy_subdata$TestSubject)
tidy_subdata$Activity <- as.factor(tidy_subdata$Activity)
rownames(tidy_subdata) <- NULL

write.table(tidy_subdata,file="tidy_dataset.txt", row.name = FALSE)

setwd("../")
