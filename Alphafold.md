# Alphafold related processes

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
