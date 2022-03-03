## 安装DBD::mysql时出现的错误

安装该模块中报错 libmysqlclient.so.16: cannot open shared object file: No such file or directory

这主要是因为安装的libmysqlclient.so.16路径无法被识别，要修改共享库配置文件/etc/ld.so.conf

1.使用locate定位libmysqlclient.so.16路径

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



##  Fastq > Fasta

```bash
awk '{if(NR%4 == 1){print ">" substr($0,2)}}{if(NR%4 == 2){print}}' fastq > fasta
# fastq means the name of fastq, for example, sample.fastq > sample.fasta
```



##  linuxbrew/xorg/libvdpau

Brew always warned you to use libvdpau  substituting linuxbrew/xorg/libvdpau.

This may be caused by the tap linuxbrew/xorg outdated.

```brew untap linuxbrew/xorg```



##  WSL2中出现 “参考的对象类型不支持尝试的操作” 的解决方法

原因：代理软件和WSL2的sock端口发生冲突

解决办法：使用netsh winsock reset重置修复。利用管理员身份打开CMD，在其中输入上述命令，重启后恢复正常

```
net winsock reset
```



##  Delete command in Linux quiker

Using CTRL + w to delete commands until the nearest "space"



##  如何使得自己编写的bash脚本变成可执行文件

1. 这里利用uzcat.sh脚本为例，首先将该脚本放入/bin文件夹之下作为可执行文件的存储地

2. ls -l进行查看，可以看到该文件的属性没有可执行，因此需要添加可执行权限

3. ```bash
   chmod u+x uzcat.sh
   ```

   为uzcat这个bash脚本加上可执行权限

4. ```bash
   ./uzcat.sh
   ```

   可以直接在当前路径启动该bash脚本
   
   

##  updatedb: can not open a temporary file for `/var/lib/mlocate/mlocate.db'

使用locate命令进行定位时，原理是将所有文件都收录到一个数据库中，在数据库中查找，从而显著的缩短所需使用的时间。而由于locate只会每天更新一次，所以刚刚安装的软件路径可能不会直接放入数据库，需要立马更新。

利用updatedb可以对数据库进行更新，遇到上面这个问题是因为权限不够

```bash
sudo updatedb
```

等待数据库更新完成就可以使用locate了，该方法搜索速度最快，比较好用



##  error: No curses/termcap library found

```bash
sudo apt-get install libncurses5-dev
```



##  Brew Could Not Resolve HEAD to a Revision

```bash
git -C $(brew --repository homebrew/core) checkout master
git -C $(brew --repository homebrew/core) reset --hard HEAD
```



##  DBD::mysql::db do failed: Specified key was too long; max key length is 1000 bytes at gr_db.pl

出现原因，ENGINE使用的是MyISAM，因此限制的最大key长度为1000 bytes。当初王老师在使用MySQL时版本为5.7，使用的CHARSET默认为latin1，即ASCII字符，为1 bytes。但是当系统更新到MySQL 8.0时，默认使用的字符是utf8，有长有短，为1 bytes至4 bytes，因此当key生成的时候就有可能超过1000，此时需要在init.sql中更新CHARSET，将CHARSET规定为latin1，这样就可以避免上述的问题