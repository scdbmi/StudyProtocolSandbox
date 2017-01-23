#PhenotypeDataExtraction

This R package generates data extracts necessary for a Phenotype Study (by a team at Columbia U).
Such extracts are later analyzed on a second step (not part of this package).



##Step 1.
Install the package.  The --no-multiarch eliminates errors on some Windows computers (it is not always necessar). 

```R
install.packages("devtools")
library(devtools)
install_github("ohdsi/StudyProtocolSandbox/phenotypeDataExtraction",args="--no-multiarch")
library(phenotypeDataExtraction)

```

##Step 2. 
Execute the following code:

```R
#use your previous connectionDetails object with username and psw for database
#or get it from an external file 
source('c:/r/conn.R')  #this file should create an object called connectionDetails

#create a work folder
workFolder <- 'c:/temp/phenoDE'  #create a folder where data will be exported
dir.create(workFolder) 


#provide names of your CDM and results schemas (see http://www.ohdsi.org/web/wiki/doku.php?id=development:data_architecture ) 
cdm<-'cdm.dbo'
results<-'cdm.dbo'


execute(connectionDetails = connectionDetails,cdm = cdm,results = results,workFolder = workFolder)

```
