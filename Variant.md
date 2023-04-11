# Variant Related

Different format recording variants info. And how to deal with it.

## Main Variant Format

### Default VEP input

The default format is a simple whitespace-separated format (columns may be separated by space or tab characters), containing five required columns plus an optional identifier column:

1. chromosome - just the name or number, with no 'chr' prefix
2. start
3. end
4. allele - pair of alleles separated by a '/', with the reference allele first
5. strand - defined as + or -
6. identifier - this identifier will be used in VEP's output.

An insertion (of any size) is indicated by start coordinate = end coordinate + 1. For example, an insertion of 'C' between nucleotides 12600 and 12601 on the forward strand of chromosome 8 is indicated as follows:

```txt
8   12601     12600     -/C   +
```

A deletion is indicated by the exact nucleotide coordinates. For example, a three base pair deletion of nucleotides 12600, 12601, and 12602 of the reverse strand of chromosome 8 will be:

```txt
8   12600     12602     CGT/- -
```

### VCF

VCF is a text file format (most likely stored in a compressed manner). It contains meta-information lines, a header line, and then data lines each containing information about a position in the genome.

For any unbalanced variant (i.e. insertion, deletion or unbalanced substitution), the VCF specification requires that the base immediately before the variant should be included in both the reference and variant alleles. This also affects the reported position i.e. the reported position will be one base before the actual site of the variant.

The above means an insertion will be showed in a different from the default VEP (same example):

```txt
8   12600   .   N   NC  .   PASS    DP=100
```

Examples from [vcf4.0]:

```vcf
##fileformat=VCFv4.0
##fileDate=20090805
##source=myImputationProgramV3.1
##reference=1000GenomesPilot-NCBI36
##phasing=partial
##INFO=<ID=NS,Number=1,Type=Integer,Description="Number of Samples With Data">
##INFO=<ID=DP,Number=1,Type=Integer,Description="Total Depth">
##INFO=<ID=AF,Number=.,Type=Float,Description="Allele Frequency">
##INFO=<ID=AA,Number=1,Type=String,Description="Ancestral Allele">
##INFO=<ID=DB,Number=0,Type=Flag,Description="dbSNP membership, build 129">
##INFO=<ID=H2,Number=0,Type=Flag,Description="HapMap2 membership">
##FILTER=<ID=q10,Description="Quality below 10">
##FILTER=<ID=s50,Description="Less than 50% of samples have data">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
##FORMAT=<ID=HQ,Number=2,Type=Integer,Description="Haplotype Quality">
#CHROM POS     ID        REF ALT    QUAL FILTER INFO                              FORMAT      NA00001        NA00002        NA00003
20     14370   rs6054257 G      A       29   PASS   NS=3;DP=14;AF=0.5;DB;H2           GT:GQ:DP:HQ 0|0:48:1:51,51 1|0:48:8:51,51 1/1:43:5:.,.
20     17330   .         T      A       3    q10    NS=3;DP=11;AF=0.017               GT:GQ:DP:HQ 0|0:49:3:58,50 0|1:3:5:65,3   0/0:41:3
20     1110696 rs6040355 A      G,T     67   PASS   NS=2;DP=10;AF=0.333,0.667;AA=T;DB GT:GQ:DP:HQ 1|2:21:6:23,27 2|1:2:0:18,2   2/2:35:4
20     1230237 .         T      .       47   PASS   NS=3;DP=13;AA=T                   GT:GQ:DP:HQ 0|0:54:7:56,60 0|0:48:4:51,51 0/0:61:2
20     1234567 microsat1 GTCT   G,GTACT 50   PASS   NS=3;DP=9;AA=G                    GT:GQ:DP    0/1:35:4       0/2:17:2       1/1:40:3
```

1. Meta-info lines

File meta-information is included after the `##` string, often as key=value pairs.

##INFO=<ID=ID,Number=number,Type=type,Description=”description”>

##FILTER=<ID=ID,Description=”description”>

##FORMAT=<ID=ID,Number=number,Type=type,Description=”description”>

2. The header line syntax

8 fixed, mandatory colomuns as follows:

`#CHROM POS ID REF ALT QUAL FILTER INFO`

If genotype data is present in the file, these are followed by a FORMAT column header, then an arbitrary number of sample IDs. The header line is tab-delimited.

3. Data lines

