
# Wrapper around the actual get_all_compdata to ensure we only create one instance of
# COMPDATA regardless of how many times the function is called.  In addtion, doing it this
# way we do not have to worry about order of operations in terms of loading the package data.
make_get_all_compdata <- function() {
  COMPDATA <- NULL
  function(dot) {
    if(is.null(COMPDATA)) {
      # load the package data to get COMPDATAi for i in 1..NUM_BINS
      eval(parse(text=paste0("utils::data(",paste(paste0("'COMPDATA", seq(1, NUM_BINS)), collapse="',"), "')")))
      # combine each of those COMPDATAi into a single list
      COMPDATA <<- eval(parse(text=paste0("c(",paste(paste0("COMPDATA", seq(1, NUM_BINS)), collapse=","), ")")))
    }

    invisible(COMPDATA)
  }
}

#' A list of all compdata suitable for use in gcamdata's old/new tests.
#'
#' This is a list object where [[output_name]] <- compressed(output_data).  In most
#' cases users should use \code{get_comparison_data} so they do not need to worry about
#' these details.
#' @return The list of all COMPDATA
#' @export
get_all_compdata <- make_get_all_compdata()

#' Get the comparison data for the given data name
#'
#' This method will lookup the data from \code{COMPDATA} and uncompress if it
#' exists, or return \code{NULL} otherwise.
#' @param name The name of the comparison data to get
#' @return The comparison data if available, or \code{NULL} otherwise
#' @export
get_comparison_data <- function(name) {
  COMPDATA <- get_all_compdata()
  data_compress <- COMPDATA[[name]]
  if(is.null(data_compress)) {
    return(NULL)
  } else {
    conn <- rawConnection(memDecompress(data_compress, "xz"), "r")
    data <- readRDS(conn)
    close(conn)
    return(data)
  }
}
