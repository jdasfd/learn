# Problem met during study

在这个markdown中主要记录了一些在学习的过程中遇到的一些问题，并且尽量记录一些可能有用的解决办法。

## 安装DBD::mysql时出现的错误

安装该模块中报错`libmysqlclient.so.16: cannot open shared object file: No such file or directory`

这主要是因为安装的`libmysqlclient.so.16`路径无法被识别，要修改共享库配置文件`/etc/ld.so.conf`

1.使用`locate`定位`libmysqlclient.so.16`路径

```bash
locate libmysqlclient.so.16
```

2.添加库的路径至配置文件

```bash
cd /etc
sudo vim ld.so.conf
/home/xx/mysql/lib/myql
```

3.是配置生效

````bash
sudo ldconfig
````

## linuxbrew/xorg/libvdpau

Brew always warned you to use libvdpau substituting linuxbrew/xorg/libvdpau.

This may be caused by the tap linuxbrew/xorg outdated.

`brew untap linuxbrew/xorg`

## WSL2中出现 “参考的对象类型不支持尝试的操作” 的解决方法

原因：代理软件和WSL2的sock端口发生冲突

解决办法：使用netsh winsock reset重置修复。利用管理员身份打开CMD，在其中输入上述命令，重启后恢复正常

`net winsock reset`

## Delete command in Linux quiker

Using CTRL + w to delete commands until the nearest "space"

## 如何使得自己编写的bash脚本变成可执行文件

1. 这里利用uzcat.sh脚本为例，首先将该脚本放入/bin文件夹之下作为可执行文件的存储地

2. `ls -l`进行查看，可以看到该文件的属性没有可执行，因此需要添加可执行权限

3. 使用`chmod`来改变文件的属性，为uzcat这个bash脚本加上可执行权限

   ```bash
   chmod u+x uzcat.sh
   ```

4. 可以直接在任意路径启动该bash脚本，因为`/bin`已经被添加到了`$PATH`下

   ```bash
   ./uzcat.sh
   ```

## updatedb: can not open a temporary file for `/var/lib/mlocate/mlocate.db'

使用locate命令进行定位时，原理是将所有文件都收录到一个数据库中，在数据库中查找，从而显著的缩短所需使用的时间。而由于locate只会每天更新一次，所以刚刚安装的软件路径可能不会直接放入数据库，需要立马更新。

利用updatedb可以对数据库进行更新，遇到上面这个问题是因为权限不够

```bash
sudo updatedb
```

等待数据库更新完成就可以使用locate了，该方法搜索速度很快，比较好用

## error: No curses/termcap library found

```bash
sudo apt-get install libncurses5-dev
```

## Brew Could Not Resolve HEAD to a Revision

```bash
git -C $(brew --repository homebrew/core) checkout master
git -C $(brew --repository homebrew/core) reset --hard HEAD
```

## DBD::mysql::db do failed: Specified key was too long; max key length is 1000 bytes at gr_db.pl

出现原因，ENGINE使用的是MyISAM，因此限制的最大key长度为1000 bytes。当初王老师在使用MySQL时版本为5.7，使用的CHARSET默认为latin1，即ASCII字符，为1 bytes。但是当系统更新到MySQL 8.0时，默认使用的字符是utf8,有长有短，为1 bytes至4 bytes，因此当key生成的时候就有可能超过1000，此时需要在init.sql中更新CHARSET，将CHARSET规定为latin1，这样就可以避免上述的问题

## Fastq > Fasta

```bash
awk '{if(NR%4 == 1){print ">" substr($0,2)}}{if(NR%4 == 2){print}}' fastq > fasta
# fastq means the name of fastq, for example, sample.fastq > sample.fasta
```

最简便的shell脚本进行处理，在`awk`中，`FNR`，`NR`，`NF`是内建变量

`NR (Number of Record)`表示从`awk`开始执行后，按照分隔符读取的数据次数，默认分隔符为换行符，表示读取的数据行数。

`FNR (File Number of Record)`指`awk`在处理多个输入文件的时候，在处理完第一个文件后，`NR`会继续累加，而新文件的`FNR`从1开始重新计数。

`NF (Number of Field)`记录目前被分割的字段的数目。

`faops filter`也可完成该任务，具体请参考[Faops_intro.md](Tool_usage/Faops_intro.md)

## Perl loadable library and perl binary are mismatched

最好的解决方式，把perl卸了重装一遍

```bash
rm -rf ~/perl5

brew install perl
# bash ~/Scripts/dotfiles/perl/install.sh
```

## 如何挂载外置的硬盘使得WSL2识别

```bash
sudo mount -t drvfs F: /mnt/f
ln -s /mnt/f/data/ ~/data
```

- If mount point does not exist, then you should first create that mount point.

```bash
cd /mnt
mkdir e
sudo mount -t drvfs E: /mnt/e
```

## 抑制linuxbrew自动更新

```bash
echo >> $HOME/.bashrc
echo >> $HOME/.bashrc
echo '# Close linuxbrew auto update' >> $HOME/.bashrc
echo "export HOMEBREW_NO_AUTO_UPDATE=1" >> $HOME/.bashrc
```

## Ubuntu目前遇到的问题

- Powershell中卸载Ubuntu

从设置的应用中无法成功卸载所有已安装的Linux子系统（ubuntu），因此使用这种方法将子系统清空。

```shell
# list all ubuntu in wsl2
wslconfig /l
# uninstall them
wslconfig /u Ubuntu # the name depends on your setting
```

- 关闭Ubuntu

目前遇到了一些无法解决的问题：Ubuntu会在运行一段时间后自动kill掉所有进程，并且卡在界面。重新启动之后无法使用`cd ~/`，`ls`等命令，也无法识别`ctrl+c`等有效操作，但是可以进行`sudo apt update`，也可以`cd /var`，除了用户根目录之下，上一层的文件夹均可以`cd`。

```shell
wsl --shutdown
```

- 打开WSL2的可视化界面

目前该问题已经被更新后的linux subsystem解决，目前WSL2安装后会在文件夹中映射一个驱动器，可以直接从`此电脑`中访问。

如果想从命令行直接打开当前文件夹，运行`explorer.exe .`即可。

## Ubuntu查询MAC地址

```bash
sudo lshw -c network | grep serial
```

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
