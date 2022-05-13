# Faops manuscript

```bash
faops is a lightweight tool for operating sequences in the fasta format.
```

```bash
faops help

Usage:     faops <command> [options] <arguments>
Version:   0.8.17

Commands:
    help           print this message
    count          count base statistics in FA file(s)
    size           count total bases in FA file(s)
    frag           extract sub-sequences from a FA file
    rc             reverse complement a FA file
    some           extract some fa records
    order          extract some fa records by the given order
    replace        replace headers from a FA file
    filter         filter fa records
    split-name     splitting by sequence names
    split-about    splitting to chunks about specified size
    n50            compute N50 and other statistics
    dazz           rename records for dazz_db
    interleave     interleave two PE files
    region         extract regions from a FA file

Options:
    There're no global options.
    Type "faops command-name" for detailed options of each command.
    Options *MUST* be placed just after command.

```

## Examples

test file downloaded from <https://github.com/wang-q/faops>

for every > is separated

* Count base statistics in FA file(s)

  ```bash
  usage:
      faops count <in.fa> [more_files.fa]
      
  faops count ufasta.fa
  
  #seq    len     A       C       G       T       N
  read0   359     99      89      92      79      0
  read1   106     24      25      32      25      0
  read2   217     57      58      49      53      0
  read3   73      10      21      19      23      0
  read4   76      12      22      22      20      0
  read5   215     43      51      67      54      0
  read6   132     32      37      32      31      0
  read7   240     63      60      50      67      0
  read8   227     66      53      53      55      0
  read9   0       0       0       0       0       0
  read10  141     30      38      43      30      0
  read11  144     37      40      36      31      0
  read12  428     100     121     112     95      0
  read13  516     137     117     139     123     0
  read14  443     121     108     109     105     0
  read15  106     24      28      27      27      0
  read16  172     42      39      42      49      0
  read17  253     56      70      68      59      0
  read18  469     125     116     122     106     0
  read19  122     39      22      23      38      0
  read20  28      7       5       6       10      0
  read21  296     65      71      73      87      0
  read22  164     34      41      50      39      0
  read23  0       0       0       0       0       0
  read24  68      19      10      20      19      0
  read25  297     72      87      64      74      0
  read26  105     25      29      29      22      0
  read27  112     28      28      30      26      0
  read28  589     126     145     161     157     0
  read29  421     118     107     93      103     0
  read30  36      9       7       13      7       0
  read31  48      14      6       17      11      0
  read32  81      23      18      17      23      0
  read33  0       0       0       0       0       0
  read34  231     56      59      64      52      0
  read35  165     45      41      44      35      0
  read36  6       1       3       1       1       0
  read37  139     41      38      35      25      0
  read38  237     63      56      54      64      0
  read39  314     77      71      88      78      0
  read40  376     101     97      81      97      0
  read41  458     104     99      120     135     0
  read42  40      9       11      11      9       0
  read43  45      10      12      10      13      0
  read44  133     37      25      36      35      0
  read45  0       0       0       0       0       0
  read46  15      2       6       3       4       0
  read47  116     21      27      35      33      0
  read48  0       0       0       0       0       0
  read49  358     94      91      81      92      0
  total   9317    2318    2305    2373    2321    0
  ```

* Count total bases in FA file(s)

  ```bash
  usage:
      faops size <in.fa> [more_files.fa]
  
  faops size 000.fa
  
  read0   359
  read1   106
  read2   217
  read3   73
  read4   76
  read5   215
  read6   132
  read7   240
  read8   227
  read9   0
  read10  141
  read11  144
  read12  428
  read13  516
  read14  443
  read15  106
  read16  172
  read17  253
  read18  469
  read19  122
  read20  28
  read21  296
  read22  164
  read23  0
  read24  68
  read25  297
  read26  105
  read27  112
  read28  589
  read29  421
  read30  36
  read31  48
  read32  81
  read33  0
  read34  231
  read35  165
  read36  6
  read37  139
  read38  237
  read39  314
  read40  376
  read41  458
  read42  40
  read43  45
  read44  133
  read45  0
  read46  15
  read47  116
  read48  1
  read49  358
  ```

* Extract a piece of DNA from a FA file

  ```bash
  usage:
      faops frag [options] <in.fa> <start> <end> <out.fa>
  
  faops frag ufasta.fa 1 200 1.fa
  # this command could extract 1-200 sequences to 1.fa, but this command could only extract the first sequence among a file more than one sequence
  
  >read0:1-200
  tCGTTTAACCCAAatcAAGGCaatACAggtGggCCGccCatgTcAcAAActcgatGAGtgGgaAaTGgAgTgaAGcaGCAtCtGctgaGCCCCATTctctAgCggaaaATGgtatCGaACcGagataAGtTAAacCgcaaCgGAtaagGgGcgGGctTCAaGtGAaGGaAGaGgGgTTcAaaAgGccCgtcGtCaaTcAa
  ```

* Reverse complement a FA file

  ```bash
  usage:
      faops rc [options] <in.fa> <out.fa>
      
  faops rc ufasta.fa 2.fa
  ```

*
