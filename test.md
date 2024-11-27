# Test code

```bash
cd ~/gqh/Saccharomycotina/731-strain/GCF-731-SCORE/fasta-0.1

mkdir split_523

ls fasta-0.1/ |
    perl -pe 's/\.txt\.fasta$//' \
    > split_523/line.lst

# mkdir
cat split_523/line.lst |
    parallel -j 24 -k '
        mkdir split_523/{}
    '

# extract all seqs in tsv format
cat split_523/line.lst |
    parallel -j 24 -k '
        echo "==> {}"
        cat fasta-0.1/{}.txt.fasta |
            faops size stdin |
            cut -f 1 |
            tsv-join -f <(
                cat ../GCF731-name.tsv |
                tsv-select -f 2,1,3
            ) -k 1 -a 2 \
            > split_523/{}/{}.tmp.tsv
    '

for name in $(cat split_523/line.lst)
do
    echo "==> ${name}"
    cd split_523/${name}
    cat ${name}.tmp.tsv |
        parallel -j 12 -k --colsep '\t' '
            if [ -e {2}.tmp.lst ]; then
                echo {1} >> {2}.tmp.lst
            else
                echo {1} > {2}.tmp.lst
            fi
        '
    ls *.tmp.lst |
        perl -pe 's/\.tmp\.lst$//' |
        parallel -j 12 -k '
            faops some ~/test/gqh/Saccharomycotina/731-strain/GCF731-protein.faa \
                {}.tmp.lst {}.fa
        '
    rm *.tmp.lst
    cd ~/test/gqh/Saccharomycotina/731-strain/GCF-731-SCORE
done

cat split_523/line.lst |
    parallel -j 24 -k '
        rm split_523/{}/{}.tmp.tsv
    '

# filter
for file in $(cat split_523/line.lst)
do
    echo "==> ${file}"
    ls split_523/${file}/*.fa |
        parallel -j 12 -k '
            faops size {} |
            wc -l |
            awk -v SPE={/.} '\''{print (SPE"\t"$0)}'\''
        ' \
        > split_523/${file}/${file}.count.tsv
done

cd split_523
cat line.lst |
    parallel -j 12 -k '
        cat {}/{}.count.tsv |
            tsv-filter --ne 2:1 |
            wc -l |
            awk -v LINE={} '\''{print ($0"\t"LINE)}'\''
    ' \
    > line.ne1.tsv

cat line.ne1.tsv | tsv-filter --ne 1:0 | cut -f 2 > line_outgroup.lst

cat line_outgroup.lst | wc -l
#198

cat line_outgroup.lst |
    parallel -j 3 '
        orthofinder -f {} -t 4 -a 4 -X -o {}/result_{}
    '

bsub -q mpi -n 24 -J "ortho" -o . "cat line_outgroup.lst | parallel -j 4 'python3 ~/share/OrthoFinder/orthofinder.py -f {} -t 4 -a 4 -X -o {}/result_{}'"

#10441576
```

```bash
cd ~/data/test/gqh

cat ~/.nwr/assembly_summary_refseq.txt |
    grep -v "^##" |
    perl -pe 's/^#//' |
    tsv-select -H -f assembly_accession,species_taxid,organism_name |
    perl -nla -F'\t' -e '
        /^assembly/ ? print : $F[2] =~ s/\s/_/g && print "$F[0]\t$F[1]\t$F[2]"
    ' \
    > assembly_refseq.tsv

cat ~/.nwr/assembly_summary_genbank.txt |
    grep -v "^##" |
    perl -pe 's/^#//' |
    tsv-select -H -f assembly_accession,species_taxid,organism_name |
    perl -nla -F'\t' -e '
        /^assembly/ ? print : $F[2] =~ s/\s/_/g && print "$F[0]\t$F[1]\t$F[2]"
    ' \
    > assembly_genbank.tsv

perl ~/Scripts/fig_table/xlsx2csv.pl -f species-strain.xlsx -s 731 |
    cut -d',' -f 2 |
    perl -pe 's/(.+)_(\d+)$/$1\.$2/' \
    > accession.lst

cat accession.lst |
    tsv-join -f assembly_refseq.tsv -k 1 -a 2,3 \
    > accession.taxid.tsv

cat accession.lst |
    tsv-join -f assembly_genbank.tsv -k 1 -a 2,3 \
    >> accession.taxid.tsv

cat accession.taxid.tsv | wc -l
#725

cat accession.taxid.tsv |
    parallel -j 1 -k --colsep "\t" '
        nwr lineage {2} |
            tsv-select -f 1,2 |
            perl -nle '\''
                my @array = split/\t/, $_;
                my @tax_level = qw(kingdom phylum class order family genus species);
                if ( grep {$_ eq $array[0]} @tax_level ) {
                    print "$array[0]\t$array[1]";
                }
            '\'' |
            paste -sd "\t" |
            awk -v ACC={1} '\''{print ACC"\t"$0}'\''
    ' \
    > 731_species.taxo.tsv

cat 731_species.taxo.tsv | wc -l
```

```bash
cat genome.lst |
    parallel -j 1 -k '
        for group in TNL CNL RNL
        do
            echo "==> {} $group"
            cat 808/{}_${group}_seq.fa |
                perl -nle '\''print if /^>/'\'' |
                wc -l |
                awk -v GENOM={} -v GROUP=${group} '\''{print (GENOM","GROUP","$0)}'\'' \
                >> 155_NLR.csv
        done
    '
```

```bash
cat 38_brassica_name.txt |
    parallel -j 1 -k '
    for group in TNL CNL RNL
    do
        echo "==> {} $group"
        cat /home/efg/DataDisk/sangcw/1_pair_research/angiosperm/808/{}_${group}_seq.fa |
            perl -nle '\''print if /^>/'\'' |
            wc -l |
            awk -v GENOM={} -v GROUP=${group} '\''{print (GENOM","GROUP","$0)}'\'' \
            >> 38_brassica_NLR.csv
    done
    '
```

```bash
blastp -outfmt 6 -evalue 0.00001 -num_threads 8 -max_target_seqs 5
ParaAT.pl -m muscle -f axt
```

```bash
./configure --prefix=/share/home/zhuqingshao/software/local/ CPPFLAGS="-I/share/home/zhuqingshao/software/local/include/"
```

```bash
cat Total_RLK.ECD.tsv | grep "^CL_" | tsv-filter --str-eq 2:None | wc -l
#1895

find ../DOMAIN -name "Pro.final.domain.tsv" | parallel -j 1 'cat {}' | tsv-join -f <(cat Total_RLK.ECD.tsv | tsv-filter --str-eq 2:None | grep "^CL_" | tsv-select -f 1) -k 1 | perl ../scripts/ECD_length.pl
```

