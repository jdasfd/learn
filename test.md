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
```
