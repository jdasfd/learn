# Genome Mapping or Alignment

## BWT algorithm

二代数据：

- 短，一般在 250 bp 上下
- 相对较高的精度 0.001 = Q30

三代数据：

- 长
- 不稳定，会存在 100 bp 以上的structure variation

### 比对算法原理

Pairwise alignment:

- global NW (Needleman-Wunsch) algorithm
- local SW (Smith-Waterman) algorithm

**NW dynamic programming algorithm**:

$$Initialization : F(0,0)=0$$

$$Iteration: F(i,j) = max
\begin{cases}
        F(i-1,j)-d\\
        F(i,j-1)-d\\
        F(i-1,j-1)+s(x_i,y_j)
\end{cases}
\tag{1}
$$

$$Termination: Bottom\ right$$
