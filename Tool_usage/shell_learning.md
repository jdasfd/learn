# shell learning and common command

用以记录常见的shell命令及学习过程

## grep

`-q : Quiet: do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.`
安静模式，不打印任何标准输出，当有匹配的内容时立即返回状态值0.

```bash
cat a.txt
nihao
nihaooo
hello

if grep -q hello a.txt; then
echo "yes";
else
echo "no";
fi
Output:
yes

if grep -q word a.txt; then
echo "yes";
else
echo "no";
fi
Output:
no
```

帮助判断是否含有字符串

## curl

`-L`：跟随网站的跳转
`-O`: 写入到文件，文件名和远程文件一样

## datamash
