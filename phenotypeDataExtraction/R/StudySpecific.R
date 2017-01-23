#' @title Execute OHDSI Study phenotypeDataExtraction
#'
#' @details
#' This function executes OHDSI Study (FILL IN NAME).
#' This is a study of (GIVE SOME DETAILS).
#' Detailed information and protocol are available on the OHDSI Wiki.
#'
#' @return
#' Study results are placed in CSV format files in specified local folder and returned
#' as an R object class \code{OhdsiStudy} when sufficiently small.  The properties of an
#' \code{OhdsiStudy} may differ from study to study.

#' @param dbms              The type of DBMS running on the server. Valid values are
#' \itemize{
#'   \item{"mysql" for MySQL}
#'   \item{"oracle" for Oracle}
#'   \item{"postgresql" for PostgreSQL}
#'   \item{"redshift" for Amazon Redshift}
#'   \item{"sql server" for Microsoft SQL Server}
#'   \item{"pdw" for Microsoft Parallel Data Warehouse (PDW)}
#'   \item{"netezza" for IBM Netezza}
#' }
#' @param user				The user name used to access the server. If the user is not specified for SQL Server,
#' 									  Windows Integrated Security will be used, which requires the SQL Server JDBC drivers
#' 									  to be installed.
#' @param domain	    (optional) The Windows domain for SQL Server only.
#' @param password		The password for that user
#' @param server			The name of the server
#' @param port				(optional) The port on the server to connect to
#' @param cdmSchema  Schema name where your patient-level data in OMOP CDM format resides
#' @param resultsSchema  (Optional) Schema where you'd like the results tables to be created (requires user to have create/write access)
#' @param file	(Optional) Name of local file to place results; makre sure to use forward slashes (/)
#' @param ...   (FILL IN) Additional properties for this specific study.
#'
#' @examples \dontrun{
#' # Run study
#' execute(dbms = "postgresql",
#'         user = "joebruin",
#'         password = "supersecret",
#'         server = "myserver",
#'         cdmSchema = "cdm_schema",
#'         resultsSchema = "results_schema")
#'
#' # Email result file
#' email(from = "collaborator@@ohdsi.org",
#'       dataDescription = "CDM4 Simulated Data")
#' }
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