There are 8 fixed fields per record. All data lines are tab-delimited. In all cases, missing values are specified with a dot (”.”). Details could be seen on the [vcf4.0](https://www.internationalgenome.org/wiki/Analysis/vcf4.0).

Some useful info would be recorded here:

INFO additional information: (Alphanumeric String) INFO fields are encoded as a semicolon-separated series of short keys with optional values in the format: <key>=<data>[,data]. Arbitrary keys are permitted, although the following sub-fields are reserved (albeit optional):

- AA ancestral allele
- AC allele count in genotypes, for each ALT allele, in the same order as listed
- AF allele frequency for each ALT allele in the same order as listed: use this when estimated from primary data, not called genotypes
- AN total number of alleles in called genotypes
- BQ RMS base quality at this position
- CIGAR cigar string describing how to align an alternate allele to the reference allele
- DB dbSNP membership
- DP combined depth across samples, e.g. DP=154
- END end position of the variant described in this record (esp. for CNVs)
- H2 membership in hapmap2
- MQ RMS mapping quality, e.g. MQ=52
- MQ0 Number of MAPQ == 0 reads covering this record
- NS Number of samples with data
- SB strand bias at this position
- SOMATIC indicates that the record is a somatic mutation, for cancer genomics
- VALIDATED validated by follow-up experiment

As with the INFO field, there are several common, reserved keywords that are standards across the community:

- GT genotype, encoded as alleles values separated by either of ”/” or “|”, e.g. The allele values are 0 for the reference allele (what is in the reference sequence), 1 for the first allele listed in ALT, 2 for the second allele list in ALT and so on. For diploid calls examples could be 0/1 or 1|0 etc. For haploid calls, e.g. on Y, male X, mitochondrion, only one allele value should be given. All samples must have GT call information; if a call cannot be made for a sample at a given locus, ”.” must be specified for each missing allele in the GT field (for example ./. for a diploid). The meanings of the separators are:
    - `/`: genotype unphased, genotypes without regard to which one of the pair of chromosomes holds that allele
    - `|`: genotype phased, ordered along one chromosome so that you know the haplotype
- DP read depth at this position for this sample (Integer)
- FT sample genotype filter indicating if this genotype was “called” (similar in concept to the FILTER field). Again, use PASS to indicate that all filters have been passed, a semi-colon separated list of codes for filters that fail, or ”.” to indicate that filters have not been applied. These values should be described in the meta-information in the same way as FILTERs (Alphanumeric String)
- GL three floating point log10-scaled likelihoods for AA,AB,BB genotypes where A=ref and B=alt; not applicable if site is not biallelic. For example: GT:GL 0/1:-323.03,-99.29,-802.53 (Numeric)
- GQ genotype quality, encoded as a phred quality -10log_10p(genotype call is wrong) (Numeric)
- HQ haplotype qualities, two phred qualities comma separated (Numeric)

### Other formats

- [HGVS identifiers](https://varnomen.hgvs.org/)
- [Genomic SPDI notation](https://www.ncbi.nlm.nih.gov/variation/notation/)

It is not commonly used in my protocols, so details may not be recorded here.

## bcftools

Utilities for variant calling and manipulating VCFs and BCFs.

The version 1.15.1 is using here.

```bash
Program: bcftools (Tools for variant calling and manipulating VCFs and BCFs)
License: GNU GPLv3+, due to use of the GNU Scientific Library
Version: 1.15.1 (using htslib 1.15.1)

Usage:   bcftools [--version|--version-only] [--help] <command> <argument>

Commands:

 -- Indexing
    index        index VCF/BCF files

 -- VCF/BCF manipulation
    annotate     annotate and edit VCF/BCF files
    concat       concatenate VCF/BCF files from the same set of samples
    convert      convert VCF/BCF files to different formats and back
    head         view VCF/BCF file headers
    isec         intersections of VCF/BCF files
    merge        merge VCF/BCF files files from non-overlapping sample sets
    norm         left-align and normalize indels
    plugin       user-defined plugins
    query        transform VCF/BCF into user-defined formats
    reheader     modify VCF/BCF header, change sample names
    sort         sort VCF/BCF file
    view         VCF/BCF conversion, view, subset and filter VCF/BCF files

 -- VCF/BCF analysis
    call         SNP/indel calling
    consensus    create consensus sequence by applying VCF variants
    cnv          HMM CNV calling
    csq          call variation consequences
    filter       filter VCF/BCF files using fixed thresholds
    gtcheck      check sample concordance, detect sample swaps and contamination
    mpileup      multi-way pileup producing genotype likelihoods
    polysomy     detect number of chromosomal copies
    roh          identify runs of autozygosity (HMM)
    stats        produce VCF/BCF stats

 -- Plugins (collection of programs for calling, file manipulation & analysis)
    38 plugins available, run "bcftools plugin -lv" to see a complete list

 Most commands accept VCF, bgzipped VCF, and BCF with the file type detected
 automatically even when streaming from a pipe. Indexed VCF and BCF will work
 in all situations. Un-indexed VCF and BCF and streams will work in most but
 not all situations.
```

## Reference:

- [VEP Data formats](https://asia.ensembl.org/info/docs/tools/vep/vep_formats.html)
- [vcf4.0](https://www.internationalgenome.org/wiki/Analysis/vcf4.0)
- [phased and unphased genotypes](https://www.biostars.org/p/7846/)
