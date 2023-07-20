# Assembly of bacterial genomes

## Preparation

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

```bash
cd ~/share
sudo apt-get update && sudo apt-get install -y pkg-config libfreetype6-dev libpng-dev python3-matplotlib
wget https://github.com/ablab/quast/releases/download/quast_5.2.0/quast-5.2.0.tar.gz
tar -xzf quast-5.2.0.tar.gz
cd quast-5.2.0
```

Via Conda

```bash
conda install -c bioconda -n genome ragtag
```

## Acquired different genomes

```bash
mkdir -p ~/data/bac_assembly/raw
# push raw seq data into the dir
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
