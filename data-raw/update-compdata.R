library(devtools)
library(readr)
library(gcamdata.compdata)

# Note that if we *delete* a data output from gcamdata, it may 'hang around'
# in COMPDATA and won't be deleted automatically. We have a good reason for
# doing it this way, though.

data("COMPDATA")   # load as an object that we'll modify and write back out below

outputs_dir <- "./outputs"
comment_char <- "#"
for(output_fn in list.files(outputs_dir, pattern = "*.csv", full.names = TRUE)) {
    dataname <- sub('.csv$', '', basename(output_fn))
    data <- read_csv(output_fn, comment = comment_char)
    COMPDATA[[dataname]] <- data
}

use_data(COMPDATA, overwrite = TRUE, internal = FALSE, compress = "xz")
