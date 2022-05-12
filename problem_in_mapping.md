# 在sRNA流程中alignment相关问题

## 比对参数以及选择范围

Q：为何要选择bowtie2？

A：在目前我见过的比对软件中，主要有`bwa`，`bowtie`和`bowtie2`。它们三个均采用的相同的算法进行比对，即BWT。

`bowtie`和`bowtie2`相比于`bwa`来说
  
- `bwa`可以仔细的选择不同的算法，但是与`bowtie 1/2`相比，比对的速度和敏感度均处于相对的劣势，具体的数据可以参照[Bowtie 2 versus BWA](http://seqanswers.com/forums/showthread.php?t=15200)
- `bowtie`与`bowtie2`的主要区别在于，`bowtie2`更新并允许了gap的出现。同时由于两者开发的年份并不相同。`bowtie`更适合于小片段的比对任务，而`bowtie2`则更适用于大的片段长度。两者速度都很快。
- **注意**：`bowtie -v 0`能够允许序列完全一致的比对，但是`bowtie2`不行，需要通过`sam`文件中的`CIGAR`列来完成，因此需要`--xeq`参数来显示比对的具体项目。

根据上述的结果，我最终选择了`bowtie2`作为初步比对流程的软件。

- bowtie2中的比对结果

`bowtie2`比对是需要用到的参数及解释：

```bash
bowtie2
```
