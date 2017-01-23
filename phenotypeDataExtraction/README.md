#PhenotypeDataExtraction

This is part of a study. It allows generation of data extracts from CDM shaped data.
Such extracts are later analyzed on a second step.





##Step 1.
Install the package.  The --no-multiarch eliminates errors on some Windows computers (it is not always necessar). 

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/StudyProtocolSandbox/phenotypeDataExtraction",args="--no-multiarch")
library(phenotypeDataExtraction)

```

##Step 3. 
Execute the following code:

```R
#use your previous connectionDetails object with username and psw for database
#or get it from an external file 
source('c:/r/conn.R')  #this file should create an object called connectionDetails

workFolder <- 'c:/temp/phenoDE'  #create a folder where data will be exported
dir.create(workFolder) 


 connectionDetails<-connDlee4
cdm<-'cdm.dbo'
results<-'cdm.dbo'


execute(connectionDetails = connectionDetails,cdm = cdm,results = results,workFolder = workFolder)

```
