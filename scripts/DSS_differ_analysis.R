library(tidyr)
suppressMessages(library(dplyr))
library(readr)
suppressMessages(library(DSS))
library("optparse")

option_list = list(
    make_option(c("-1","--file1"), type = "character", default = NULL,
    help = "one file prepared for the DSS input", metavar = "character"),
    make_option(c("-2","--file2"), type = "character", default = NULL,
    help = "another file from group combined with file 1", metavar = "character"),
    make_option(c("-p","--prefix"), type = "character", default = NULL,
    help = "file name of output", metavar = "character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# import data
data1 <- read_tsv(opt$file1, show_col_type = FALSE)
data2 <- read_tsv(opt$file2, show_col_type = FALSE)
prefix <- opt$prefix
outtest <- paste0(prefix, "_test.tsv")
outdmls <- paste0(prefix, "_dmls.tsv")
outdmrs <- paste0(prefix, "_dmrs.tsv")

# data manipulation to prepare for the BSseq objection
print("Importing data file, this may take a while...")
DSS_in1 <- data1 %>%
    mutate(chr = paste("chr", chr, seq = "")) %>%
    mutate(pos = start, N = methyled + unmethyled, X = methyled) %>%
    select(chr, pos, N, X)
DSS_in2 <- data2 %>%
    mutate(chr = paste("chr", chr, seq = "")) %>%
    mutate(pos = start, N = methyled + unmethyled, X = methyled) %>%
    select(chr, pos, N, X)

# create BSseq object and make the statistical test
bsobj <- makeBSseqData(list(DSS_in1, DSS_in2), c("WT", "TetKO"))
dmlTest <- DMLtest(bsobj, group1 = c("WT"), group2 = c("TetKO"), smoothing = T)
print("Basic statistical test completed.")

# dmls detection
dmls <- callDML(dmlTest, p.threshold = 0.001)
# dmrs detection
dmrs <- callDMR(dmlTest, p.threshold= 0.01)
print("DML and DMR extraction completed.")

# output the results
write.table(dmlTest, outtest, raw.names = FALSE, col.names = FALSE, sep = "\t")
write.table(dmls, outdmls, raw.names = FALSE, col.names = FALSE, sep = "\t")
write.table(dmrs, outdmrs, raw.names = FALSE, col.names = FALSE, sep = "\t")
