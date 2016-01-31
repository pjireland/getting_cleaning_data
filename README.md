# Getting and Cleaning Data Course Project
## Peter J. Ireland
### Submission for the final project for the Getting and Cleaning Data class offered through Coursera.

The script <code>run_analysis.R</code> is used for the analysis.  It performs the following steps:

<ol start="0">
  <li>Downloads and unzips the files.</li>
  <li>Merges the training and the test sets to create one data set.</li>
  <li>Extracts only the measurements on the mean and standard deviation for each measurement.</li>
  <li>Uses descriptive activity names to name the activities in the data set.</li>
  <li>Appropriately labels the data set with descriptive variable names.</li>
  <li>From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.</li>
</ol>

The tidy data set generated in Step 5 above is included in this repository as 
<code>human_activity_recognition.txt</code>. The codebook is provided as
<code>codebook.pdf</code>.

The script was run using<br/>
<code>R version 3.2.3 Patched (2015-12-17 r69782)</code><br/>
<code>Platform: x86_64-apple-darwin10.8.0 (64-bit)</code><br/>
<code>Running under: OS X 10.10.5 (Yosemite)</code>.<br/>
It uses two libraries: <code>dplyr_0.4.3</code> and <code>magrittr_1.5</code>.





