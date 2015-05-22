library(dplyr)
library(reshape2)

### Download file
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f<- "Dataset.zip"
download.file(url, destfile=file.path(getwd(), f), method="curl")
### Unzip file
unzip(file.path(getwd(), f))

path<-file.path(getwd(), "UCI HAR Dataset")
### Read.files
SubjTrain<-read.table(file.path(path, "train", "subject_train.txt"))
SubjTest<-read.table(file.path(path, "test", "subject_test.txt"))

ActivTrainY<-read.table(file.path(path, "train", "Y_train.txt"))
ActivTestY<-read.table(file.path(path, "test" , "Y_test.txt"))

ActivTrainX<-read.table(file.path(path, "train", "X_train.txt"))
ActivTestX<-read.table(file.path(path, "test" , "X_test.txt"))

###Merging by rows (test and treaining sets)

Subj<-rbind(SubjTrain, SubjTest)
colnames(Subj) <-c ("subject")

ActivY<-rbind(ActivTrainY, ActivTestY)
colnames(ActivY) <-c ("activityNum")

ActivX<-rbind(ActivTrainX, ActivTestX)

### Getting measurements names
ColNames_X<-read.table(file.path(path, "features.txt"))
Meas_name<-c(as.character(ColNames_X[,2]))
colnames(ActivX)<-Meas_name

### Extracting colums with mean and std

Data1<-ActivX[ ,grep("mean", names(ActivX), value=TRUE)]
Data2<-ActivX[ ,grep("std", names(ActivX), value=TRUE)]
Data<-data.frame(Data1, Data2, check.names=F)

### Naming activities
ActivNames<-read.table(file.path(path, "activity_labels.txt"))
colnames(ActivNames) <-c ("activityNum", "activityLabel")
ActivNames[,2]<-as.character(ActivNames[,2])

### Labeling activity in data set
Activity_set<-merge(ActivY, ActivNames, by="activityNum", sort=F)
Data_set<-data.frame(Subj, Activity_set, Data, check.names=F)

### Second data set with average  of each variable for each subject
long<-melt(Data_set, id.vars=c("subject","activityLabel", "activityNum"))
summary<-summarize(group_by(long, subject, activityLabel, variable), value=mean(value))
colnames(summary) <-c ("subject", "activityLabel", "measurement", "mean")

write.table(summary, file=file.path(path, "summary.txt"), row.names=F, quote=F, sep="\t")
