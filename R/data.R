#' The number of bins used internally to store \code{COMPDATA}
#'
#' We need to store the COMPDATA internally in bins to avoid having to commit any single Rdata that is _too_ big.
#' The number of bins is calculated as the minimum required so the total size of the data while staying below the max
#' @format An integer
"NUM_BINS"
