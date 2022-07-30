# Variant format

Different format recording variants info.

## Default VEP input

The default format is a simple whitespace-separated format (columns may be separated by space or tab characters), containing five required columns plus an optional identifier column:

1. chromosome - just the name or number, with no 'chr' prefix
2. start
3. end
4. allele - pair of alleles separated by a '/', with the reference allele first
5. strand - defined as + or -
6. identifier - this identifier will be used in VEP's output.