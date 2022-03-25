# 使用ggplot2中遇到的问题详解

在ggplot2画图时遇到了各种问题，在接下来会进行记录并不断更新

## 为何在.r script中会输出两张图

问题描述：由于需要将两幅图拼在一起，所以写了一个程序共同输出，但是在脚本运行时会出现两张图，一张图是默认大小的，另一张是指定了大小的。

```R
plot <- grid.arrange(plot1, plot2, ncol = 2, layout_matrix = rbind(c(1,1,1,2)))
pdf(plot, opt$out, width = 12, height = 3)
dev.off()
# layout_matrix can output a rearrange plot with different single plots
```

在研究了输出的结果，以及看了其他的一些脚本的写作方式，我发现，由于会输出一次默认大小的，而且命名为`Rplot`的图像。这说明该图像走的是默认的输出路径

问题主要出在`grid.arrange`命令中，因为这个命令会通过默认输出途径进行一次输出，之后pdf命令会再输出一次。因此只要改变一下命令的写作，即在pdf输出时使用`grid.arrange`命令即可

```R
pdf(opt$out, width = 12, height = 3)
grid.arrange(plot1, plot2, ncol = 2, layout_matrix = rbind(c(1,1,1,2)))
dev.off
```



## 如何改变堆积图的位置

由于需要输出

