library(devtools)
library(readr)

outputs_dir <- "./outputs"
comment_char <- "#"
COMPDATA <- list()
for(output_fn in list.files(outputs_dir, pattern="*.csv", full.names = TRUE)) {
  cat("Reading", output_fn, "\n")
  dataname <- sub('.csv$', '', basename(output_fn))
  data <- read_csv(output_fn, comment = comment_char)
  COMPDATA[[dataname]] <- data
}

use_data(COMPDATA, overwrite = TRUE, internal = FALSE, compress = "xz")
