```bash
./configure --prefix=/share/home/zhuqingshao/software/local/ CPPFLAGS="-I/share/home/zhuqingshao/software/local/include/"
```

```bash
cat Total_RLK.ECD.tsv | grep "^CL_" | tsv-filter --str-eq 2:None | wc -l
#1895

find ../DOMAIN -name "Pro.final.domain.tsv" | parallel -j 1 'cat {}' | tsv-join -f <(cat Total_RLK.ECD.tsv | tsv-filter --str-eq 2:None | grep "^CL_" | tsv-select -f 1) -k 1 | perl ../scripts/ECD_length.pl
```

