#' @title Execute OHDSI Study phenotypeDataExtraction
#'
#' @details
#' This function executes OHDSI Study (FILL IN NAME).
#' This is a study of (GIVE SOME DETAILS).
#' Detailed information and protocol are available on the OHDSI Wiki.
#'
#' @return
#' Study results are in folder

#' @param cdm  Schema name where your patient-level data in OMOP CDM format resides
#' @param results   Schema where you'd like the results tables to be created (requires user to have create/write access)
#'
#'
#' @importFrom DBI dbDisconnect
#' @export
execute <- function(connectionDetails,
                    cdm,
                    results,
                    workFolder,
                    ncnt = 450,
                    mcnt = 450,
                    oracleTempSchema = results,
                    ...) {

    conn <- DatabaseConnector::connect(connectionDetails)
    if (is.null(conn)) {
        stop("Failed to connect to db server.")
    }

    # Record start time
    start <- Sys.time()

    # Place execution code here
    #execute one extract here



    writeLines("- Creating cohort")
    sql <- SqlRender::loadRenderTranslateSql("GenerateRandomTestPatientList.sql",
                                             "phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,
                                             oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,
                                             results = results,
                                             mcnt=mcnt,ncnt=ncnt
    )
    DatabaseConnector::executeSql(conn, sql)

    # Extract conditions
    writeLines("- Extracting Conditions")

    sql <- SqlRender::loadRenderTranslateSql("ExtractConditionsRandom.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    conditions_nr<-DatabaseConnector::querySql(conn, sql)
    write.csv(conditions_nr,file.path(workFolder,'Randomsample_cond.csv'),row.names = F)


    sql <- SqlRender::loadRenderTranslateSql("ExtractConditionsSeed.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    conditions_ms<-DatabaseConnector::querySql(conn, sql)
    write.csv(conditions_ms,file.path(workFolder,'Seedpatients_cond.csv'),row.names = F)

    # Extract demographics
    writeLines("- Extracting Demographics")

    sql <- SqlRender::loadRenderTranslateSql("ExtractDemographicsRandom.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    demographics_nr<-DatabaseConnector::querySql(conn, sql)
    write.csv(demographics_nr,file.path(workFolder,'Randomsample_demo.csv'),row.names = F)


    sql <- SqlRender::loadRenderTranslateSql("ExtractDemographicsSeed.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    demographics_ms<-DatabaseConnector::querySql(conn, sql)
    write.csv(demographics_ms,file.path(workFolder,'Seedpatients_demo.csv'),row.names = F)

    # Extract drugs
    writeLines("- Extracting Drugs")

    sql <- SqlRender::loadRenderTranslateSql("ExtractDrugsRandom.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    drugs_nr<-DatabaseConnector::querySql(conn, sql)
    write.csv(drugs_nr,file.path(workFolder,'Randomsample_drugs.csv'),row.names = F)


    sql <- SqlRender::loadRenderTranslateSql("ExtractDrugsSeed.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    drugs_ms<-DatabaseConnector::querySql(conn, sql)
    write.csv(drugs_ms,file.path(workFolder,'Seedpatients_drugs.csv'),row.names = F)

    # Extract labs
    writeLines("- Extracting Labs")

    sql <- SqlRender::loadRenderTranslateSql("ExtractLabsRandom.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    labs_nr<-DatabaseConnector::querySql(conn, sql)
    write.csv(labs_nr,file.path(workFolder,'Randomsample_labs.csv'),row.names = F)


    sql <- SqlRender::loadRenderTranslateSql("ExtractLabsSeed.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    labs_ms<-DatabaseConnector::querySql(conn, sql)
    write.csv(labs_ms,file.path(workFolder,'Seedpatients_labs.csv'),row.names = F)

    # Extract procedures
    writeLines("- Extracting Procedures")

    sql <- SqlRender::loadRenderTranslateSql("ExtractProceduresRandom.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    procedures_nr<-DatabaseConnector::querySql(conn, sql)
    write.csv(procedures_nr,file.path(workFolder,'Randomsample_proc.csv'),row.names = F)


    sql <- SqlRender::loadRenderTranslateSql("ExtractProceduresSeed.sql","phenotypeDataExtraction",
                                             dbms = connectionDetails$dbms,oracleTempSchema = oracleTempSchema,
                                             cdm = cdm,results = results
    )
    procedures_ms<-DatabaseConnector::querySql(conn, sql)
    write.csv(procedures_ms,file.path(workFolder,'Seedpatients_proc.csv'),row.names = F)





    result <- 1

    # Execution duration
    executionTime <- Sys.time() - start

    # # List of R objects to save
    objectsToSave <- c(
        "result",
        "executionTime"
    )

    # # Save results to disk
    # saveOhdsiStudy(list = objectsToSave, file = file)


    # Clean up
    DBI::dbDisconnect(conn)
    writeLines(paste('All done. Extracts can be found in ',workFolder))

    # Package and return result if return value is used
    result <- mget(objectsToSave)
    class(result) <- "OhdsiStudy"
    invisible(result)
}







