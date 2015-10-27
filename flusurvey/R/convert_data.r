##' This reads in flusurvey data for a given year
##'
##' This reads different surveys and returns a list of data tables
##' containing the surveys. It does minimal cleaning and conversion
##' into R data formats. The csv files that should be provided can be
##' obtained via SQL dump,  e.g.
##' \\f ','
##' \\a
##' \\t
##' \\o intake_16.csv
##' SELECT * FROM pollster_results_intake;
##' \\o
##' \\q
##'
##' and similarly for weekly surveys
##'
##' @param files a (named!) list of files. The names stand for the surveys (e.g., "symptoms", "background", "contacts", etc.)
##' @param year the year from which the data come. If not given, will try to guess it from the headers in the .csv files
##' @param ... options to be passed to \code{read.csv}
##' @return a list of data tables with the data
##' @author seb
##' @import data.table
##' @export
read_data <- function(files, year, ...)
{
    res <- list()
    for (name in names(files))
    {
        dt <- data.table(read.csv(files[[name]], ...))

        ## remove empty variables
        fields <- copy(colnames(dt))
        for (col in fields)
        {
            if (all(is.na(dt[, get(col)])) || all(is.null(dt[, get(col)])))
            {
                dt[, paste(col) := NULL]
            }
        }

        if (missing(year))
        {
            ## try to guess
            i <- 1
            found <- FALSE
            while (i <= length(questions) && !found)
        {
            if (name %in% names(flusurvey::questions[[i]]) &&
                setequal(names(flusurvey::questions[[i]][[name]]),
                         setdiff(colnames(dt), c("id", "user", "global_id", "timestamp"))))
            {
                found <- TRUE
                year <- names(flusurvey::questions)[i]
            } else {
                i <- i + 1
            }
        }
            if (!found)
            {
                stop("Did not find the right questions for the data -- please provide 'year'")
            }
        } else {
            year <- as.character(year)
        }

        ## convert question name
        setnames(dt, names(flusurvey::questions[[year]][[name]]),
                 flusurvey::questions[[year]][[name]])

        ## convert dates
        dt[, date := as.Date(timestamp)]

        for (col in grep("\\.date$", colnames(dt), value = TRUE))
        {
            dt[get(col) == "", paste(col) := NA_character_]
            dt[, paste(col) := as.Date(get(col))]
        }

        ## convert options
        for (option in intersect(colnames(dt), names(flusurvey::options)))
        {
            dt[, paste(option) := factor(plyr::revalue(as.character(get(option)),
                                                       flusurvey::options[[option]],
                                                       warn_missing = FALSE))]
        }

        setkey(dt, global_id, date)

        res[[name]] <- dt
    }

    return(res)
}
