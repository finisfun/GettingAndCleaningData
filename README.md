# GettingAndCleaningData
To store the assignment for Getting and Cleaning Data

The code run_analysis.R assumes checks for the presence of a "data" subdirectory in the working directory
It will create this directory if it does not exist already
Then it checks if the zip file exists within the data subdirectory. If it does not exist, it downloads and unzips the zip file within the data subdirectory
Then it sets the working directory to within the data directory
The file finally creates a tidy_dataset.txt and sets the working directory to one level up as we started with.

