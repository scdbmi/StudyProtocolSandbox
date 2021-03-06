# @file SelfControlledCohort.R
#
# Copyright 2016 Observational Health Data Sciences and Informatics
#
# This file is part of PopEstMethodEvaluation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' @export
runSelfControlledCohort <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    oracleTempSchema = NULL,
                                    outcomeDatabaseSchema = cdmDatabaseSchema,
                                    outcomeTable = "cohort",
                                    workFolder,
                                    cdmVersion = "5") {
    start <- Sys.time()
    injectionSummaryFile <- file.path(workFolder, "injectionSummary.rds")
    if (!file.exists(injectionSummaryFile))
        stop("Cannot find injection summary file. Please run injectSignals first.")
    injectedSignals <- readRDS(injectionSummaryFile)

    sccFolder <- file.path(workFolder, "selfControlledCohort")
    if (!file.exists(sccFolder))
        dir.create(sccFolder)

    sccSummaryFile <- file.path(workFolder, "sccSummary.rds")
    if (!file.exists(sccSummaryFile)) {
        eoList <- list()
        for (i in 1:nrow(injectedSignals)) {
            if (injectedSignals$trueEffectSize[i] != 0) {
                eoList[[length(eoList)+1]] <- SelfControlledCohort::createExposureOutcome(exposureId = injectedSignals$exposureId[i],
                                                                                        outcomeId = injectedSignals$newOutcomeId[i])
            }
        }
        sccAnalysisListFile <- system.file("settings", "sccAnalysisSettings.txt", package = "PopEstMethodEvaluation")
        sccAnalysisList <- SelfControlledCohort::loadSccAnalysisList(sccAnalysisListFile)
        sccResult <- SelfControlledCohort::runSccAnalyses(connectionDetails = connectionDetails,
                                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                                          oracleTempSchema = oracleTempSchema,
                                                          exposureTable = "drug_era",
                                                          outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                          outcomeTable = outcomeTable,
                                                          sccAnalysisList = sccAnalysisList,
                                                          exposureOutcomeList = eoList,
                                                          cdmVersion = cdmVersion,
                                                          outputFolder = sccFolder,
                                                          analysisThreads = 10)
        sccSummary <- SelfControlledCohort::summarizeAnalyses(sccResult)
        saveRDS(sccSummary, sccSummaryFile)
    }
    delta <- Sys.time() - start
    writeLines(paste("Completed SelfControlledCohort analyses in", signif(delta, 3), attr(delta, "units")))
}

#' @export
createSelfControlledCohortSettings <- function(fileName) {

    runSccArgs1 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = TRUE,
                                                                           timeAtRiskExposedStart = 0,
                                                                           surveillanceExposed = 0,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = TRUE,
                                                                           surveillanceUnexposed = 0,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis1 <- SelfControlledCohort::createSccAnalysis(analysisId = 1,
                                                            description = "Length of exposure, index date in exposure window",
                                                            runSelfControlledCohortArgs = runSccArgs1)

    runSccArgs2 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = FALSE,
                                                                           timeAtRiskExposedStart = 0,
                                                                           surveillanceExposed = 30,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = FALSE,
                                                                           surveillanceUnexposed = -30,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis2 <- SelfControlledCohort::createSccAnalysis(analysisId = 2,
                                                            description = "30 days of each exposure, index date in exposure window",
                                                            runSelfControlledCohortArgs = runSccArgs2)

    runSccArgs3 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = TRUE,
                                                                           timeAtRiskExposedStart = 0,
                                                                           surveillanceExposed = 0,
                                                                           hasFullTimeAtRisk = TRUE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = TRUE,
                                                                           surveillanceUnexposed = 0,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis3 <- SelfControlledCohort::createSccAnalysis(analysisId = 3,
                                                            description = "Length of exposure, index date in exposure window, require full obs",
                                                            runSelfControlledCohortArgs = runSccArgs3)


    runSccArgs4 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = FALSE,
                                                                           timeAtRiskExposedStart = 0,
                                                                           surveillanceExposed = 30,
                                                                           hasFullTimeAtRisk = TRUE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = FALSE,
                                                                           surveillanceUnexposed = -30,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis4 <- SelfControlledCohort::createSccAnalysis(analysisId = 4,
                                                            description = "30 days of each exposure, index date in exposure window, require full obs",
                                                            runSelfControlledCohortArgs = runSccArgs4)

    runSccArgs5 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = TRUE,
                                                                           timeAtRiskExposedStart = 1,
                                                                           surveillanceExposed = 0,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = TRUE,
                                                                           surveillanceUnexposed = 0,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis5 <- SelfControlledCohort::createSccAnalysis(analysisId = 5,
                                                            description = "Length of exposure, index date ignored",
                                                            runSelfControlledCohortArgs = runSccArgs5)

    runSccArgs6 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = FALSE,
                                                                           timeAtRiskExposedStart = 1,
                                                                           surveillanceExposed = 30,
                                                                           hasFullTimeAtRisk = FALSE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = FALSE,
                                                                           surveillanceUnexposed = -30,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis6 <- SelfControlledCohort::createSccAnalysis(analysisId = 6,
                                                            description = "30 days of each exposure, index date ignored",
                                                            runSelfControlledCohortArgs = runSccArgs6)

    runSccArgs7 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = TRUE,
                                                                           timeAtRiskExposedStart = 1,
                                                                           surveillanceExposed = 0,
                                                                           hasFullTimeAtRisk = TRUE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = TRUE,
                                                                           surveillanceUnexposed = 0,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis7 <- SelfControlledCohort::createSccAnalysis(analysisId = 7,
                                                            description = "Length of exposure, index date ignored, require full obs",
                                                            runSelfControlledCohortArgs = runSccArgs7)


    runSccArgs8 <- SelfControlledCohort::createRunSelfControlledCohortArgs(firstOccurrenceDrugOnly = FALSE,
                                                                           firstOccurrenceConditionOnly = FALSE,
                                                                           useLengthOfExposureExposed = FALSE,
                                                                           timeAtRiskExposedStart = 1,
                                                                           surveillanceExposed = 30,
                                                                           hasFullTimeAtRisk = TRUE,
                                                                           timeAtRiskUnexposedStart = -1,
                                                                           useLengthOfExposureUnexposed = FALSE,
                                                                           surveillanceUnexposed = -30,
                                                                           washoutWindow = 183,
                                                                           followupWindow = 183)

    sccAnalysis8 <- SelfControlledCohort::createSccAnalysis(analysisId = 8,
                                                            description = "30 days of each exposure, index date ignored, require full obs",
                                                            runSelfControlledCohortArgs = runSccArgs8)

    sccAnalysisList <- list(sccAnalysis1, sccAnalysis2, sccAnalysis3, sccAnalysis4, sccAnalysis5, sccAnalysis6, sccAnalysis7, sccAnalysis8)
    if (!missing(fileName) && !is.null(fileName)){
        SelfControlledCohort::saveSccAnalysisList(sccAnalysisList, fileName)
    }
    invisible(sccAnalysisList)
}
