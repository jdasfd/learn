```bash
mkdir -p ~/data/AF_related/Atha
cd ~/data/AF_related/Atha
tar -xf UP000006548_3702_ARATH_v4.tar
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

cd ..

cat NLR.lst |
    parallel -j 12 -k '
        USalign Atha/AF-{}-F1-model_v4.pdb.gz -dir2 Atha/ Atha.pdb.lst -mol prot -outfmt 2
    '
```