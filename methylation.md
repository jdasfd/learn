# Methylation Learning

The protocol was orginated from my lab colleague [Jihong-Tang](https://github.com/Jihong-Tang/methylation-analysis/tree/master/NBT_repeat). I repeated it and learn the methylation analyze protocol.

- [Methylation Learning](#methylation-learning)
  - [Data Preparation](#data-preparation)
  - [Quality Control and Trimming](#quality-control-and-trimming)
  - [Methylation Analysis](#methylation-analysis)
    - [Genome indexing](#genome-indexing)
    - [Alignment](#alignment)
    - [Aligned reads deduplication](#aligned-reads-deduplication)
    - [Methylation information extracting](#methylation-information-extracting)
  - [Downstream Analysis](#downstream-analysis)
    - [Input data preparation](#input-data-preparation)
    - [DML/DMR detection](#dmldmr-detection)
  - [Reference](#reference)

## Data Preparation

- Software Preparation

```bash
brew install wang-q/tap/bismark
```

- Data Download

```bash
mkdir -p /mnt/e/methy/ena
cd /mnt/e/methy/ena

cat << EOF > file.csv
Run,Biotype
SRR7368841,WT
SRR7368842,WT
SRR7368845,TetKO
EOF

cat SraRunTable.txt | mlr --icsv --otsv cat | \
tsv-join -H --filter-file <(cat file.csv | mlr --icsv --otsv cat) \
--key-fields Run | \
tsv-select -H -f Experiment,"Sample\ Name",Bases \
> SraRunTable.tsv

cat SraRunTable.tsv | sed '1 s/^/#/' | \
keep-header -- tsv-sort -k2,2 -k3,3nr | \
tsv-uniq -H -f "Sample\ Name" --max 1 | mlr --itsv --ocsv cat > source.csv

anchr ena info | perl - -v source.csv > ena_info.yml
anchr ena prep | perl - ena_info.yml

aria2c -j 4 -x 4 -s 2 --file-allocation=none -c -i ena_info.ftp.txt
```

- Genome Download

```bash
mkdir -p /mnt/e/methy/genome
cd /mnt/e/methy/genome

AD=ftp://ftp.ensembl.org/pub/release-106/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.
for num in {1..19} MT X Y
do
echo "$AD$num.fa.gz" >> genome_info.ftp.txt
done

aria2c -j 2 -s 2 --file-allocation=none -c -i genome_info.ftp.txt
```

## Quality Control and Trimming

Using `fastqc` and `trim_galore` to do the quality control and adapter trimming.

```bash
mkdir /mnt/e/methy/fastqc
cd /mnt/e/methy/fastqc
mkdir raw trimmed
mkdir /mnt/e/methy/trim
```

- Quality control of raw seq-data

```bash
cd /mnt/e/methy/ena

parallel -j 3 " \
fastqc --threads 4 --quiet -o ../fastqc/raw {} \
" ::: $(ls *.fastq.gz)
```

- Trimming

```bash
cd /mnt/e/methy/ena

parallel -j 3 " \
trim_galore -j 4 \
--fastqc --output_dir ../trim {} \
--suppress_warn \
" ::: $(ls *.fastq.gz)

cd /mnt/e/methy/trim
mv *_fastqc.zip *.txt *.html ../fastqc/trimmed/
```

The adapter were all removed by `trim_galore`.

## Methylation Analysis

Using the `bismark` to do the methylation analysis of the BS-seq data.

**Bismark**:

```txt
genomic fragment:      ...ccgg(mc)atgtttaaa(mc)gct...
bisulfite-treated:        TTGG  C ATGTTTAAA  C GTT

BS-treated seq were followed:
C-to-T:                   TTGG  T ATGTTTAAA  T GTT (1)
G-to-A:                   TTAA  C ATATTTAAA  C ATT (2)

forward strand C-to-T: ...ttgg  t atgtttaaa  t gtt...
genome(1)              ...aacc  a tacaaattt  a caa...

forward strand G-to-A: ...ccaa  c atatttaaa  c act...
genome(2)              ...ggtt  g tataaattt  g tga...

(1) -> genome(1)
(1) -> genome(2)
(2) -> genome(1)
(2) -> genome(2)
```

Determine unique best alignment after 4 round mapping

### Genome indexing

Before alignments, the genome of interest needs bisulfiter converting according to `bismark` and indexed by `bowtie/bowtie2`. Here I repeated the processes with `bowtie2`.

```bash
cd /mnt/e/methy

bismark_genome_preparation --bowtie2 /mnt/e/methy/genome
```

### Alignment

The core of the methylation data analysis procedure is to align the sequencing reads to the reference genome which converted to bisulfite-type. It is assumed that all data were high-quality and were  adapter trimmed.

```bash
mkdir -p /mnt/e/methy/output/bismark_result
cd /mnt/e/methy/trim

genome_path="/mnt/e/methy/genome"

# read alignment
bismark -o ../output/bismark_result/ --parallel 4 --genome_folder ${genome_path} ./*.fq.gz
# --parallel: (May also be --multicore <int>), resource hungry, do jobs concurrently and merge at the end
# --bowtie2: default, bismark limits bowtie2 only perform end-to-end alignments
# -L: length of seed substrings, default -L 20
# -N: mismatches allowed in seed, default -N 0

# merge the two WT_mESC_rep1 result
cd /mnt/e/methy/output/bismark_result

samtools cat -o SRX4241790_trimmed_bismark_bt2.bam \
SRR7368841_trimmed_bismark_bt2.bam WT_bismark_bt2.bam

cat SRR7368841_trimmed_bismark_bt2_SE_report.txt \
SRR7368842_trimmed_bismark_bt2_SE_report.txt > WT_bismark_bt2_SE_report.txt

mv SRR7368845_trimmed_bismark_bt2.bam TetKO_bismark_bt2.bam
mv SRR7368845_trimmed_bismark_bt2_SE_report.txt TetKO_bismark_bt2_SE_report.txt

rm SRR7368841_trimmed_bismark_bt2.bam SRR7368842_trimmed_bismark_bt2.bam
rm SRR7368841_trimmed_bismark_bt2_SE_report.txt SRR7368842_trimmed_bismark_bt2_SE_report.txt
# samtools cat: concatenate BAMs
```

### Aligned reads deduplication

Mammalian genomes are unlikely to encounter several geniunely independent fragements which align to the very same genomic position. It is much more likely that such reads are originated from PCR amplification. For large genomes, removing duplicate reads is therefore a valid route to take.

**Attention**: Note that deduplication is not recommended for RRBS-type experiments!

The dedupliacation step could be finished from `bismark` tools, finishing through the `deduplicate_bismark` script.

In the default mode, the first alignment to a given position will be used irrespective of its methylation call (fastest and near enough random as the alignments not ordered in any way).

```bash
cd /mnt/e/methy/output
mkdir /mnt/e/methy/output/deduplicated_result

# aligned reads deduplication
deduplicate_bismark -s --bam --output_dir ./deduplicated_result/ ./bismark_result/*_bismark_bt2.bam
# -s/--single: deduplicate single-end Bismark files
# --bam: output will be written out in BAM instead of SAM.
```

### Methylation information extracting

The `bismark_methylation_extractor` script could extract all methylation info from alignment result files and act as the endpoint of the `bismark` package.

The script could extract ressults file produced by the Bismark bisulfite mapper (BAM/CRAM/SAM format) and extracts the methylation info for individual cytosines.

This information is found in the methylation call field which can contain the following characters:

> - X   for methylated C in CHG context
> - x   for not methylated C CHG
> - H   for methylated C in CHH context
> - h   for not methylated C in CHH context
> - Z   for methylated C in CpG context
> - z   for not methylated C in CpG context
> - U   for methylated C in Unknown context (CN or CHN)
> - u   for not methylated C in Unknown context (CN or CHN)
> - .   for any bases not involving cytosines

The output files are in the following format (tab delimited):

```txt
<sequence_id>   <strand>    <chromosome>    <position>  <methylation call>
```

- The following command is used to retrive methylated information from mapping results of previous `bismark.bam`

```bash
genome_path= "/mnt/e/methy/genome/"
cd /mnt/e/methy/output

# methylation information extracting
bismark_methylation_extractor -s --gzip --parallel 6 --bedGraph \
--cytosine_report --genome_folder ${genome_path} \
-o ./deduplicated_result/ ./deduplicated_result/*.bam
# -s/--single-end: single-end read data
# --bedGraph: the methylation output is written into a sorted bedGraph file that reports the position of a given cytosine and its methylation state
# --cytosine_report" after conversion to bedGraph, produces a genome-wide methylation report for all cytosine in the genome
```

- Output format info:

```txt
OUTPUT:

The bismark_methylation_extractor output is in the form:
--------------------------------------------------------
<seq-ID>  <methylation state*>  <chromosome>  <start position (= end position)>  <methylation call>
* Methylated cytosines receive a '+' orientation,
* Unmethylated cytosines receive a '-' orientation.


The bismark_methylation_extractor output with --yacht (optional) specified is in the form:
------------------------------------------------------------------------------------------
<seq-ID>  <methylation state*>  <chromosome>  <start position (= end position)>  <methylation call>  <read start>  <read end>  <read orientation>
* Methylated cytosines receive a '+' orientation,
* Unmethylated cytosines receive a '-' orientation.


The bedGraph output (optional) looks like this (tab-delimited; 0-based start coords, 1-based end coords):
---------------------------------------------------------------------------------------------------------
track type=bedGraph (header line)
<chromosome>  <start position>  <end position>  <methylation percentage>


The coverage output looks like this (tab-delimited, 1-based genomic coords; zero-based half-open coordinates available with '--zero_based'):
--------------------------------------------------------------------------------------------------------------------------------------------
<chromosome>  <start position>  <end position>  <methylation percentage>  <count methylated>  <count non-methylated>


The genome-wide cytosine methylation output file is tab-delimited in the following format:
------------------------------------------------------------------------------------------
<chromosome>  <position>  <strand>  <count methylated>  <count non-methylated>  <C-context>  <trinucleotide context>
```

## Downstream Analysis

Based on the methylation info got from previous [methylation analysis](#methylation-analysis) step, make more downstream analysis including finding specific locus and detecting differential methylation loci (DML) or differential methylation regions (DMR). R package `DSS` fit for purpose.

`DSS` was already included in my teacher's script [packages.R](https://github.com/wang-q/dotfiles/blob/master/r/packages.R). Please go and check them before you want to complete those steps.

### Input data preparation

`DSS` requires data from each BS-seq like experiment to be suummarized into following info for each CG position: chromosome number, genomic coordinate, total number of reads, and number of reads showing methylation.

The bismark result `.cov` files contain following cols: chr, start, end, methylation(%), count methylated, count unmethylated.

```bash
cd /mnt/e/methy/output/deduplicated_result

zcat TetKO_bismark_bt2.deduplicated.bismark.cov.gz | tsv-filter --gt 4:95 | head -n 3
#1       3068643 3068643 100     1       0
#1       3085348 3085348 100     1       0
#1       3111460 3111460 100     1       0
#chr    start   end methylation(%)  count_methylated    count_unmethlated
```

- Transfer input data to required format

```bash
mkdir /mnt/e/methy/output/results
cd /mnt/e/methy/output/deduplicated_result

for file in `ls *.bismark.cov.gz | perl -p -e 's/^(.*?)_.+$/$1/'`
do
zcat ${file}_bismark_bt2.deduplicated.bismark.cov.gz | \
sed '1ichr\tstart\tend\tmethyl%\tmethyled\tunmethyled' \
> ../results/${file}.cov.tsv
done
```

### DML/DMR detection

After the input data preparation, using `DSS` package to find DMLs or DMRs.

- Main fuction using in R

**Attention**: Following command were from the `DSS` Reference Manual. They were only examples about how to use it.

```R
library(DSS)

# make BSseq objects
BSobj <- makeBSseqData(list(data1.1, data1.2, data2.1, data2.2),
c("C1", "C2", "N1", "N2"))

# DML test
dmlTest <- DMLtest(BSobj, group1 = c("C1", "C2"), group2 = c("N1", "N2"))

# call DML
dmls <- callDML(dmlTest)

# call DML with a threshould
dmls2 <- callDML(dmlTest, delta = 0.1)

# take a small portion of data and test
BSobj <- BS.cancer.ex[140000:150000,]
dmlTest <- DMLtest(BSobj, group1 = c("C1", "C2", "C3"), group2 = c("N1", "N2", "N3"),
    smoothing = TRUE, smooting.span = 500)

# call DMR based on test results
dmrs <- callDMR(dmlTest)
```

- Rscript for DML/DMR detecting

Rscript for DSS analysis put into script doc

```bash
mkdir /mnt/e/methy/script
cd /mnt/e/methy/output/results

Rscript ../../script/DSS_differ_analysis.R --help
Rscript ../../script/DSS_differ_analysis.R --file1 WT.cov.tsv --file2 TetKO.cov.tsv -p mouse_chrall
```

## Reference

- [NBT_repeat](https://github.com/Jihong-Tang/methylation-analysis/tree/master/NBT_repeat)
- [DSS package Manual](http://bioconductor.org/packages/release/bioc/html/DSS.html)
- [Bismark Docs](https://github.com/FelixKrueger/Bismark/tree/master/Docs)
