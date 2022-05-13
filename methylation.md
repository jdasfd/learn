# Methylation learning

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

AD=AD=ftp://ftp.ensembl.org/pub/release-106/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.chromosome.
for num in {1..19} MT X Y
do
echo "$AD$num.fa.gz" >> genome_info.ftp.txt
done

aria2c -j 2 -s 2 --file-allocation=none -c -i genome_info.ftp.txt
```

- Quality control and trimming

```bash
mkdir -p /mnt/e/methy/fastqc
cd /mnt/e/methy/fastqc
mkdir raw trimmed
mkdir -p /mnt/e/methy/trim
```

Quality of raw seq-data.

```bash
cd /mnt/e/methy/ena

parallel -j 3 " \
fastqc --threads 4 --quiet -o ../fastqc/raw {} \
" ::: $(ls *.fastq.gz)
```
