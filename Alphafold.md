# Alphafold related processes

## Alphafold info

## Prepare

- Ahphafold2

[Alphafold2](https://github.com/jdasfd/shell/blob/main/Management.md) version 2.3.2. The steps to download and install via non-docker (conda env) are recorded in the previous link page.

```bash
conda activate alphafold

python3 ~/share/alphafold-2.3.2/run_alphafold_test.py
# everything ready will be OK
python3 ~/share/alphafold-2.3.2/run_alphafold.py --helpshort
python3 ~/share/alphafold-2.3.2/run_alphafold.py --helpfull

cd ~/share/alphafold-2.3.2
scripts/download_all_data.sh ~/share/af_dataset/
```

```bash
AF_BASE="/home/j/share/af_dataset"
python3 ~/share/alphafold-2.3.1/run_alphafold.py \
    --fasta_paths=Multimer_test.fa \
    --max_template_date=2022-12-06 \
    --model_preset=multimer \
    --output_dir=~/data/AF_related/Multimer_test \
    --data_dir=$AF_BASE \
    --use_gpu_relax=true \
    --benchmark=true \
    --uniref90_database_path="$AF_BASE/uniref90/uniref90.fasta" \
    --mgnify_database_path="$AF_BASE/mgnify/mgy_clusters_2022_05.fa" \
    --template_mmcif_dir="$AF_BASE/pdb_mmcif/mmcif_files" \
    --obsolete_pdbs_path="$AF_BASE/pdb_mmcif/obsolete.dat" \
    --bfd_database_path="$AF_BASE/bfd" \
    --uniref30_database_path="$AF_BASE/uniref30/" \
    --pdb_seqres_database_path="$AF_BASE/pdb_seqres/pdb_seqres.txt" \
    --uniprot_database_path="$AF_BASE/uniprot/uniprot/"

bash run_alphafold.sh \
    -d /home/jyq/share/af_dataset \
    -o /home/jyq/data/AF_related/Multimer_test \
    -f /home/jyq/data/AF_related/Multimer_test.fa \
    -t 2022-10-05 \
    -m multimer
```

```bash
bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/136_result/ \
	-f /home/jyq/data/AF_related/136.fa \
	-t 2022-10-05 \
	-m monomer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Fxy_result/ \
	-f /home/jyq/data/AF_related/Fxy/136_multi.fa \
	-t 2022-10-05 \
	-m multimer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true
```

```bash
mkdir -p ~/data/AF_related/Atha
cd ~/data/AF_related/Atha
tar -xf UP000006548_3702_ARATH_v4.tar
```

```bash
python3 run_alphafold.py --helpshort
```

```bash
cd ~/data/AF_related/

perl ~/Scripts/fig_table/xlsx2csv.pl -f Atha_NLR_Ngou.xlsx |
    tsv-filter -H -d ',' --not-empty Entry |
    sed 1d |
    cut -d ',' -f 1 |
    tr "/" "\n" \
    > NLR.lst

cd Atha

ls | grep -v 'cif' > ../Atha.pdb.lst

ls Atha |
    parallel -j 24 '
        USalign Atha/AF-Q9FI14-F1-model_v4.pdb.gz Atha/{} -mol prot -outfmt 2
    ' \
    > Q9FI14.align.tsv

ls Atha |
    parallel -j 24 '
        USalign Q9FI14TAO1_ARATHLRR_model_3.pdb Atha/{} -mol prot -outfmt 2
    ' \
    > Q9FI14TAO1_ARATHLRR_model_3.align.tsv


USalign Atha/AF-Q9FI14-F1-model_v4.pdb.gz -dir2 Atha/ Atha.pdb.lst -mol prot -outfmt 2 > Q9FI14.align.tsv

cat Q9FI14.align.tsv | grep -v '^#' | wc -l
#54868
```

```bash
cd ~/data/AF_related/AvrL

mafft --auto <(cat Lus_L5.fa Lus_L6.fa) > Lus_L.aln
mafft --auto <(cat AvrL567_A.fa AvrL567_D.fa) > AvrL567.aln

# too little sequence difference
mafft --auto --clustalout <(cat AvrL567_A.fa AvrL567_D.fa) > AvrL567.clustl.aln
mafft --auto --clustalout <(cat Lus_L5.fa Lus_L6.fa) > Lus_L.clustl.aln

cat AvrL567_A.fa Lus_L5.fa > AL5.fa
cat AvrL567_D.fa Lus_L5.fa > DL5.fa
cat AvrL567_A.fa Lus_L6.fa > AL6.fa
cat AvrL567_D.fa Lus_L6.fa > DL6.fa

cd ~/share/alphafold-2.3.1

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Avr_result/ \
	-f /home/jyq/data/AF_related/AvrL/AvrL567_A.fa \
	-t 2022-10-05 \
	-m monomer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Avr_result/ \
	-f /home/jyq/data/AF_related/AvrL/AvrL567_D.fa \
	-t 2022-10-05 \
	-m monomer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Avr_result/ \
	-f /home/jyq/data/AF_related/AvrL/AL5.fa \
	-t 2022-10-05 \
	-m multimer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Avr_result/ \
	-f /home/jyq/data/AF_related/AvrL/DL5.fa \
	-t 2022-10-05 \
	-m multimer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Avr_result/ \
	-f /home/jyq/data/AF_related/AvrL/AL6.fa \
	-t 2022-10-05 \
	-m multimer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true

bash run_alphafold.sh \
	-d /home/jyq/share/af_dataset \
	-o /home/jyq/data/AF_related/Avr_result/ \
	-f /home/jyq/data/AF_related/AvrL/DL6.fa \
	-t 2022-10-05 \
	-m multimer \
	-n 10 \
	-c reduced_dbs \
	-l 2 \
	-b true
```
