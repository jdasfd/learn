# Methylation Learning

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

## Quality control and trimming

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

## Methylation analysis

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
```
