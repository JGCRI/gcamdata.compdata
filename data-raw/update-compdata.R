library(devtools)
library(readr)
library(gcamdata.compdata)

# Note that if we *delete* a data output from gcamdata, it may 'hang around'
# in COMPDATA and won't be deleted automatically. We have a good reason for
# doing it this way, though.

COMPDATA <- get_all_compdata()   # load as an object that we'll modify and write back out below

outputs_dir <- "./outputs"
comment_char <- "#"
for(output_fn in list.files(outputs_dir, pattern = "*.csv", full.names = TRUE)) {
    dataname <- sub('.csv$', '', basename(output_fn))
    if (output_fn == "./outputs/L142.pfc_R_S_T_Yh.csv"){
      data <- read_csv(output_fn, comment = comment_char, col_types = c("dccccdcd"))
    } else {
      data <- read_csv(output_fn, comment = comment_char)
    }

    # we will store the individual data compressed in the list but not compress
    # the .rda file at the end so that when it gets loaded back into memory for
    # tests it will still be compressed and not be a massive memory hog that hangs
    # around
    # users will use gcamdata.compdata::get_comparison_data to retrieve the data
    # which will handle decompression
    conn <- rawConnection(raw(0), "w")
    saveRDS(data, file = conn)
    data_compress <- memCompress(rawConnectionValue(conn), "xz")
    close(conn)
    COMPDATA[[dataname]] <- data_compress
}

# The maximum bin size in bytes we want to allow, we need to restrict this as we will
# need to commit this data to git
MAX_BIN_SIZE <- 100 * 1024^2

# calculate the minimum number of bins required to stay under the max
total_size <- sum(sapply(COMPDATA, object.size))
NUM_BINS <- ceiling(total_size / MAX_BIN_SIZE)

# partition data into bins
compdata_bins <- list()
for(i in seq_len(NUM_BINS)) {
  compdata_bins[[i]] <- list()
  compdata_bins[[i]][["size"]] <- 0
  compdata_bins[[i]][["data"]] <- list()
}

# TODO: a more sophisticated approach to ensure bins are evenly balanced
curr_bin <- 1
for(n in names(COMPDATA)) {
  curr_size <- object.size(COMPDATA[[n]])
  if(compdata_bins[[curr_bin]][["size"]] + curr_size > (total_size / NUM_BINS) && curr_bin < NUM_BINS) {
    curr_bin <- curr_bin + 1
  }
  compdata_bins[[curr_bin]][["size"]] <- compdata_bins[[curr_bin]][["size"]] + curr_size
  compdata_bins[[curr_bin]][["data"]][[n]] <- COMPDATA[[n]]
}

# save the number of bins we ended up using as internal package data so it can be
# used when we load it back up to reassemble all of the bins of COMPDATA back togehter
use_data(NUM_BINS, overwrite = TRUE, internal = TRUE, compress = FALSE)

# save data, we will generate data names to be COMPDATA1..NUM_BINS
for(i in seq_len(NUM_BINS)) {
  if(compdata_bins[[i]][["size"]] > MAX_BIN_SIZE) {
    error("generated bin size greater than MAX_BIN_SIZE, possibly due to poor balancing")
  }
  dataname <- paste0("COMPDATA", i)
  assign(dataname, compdata_bins[[i]][["data"]])
  eval(parse(text=paste0("use_data(",dataname, ", overwrite = TRUE, internal = FALSE, compress = FALSE)")))
}
