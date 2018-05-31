#' A list of compdata suitable for use in gcamdata's old/new tests to see what impacts a users changes, if any, had on the data output products.
#'
#' This data is kept in a seperate package as it is a sizeable data product
#' and so we want users to only need to load it upon request.  It also allows
#' us to decoouple this history (in order to keep the Git repository at a
#' reasonable size) from the actual code development.
#' Users can update the compdata by copying in from the \code{gcamdata/output}
#' into \code{gcamdata.compdata/output}; then
#' \code{source("data-raw/update-compdata.R")}.
#' @note Ssers should avoid doing extended development on this pacakge as we may choose to do maintaince on the history at any time.
#' @format A list object where [[output_name]] <- output_data
"COMPDATA"
