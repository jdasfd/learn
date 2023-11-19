# Assembly of bacterial genomes

## Preparation

- Install on linux

```bash
sudo apt install trim-galore
sudo apt install fastqc
sudo apt install spades
brew install brewsci/bio/trimmomatic
# adapter PATH:/home/linuxbrew/.linuxbrew/opt/trimmomatic/share/trimmomatic/adapters

# sudo apt-get install libbz2-dev
# SPAdes
wget http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5.tar.gz
tar -xzf SPAdes-3.15.5.tar.gz
cd SPAdes-3.15.5
PREFIX=/home/jyq/.spades ./spades_compile.sh
# path
echo "# SPAdes 3.15.5" >> ~/.bashrc
echo 'export PATH=$PATH:/home/jyq/.spades/bin' >> ~/.bashrc
echo >> ~/.bashrc
source ~/.bashrc
# check
spades.py -h

# Kmergenie
wget http://kmergenie.bx.psu.edu/kmergenie-1.7051.tar.gz
tar -xzf kmergenie-1.7051.tar.gz
mv kmergenie-1.7051 kmergenie
cd kmergenie
make
# path
echo "# kmergenie 1.7051" >> ~/.bashrc
echo 'export PATH=$PATH:~/share/kmergenie' >> ~/.bashrc
echo >> ~/.bashrc
source ~/.bashrc
# check
kmergenie -h
```

- Via Conda

```bash
conda install -c bioconda -n genome ragtag
conda install -c conda-forge -n genome ncbi-datasets-cli
conda install -c bioconda -n genome quast
quast-download-gridss
quast-download-silva
quast-download-busco
conda install prokka -n genome
conda install clinker-py -n genome
```

## Reference genome

```bash
mkdir -p ~/data/bac_assembly/REF
cd ~/data/bac_assembly/REF

# via ftp using wget
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/671/975/GCF_003671975.1_ASM367197v1/GCF_003671975.1_ASM367197v1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/021/283/055/GCF_021283055.2_ASM2128305v2/GCF_021283055.2_ASM2128305v2_genomic.fna.gz

# datasets download genome accession GCF_003671975.1 --include gff3,rna,cds,protein,genome --filename Pseudomonas_moteilii.zip

gzip -d *
mv GCF_003671975.1_ASM367197v1_genomic.fna Pmo_B5.fa
mv GCF_021283055.2_ASM2128305v2_genomic.fna Pmo_NMI135_16.fa
```

## Acquired raw seq files

```bash
mkdir -p ~/data/bac_assembly/raw
# put raw seq data into the dir
```

## Quality control

- Trimmomatic

```bash
mkdir -p ~/data/bac_assembly/QC
cd ~/data/bac_assembly

fastqc raw/*.fastq.gz -f fastq -o ./QC -q --thread 12

ADAPTER_PATH=/home/linuxbrew/.linuxbrew/opt/trimmomatic/share/trimmomatic/adapters/TruSeq3-PE-2.fa

trimmomatic PE -threads 12 raw/BADR214260NJ_1.fastq.gz raw/BADR214260NJ_2.fastq.gz \
    QC/bac_1.paired.fq.gz QC/bac_1.unpaired.fq.gz \
    QC/bac_2.paired.fq.gz QC/bac_2.unpaired.fq.gz \
    ILLUMINACLIP:${ADAPTER_PATH}:2:30:10:8:True \
    MINLEN:50
```

- K-mer selection

```bash
mkdir -p ~/data/bac_assembly/KMER
cd ~/data/bac_assembly/KMER

ls ../QC/*.paired.fq.gz |
    parallel -j 1 '
        echo "==> {/.}"
        kmergenie {} -l 60 -k 140 -t 12 -o {/.}
    '
```

## Genome assembly

```bash
mkdir -p ~/data/bac_assembly/ASSEMBLY
cd ~/data/bac_assembly

spades.py -o ./ASSEMBLY --isolate \
    -1 QC/bac_1.paired.fq.gz -2 QC/bac_2.paired.fq.gz \
    -t 20 -m 100 -k 121 --phred-offset 33
```

## Assembly according to genome

```bash
cd ~/data/bac_assembly
mkdir RAGTAG

ragtag.py correct REF/Pmo_B5.fa ASSEMBLY/scaffolds.fasta -o RAGTAG -t 12 -u
ragtag.py scaffold REF/Pmo_B5.fa RAGTAG/ragtag.correct.fasta -t 12 -o RAGTAG -u
ragtag.py patch ./RAGTAG/ragtag.scaffold.fasta ASSEMBLY/contigs.fasta -t 12 -o RAGTAG -u
# ragtag.py correct REF/Pmo_B5.fa ASSEMBLY/scaffolds.fasta -o RAGTAG/B5_result -t 12 -u
# ragtag.py correct REF/Pmo_NMI135_16.fa ASSEMBLY/scaffolds.fasta -o RAGTAG/NMI_result -t 12 -u
# ragtag.py scaffold REF/Pmo_B5.fa RAGTAG/B5_result/ragtag.correct.fasta -t 12 -o RAGTAG/B5_result
# ragtag.py scaffold REF/Pmo_NMI135_16.fa RAGTAG/NMI_result/ragtag.correct.fasta -t 12 -o RAGTAG/NMI_result

# ragtag.py scaffold REF/Pmo_B5.fa ASSEMBLY/scaffolds.fasta -t 12 -o RAGTAG/B5_result
# ragtag.py scaffold REF/Pmo_NMI135_16.fa ASSEMBLY/scaffolds.fasta -t 12 -o RAGTAG/NMI_result
# ragtag.py merge ASSEMBLY/scaffolds.fasta RAGTAG/*_result/*.agp -o RAGTAG/final
```

```bash
cd ~/data/bac_assembly
mkdir QUAST

quast.py -o ./QUAST/before -R ./REF/Pmo_B5.fa ./ASSEMBLY/scaffolds.fasta
quast.py -o ./QUAST/after -R ./REF/Pmo_B5.fa ./RAGTAG/ragtag.patch.fasta
```
