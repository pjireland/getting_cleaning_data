##############################################
# Script for final assignment for Coursera   #
# "Getting and Cleaning Data" class          #
#                                            #
# Peter Ireland                              #  
# Due: January 31, 2016                      #
##############################################
#
# This script was run using 
# R version 3.2.3 Patched (2015-12-17 r69782)
# Platform: x86_64-apple-darwin10.8.0 (64-bit)
# Running under: OS X 10.10.5 (Yosemite).
# It uses two libraries: dplyr_0.4.3 and magrittr_1.5.
#
# The project assignment is given below.
#
# Here are the data for the project:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
# You should create one R script called run_analysis.R that does the following.
#
# (1) Merges the training and the test sets to create one data set.
# (2) Extracts only the measurements on the mean and standard deviation for 
#     each measurement.
# (3) Uses descriptive activity names to name the activities in the data set
# (4) Appropriately labels the data set with descriptive variable names.
# (5) From the data set in step 4, creates a second, independent tidy data set with the 
#     average of each variable for each activity and each subject.

#############################################################################
# (0) Download and unzip the data for the project, then read in the tables. #
#############################################################################

# (0.1) Download
destfile <- "./project_data.zip"
originfile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(originfile,destfile,method="curl")

# (0.2) Unzip
unzip(destfile)

# (0.3) Load the tables

# Training data
x_train       <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train       <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Testing data
x_test        <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test        <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test  <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# (0.4) Add column names

# Add column names from the file "features.txt"
column_names  <- read.table("./UCI HAR Dataset/features.txt")
colnames(x_train) <- column_names$V2
colnames(x_test) <- column_names$V2

# Add column names for the "y_*" and "subject_*" arrays
subject_col             <- "SubjectID"
activity_col            <- "ActivityName"
colnames(subject_train) <- subject_col
colnames(subject_test)  <- subject_col
colnames(y_train)       <- activity_col
colnames(y_test)        <- activity_col

####################################################################
# (1) Merge the training and the test sets to create one data set. #
####################################################################

# (1.1) Combine subject_train, y_train, x_train
combined_training <- cbind(subject_train,y_train,x_train)

# (1.2) Combine subject_test, y_test, x_test
combined_testing <- cbind(subject_test,y_test,x_test)

# (1.3) Combine combined_training and combined_testing
combined_testtrain <- rbind(combined_training,combined_testing)

############################################################################
# (2) Extract only the measurements on the mean and standard deviation for #
#     each measurement.                                                    #
############################################################################

# We'll assume that this means columns with the name "-mean()" and "-std()".
# We'll exclude columns which look like "angle(tBodyAccMean,gravity)",
# since this is an angle between a mean value and something else,
# and not just a mean value.
# We'll also exclude columns which contain "meanFreq()", under the assumption
# that we're only interested in measurements which have both a mean and a standard
# deviation.  Since there is no "*meanStd()", we'll assume frequency data is
# not of interest.

# (2.1) Determine which columns are should be kept
# Note that we'll also retain the first two columns, since they provide 
# descriptive information
relevant_columns <- grep("-mean\\(\\)|-std\\(\\)|SubjectID|ActivityName", colnames(combined_testtrain))

# (2.2) Subset the data, keeping only those columns
shortened_data <- subset(combined_testtrain,select=relevant_columns)

#############################################################################
# (3) Use descriptive activity names to name the activities in the data set #
#############################################################################

# The names of the activities are given in the "activity_labels.txt" file.
# We'll load that, and then replace the numeric values with the activity
# labels from this file.

# (3.1) Read the activity labels from the file
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
colnames(activity_labels)[1] <- "ID"
colnames(activity_labels)[2] <- "Label"

# (3.2) Replace the labels
# Match the IDs to the activity name
matched_ids <- match(shortened_data$ActivityName,activity_labels$ID)
# Update the ActivityName column with the new names
shortened_data$ActivityName <- activity_labels$Label[matched_ids]

#########################################################################
# (4) Appropriately label the data set with descriptive variable names. #
#########################################################################

# (4.1) Replace "t" and "f" at the start of a name with "time" and "frequency"
colnames(shortened_data) <- gsub("^t","time",colnames(shortened_data))
colnames(shortened_data) <- gsub("^f","frequency",colnames(shortened_data))

# (4.2) Replace "-mean()-" and "mean()" with "Mean" and replace -std()-" and "std()" with "Std"
colnames(shortened_data) <- gsub("\\-mean\\(\\)\\-?",'Mean',colnames(shortened_data))
colnames(shortened_data) <- gsub("\\-std\\(\\)\\-?",'StandardDeviation',colnames(shortened_data))

# (4.3) Replace "Acc" with "Acceleration", "Mag" with "Magnitude", and "Gyro" with "Gyroscopic"
colnames(shortened_data) <- gsub("Acc","Acceleration",colnames(shortened_data))
colnames(shortened_data) <- gsub("Mag","Magnitude",colnames(shortened_data))
colnames(shortened_data) <- gsub("Gyro","Gyroscopic",colnames(shortened_data))

########################################################################################
# (5) From the data set in step 4, create a second, independent tidy data set with the #
#     average of each variable for each activity and each subject.                     #
########################################################################################

# (5.1) Group by activity and subject ID
library(dplyr)
grouped_data <- group_by(shortened_data, ActivityName, SubjectID)

# (5.2) Average each variable
averaged_data <- summarise_each(grouped_data,funs(mean))

# (5.3) Now that we have averaged the variables, we should adjust the column names accordingly
#       Specificially, we add "Mean" to the end of all but the first two columns
library(magrittr)
colnames(averaged_data)[-1:-2] %<>% paste0("Mean")

# (5.4) Write to a file
write.table(averaged_data, file = "./human_activity_recognition.txt", row.names = FALSE)
