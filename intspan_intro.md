# IntSpans using protocol

[IntSpan](https://github.com/wang-q/intspan) 主要用于操作不同的集合。在这之中，我们可以将不同的基因组比对结果作为集合，以此来快速处理匹配的结果.具体的使用详情请参考IntSpan软件主页的说明。此处主要记录的是该软件的使用细则。

主要的规则：

- `chrosome` 和 `start` 是必须有的
- `species`,`strand`和`end`是可选的
- `.` 用来分隔`species`和`chromosome`
- `strand`用括号内的`+`或`-`来表示正链或负链
- `:`用来分隔染色体的名称和其对应的数字
- `-`是开始和结束的分隔
- For `species`:
  - `species`应该是不包含空格的字母数字，唯一的例外是`/`
  - `species`只是一个标记，可以把它作为strain name，assembly，或其他的任何东西

最终形式：

```bash
species.chromosome(strand):start-end
--------^^^^^^^^^^--------^^^^^^----
```

## spanr 使用说明

tests文件请参考[IntSpan](https://github.com/wang-q/intspan)

- spanr genome

```bash
cat tests/spanr/S288c.chr.sizes | head -n 5
I       230218
II      813184
III     316620
IV      1531933
IX      439888
```

`.chr.sizes`包含了该物种每条染色体的长度，并以`tsv`格式进行排布

```bash
spanr genome tests/spanr/S288c.chr.sizes | head -n 5
---
I: 1-230218
II: 1-813184
III: 1-316620
IV: 1-1531933

spanr genome tests/spanr/S288c.chr.sizes |
    spanr stat tests/spanr/S288c.chr.sizes stdin --all
chrLength,size,coverage
12071326,12071326,1.0000

# --all: only write whole genome stat
```

`spanr genome`可以将`.chr.sizes`中以`tsv`格式排布的染色体长度信息变成`yml`表示的染色体范围。

`spanr stat`主要是统计`runlists`中的集合长度与整个染色体长度的覆盖度比较。`runlists`可以用`yml`的格式来表示。

- spanr some

```bash
spanr some tests/spanr/Atha.yml tests/spanr/Atha.list
```

`Atha.list`中有各个所需染色体的名称，`spanr some`会根据这些名称在一个大的`runlist.yml`文件中提取对应的范围。

- spanr cover

```bash
cat tests/spanr/S288c.ranges
I:1-100
I(+):90-150
S288c.I(-):190-200
II:21294-22075
II:23537-24097
S288c.I(-):190-200|Species=Yeast

spanr cover tests/spanr/S288c.ranges
---
I: "1-150,190-200"
II: "21294-22075,23537-24097"

cat tests/spanr/dazzname.ranges | head -n 5
infile_0/1/0_514:19-25
infile_0/1/0_514:26-37
infile_0/1/0_514:38-50
infile_0/1/0_514:51-55
infile_0/1/0_514:56-61

spanr cover tests/spanr/dazzname.ranges
---
infile_0/1/0_514: 19-499
```

`spanr cover`可以用来统计一个染色体上被覆盖的基因长度，即`covered length/all length`的比例，集合中会忽略链特异性以及物种的备注名称，如`|Species=Yeast`会被忽略。

- spanr gff

```bash
spanr gff tests/spanr/NC_007942.gff --tag tRNA
---
NC_007942: "3-77,1638-1672,4250-4286,9561-9634,9832-9870,10459-10493,13066-13138,13562-13609,14120-14154,14915-14987,16087-16174,24049-24122,24241-24311,25395-25487,29351-29422,30181-30253,30320-30403,30853-30926,33295-33365,51617-51688,51973-52021,52714-52736,53214-53300,54662-54733,64653-64726,64929-65002,85586-85659,93011-93091,99309-99380,101394-101430,102384-102418,102483-102520,103331-103365,107141-107214,107838-107909,123445-123524,127485-127556,128180-128253,132029-132063,132874-132911,132976-133010,133964-134001,136014-136085,142303-142383,149735-149808"

# --tag <tag>: primary tag (the third field) 
```

`spanr gff`可以提取`.gff`注释中对应的区域信息到一个`.yml`文件中。这里的tag信息是根据`gff`中第三列作为tag得到的。

- spanr span

```bash
cat tests/spanr/brca2.yml
---
13: 32316461-32316527,32319077-32319325,32325076-32325184,32326101-32326150,32326242-32326282,32326499-32326613,32329443-32329492,32330919-32331030,32332272-32333387,32336265-32341196,32344558-32344653,32346827-32346896,32354861-32355288,32356428-32356609,32357742-32357929,32362523-32362693,32363179-32363533,32370402-32370557,32370956-32371100,32376670-32376791,32379317-32379515,32379750-32379913,32380007-32380145,32394689-32394933,32396898-32397044,32398162-32398770


spanr span --op cover tests/spanr/brca2.yml
---
"13": 32316461-32398770


spanr span --op cover tests/spanr/brca2.yml | spanr span --op trim -n 300 stdin
---
"13": 32316761-32398470


spanr span --op holes tests/spanr/brca2.yml
---
"13": "32316528-32319076,32319326-32325075,32325185-32326100,32326151-32326241,32326283-32326498,32326614-32329442,32329493-32330918,32331031-32332271,32333388-32336264,32341197-32344557,32344654-32346826,32346897-32354860,32355289-32356427,32356610-32357741,32357930-32362522,32362694-32363178,32363534-32370401,32370558-32370955,32371101-32376669,32376792-32379316,32379516-32379749,32379914-32380006,32380146-32394688,32394934-32396897,32397045-32398161"


spanr span --op excise -n 1000 tests/spanr/brca2.yml
---
"13": "32332272-32333387,32336265-32341196"


spanr span --op fill -n 3000 tests/spanr/brca2.yml
---
"13": "32316461-32319325,32325076-32341196,32344558-32346896,32354861-32357929,32362523-32363533,32370402-32371100,32376670-32380145,32394689-32398770"

# --op <op>: operations: cover, holes, trim, pad, excise or fill [default: cover]
# --n
```

```txt
List of operations
    cover:  a single span from min to max
    holes:  all the holes in runlist
    trim:   remove N integers from each end of each span of runlist
    pad:    add N integers from each end of each span of runlist
    excise: remove all spans smaller than N
    fill:   fill in all holes smaller than or equals to N
```

`spanr span` 可以对`yml`中的范围进行操作。
`cover` 会提取`yml`中同一个区间上从最小到最大的一个单一范围区间。
`holes` 能够提取`yml`中显示区域的差集，即从`cover`中找到的最大范围区间内不包含`yml`中区间的那部分
`trim` 会给每个区间的左右两端各减去N个数
`pad` 会在每个区间两端各加上N个数
`excise` 会过滤掉那些区间总长小于N的区间
`fill` 当某个差集区间总长小于N时，会忽略这些区间，并且输出补上这些区间后的结果

- spanr compare

```bash
spanr compare \
    --op intersect \
    tests/spanr/intergenic.yml \
    tests/spanr/repeat.yml
---
I: "-"
II: "-"
III: "-"
IV: "-"
IX: "-"
V: "-"
VI: "-"
VII: 878539-878709
VIII: "-"
X: "-"
XI: "-"
XII: "65208"
XIII: "-"
XIV: "-"
XV: "-"
XVI: "-"

# --op <op>: Operations: intersect, union, diff or xor [default: intersect]
```

对两个`yml`进行比较，可以求`intersect`交集，`union`并集，`diff`差集，和`xor`异或的运算。

xor definition:

$A \Delta B = (A - B) \cup (B-A) = (A \cup B) - (A \cap B)$

- spanr convert

```bash
cat tests/spanr/repeat.yml
---
I: "-"
II: 327069-327703
III: "-"
IV: 512988-513590,757572-759779,802895-805654,981142-987119,1017673-1018183,1175134-1175738,1307621-1308556,1504223-1504728
IX: "-"
V: 354135-354917
VI: "-"
VII: 778784-779515,878539-879235
VIII: 116405-117059,133581-134226
X: 366757-367499,712641-713226
XI: 162831-163399
XII: 64067-65208,91960-92481,451418-455181,455933-457732,460517-464318,465070-466869,489753-490545,817840-818474
XIII: 609100-609861
XIV: "-"
XV: 437522-438484
XVI: 560481-561065

spanr convert tests/spanr/repeat.yml | head -n 5
II:327069-327703
IV:512988-513590
IV:757572-759779
IV:802895-805654
IV:981142-987119
```

`spanr convert`能够把区间文件`yml`转换成类似bed形式的范围格式。

- spanr range

```bash
cat tests/spanr/S288c.ranges
I:1-100
I(+):90-150
S288c.I(-):190-200
II:21294-22075
II:23537-24097
S288c.I(-):190-200|Species=Yeast

spanr range --op overlap tests/spanr/intergenic.yml tests/spanr/S288c.ranges
II:21294-22075
II:23537-24097

spanr range --op non-overlap tests/spanr/intergenic.yml tests/spanr/S288c.rang
es
I:1-100
I(+):90-150
S288c.I(-):190-200
S288c.I(-):190-200|Species=Yeast

# --op <op>: operations: overlap, non-overlap or superset [default: overlap]
```

`spanr range`可以根据`yml`中的范围，来确定`ranges`中被覆盖或没被覆盖的区域

overlap: `.range`文件中被`yml`覆盖到的区域

non-overlap: `.range`中没被`yml`覆盖的区域
