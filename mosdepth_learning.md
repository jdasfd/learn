# Mosdepth learning

fast BAM/CRAM depth calculation for **WGS**, **exome**, or **targeted sequencing**.

利用mosdepth可以快速得到覆盖以及制定区域的覆盖度



* 输出路径指定

	首先，mosdepth不会给出output的参数，因此，在运行时会将文件输出到当前路径。因此在使用时可以在需要输出的路径中填写命令，如：

	```bash
	cd /mnt/e/project/srna/output/cover/trna
	
	parallel -j 3 " \
	mosdepth -t 4 -b ../../../annotation/bacteria/trna.bed \
	{} ../../bam/bacteria/{}.sort.bam \
	" ::: $(ls ../../bam/bacteria/*.sort.bam | \
	perl -p -e 's/\.sort\.bam//' | perl -p -e 's/^.+?\/S/S/')
	```

	提供输入文件的绝对路径



* 输出参数

	```bash
	Usage: mosdepth [options] <prefix> <BAM-or-CRAM>
	```

	这里的prefix是命名，对mosdepth文件进行命名，得到的每个mosdepth文件都会以输入的prefix来命名，因此在上面举例的命令中，在parallel传入参数的时候，一个单独的`{}`就是prefix命名，会将传入的文件作为输出的命名



* 输出文件解释

	输出文件包括了

	1. `mosdepth.global.dist.txt`

		共3列

		col 1 - 染色体号

		col 2 - 覆盖次数，即每一个位点被覆盖的次数有多少种

		col 3 - 每种覆盖次数的占所有的比例

		举例

		```tsv
		NC_008382.1	3	0.00
		NC_008382.1	2	0.00
		NC_008382.1	1	0.00
		NC_008382.1	0	1.00
		```

		该输出文件表示的是在`NC_008382.1`染色体上，有碱基被覆盖三次，有碱基被覆盖两次，有碱基被覆盖了一次，而没被覆盖的碱基占了几乎100%（保留两位小数，所以看不到上面三个的具体分布数值，估计非常小的一个数）

	2. `mosdepth.region.dist.txt`

		与上述类似，如果提供了bed区域给定覆盖region，则该文件就是制定region的覆盖情况

		同理，三列表示情况与上一个文件一致

	3. `mosdepth.summary.txt`

		有表头信息，其中chrom就是染色体编号，length是总该编号染色体的总长度，bases是被覆盖的长度，mean是平均的覆盖度（保留两位小数），min是被覆盖碱基的最低次数（0就是指有没被覆盖的碱基），max则是碱基被覆盖的最大次数

	4. `per-base.bed`

		共4列，以`bed.gz`输出，提取信息时需要解压

		col 1 - 染色体

		col 2 - start

		col 3 - end

		col 4 - 覆盖次数

	得知上面输出文件提供的主要信息后，就可以根据这些文件的内容，提取所需要的覆盖信息