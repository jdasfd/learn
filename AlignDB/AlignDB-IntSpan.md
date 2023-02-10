# AlignDB::IntSpan 使用说明

模块由导师编写，具体的详细情况请参考[AlignDB-IntSpan](https://github.com/wang-q/AlignDB-IntSpan)

本文主要是翻译模块使用说明，及大概的使用范例。

`AlignDB::IntSpan` - 整数集合处理。

## 使用概要 (SYNOPSIS)

- 在Perl中使用：

```perl
use AlignDB::IntSpan;

my $set = AlignDB::IntSpan -> new;
$set -> add(1, 2, 3, 5, 7, 9);
$set -> add_range(100, 1_000_000);
print $set -> as_string, "\n";  # 1-3,5,7,9,100-1000000
```

- Operator overloads

```perl
if ($set) {...}     # true if $set is not empty
print "$set\n";     # stringizes to the runlist
```

## 软件描述

`AlignDB::IntSpan`模块可以将整数集合变成一个包含区间 (inclusive ranges)。因为许多操作只涉及范围列表 (the list of ranges)的线性搜索，所以总体性能往往与范围的数量成正比。

模块的内部表示原理：偶数开始，奇数结束。如一个集合(1, 3-7, 9, 11, 12)就会被表示为(1, 2, 3, 8, 11, 13)。

- 无穷大集合

无限集合无法直接设置，模块中使用的是一个相当大的整数，具体来说`$NEG_INF`和`$POS_INF`被定义为`-(2^31-1)`和`(2^31-2）`，如果接受这样一个相对弱的定义。当然无限集也可以通过翻转空集得到：

```perl
my $inf = AlignDB::IntSpan -> new -> complement;
```

- 集合只在一个方向上有界 - 如所有正整数的集合（假设接受无穷大的弱定义，见上）：

```perl
my $pos_int = AlignDB::IntSpan -> new;
$pos_int -> add_range(1, $pos_int -> POS_INF);
```

## 方法

### 整数

### POS_INF

### NEG_INF

### EMPTY_STRING

### INTERFACE: Set creation

- new

```perl
my $set = AlignDB::Intspan -> new;      # empty set
my $set = AlignDB::Intspan -> new($set_spec);   # the content of $set_spec
my $set = AlignDB::Intspan -> new(@set_specs);  # the union of @set_specs
```

创建并返回一个`AlignDB::IntSpan`的对象。

- valid

```bash
my $ok = AlignDB::IntSpan -> valid($runlist);
```

如果`$runlist`是有效runlist，返回true。

- clear

```bash
$set -> clear;
```

清除`$set`的全部内容。

### INTERFACE: Set contents

- edges_ref

返回表示集合的`ArrayRef`。

- edges

返回表示集合的内部`used Array`。

- edge_size

返回number of edges。

- span_size

返回number of spans。

- as_string

返回集合的字符串表示形式。

- as_array

返回一个包含集合中所有成员的升序数组。

### INTERFACE: Span contents

- ranges

返回the runs in $set，以列表 ($lower, $upper) 的形式返回。

- spans

返回the runs in $set, 以列表 [$lower, $upper] 的形式返回。

- sets

返回the runs in $set, 作为`AlignDB::IntSpan`对象的列表。列表中的集合按照顺序排列。

- runlists

返回the runs in $set, 以列表 "$lower-$upper" 的形式返回。

### INTERFACE: Set cardinality

- cardinality

返回$set中的元素个数。

- is_empty

若集合是空，返回true。

- is_not_empty

若集合不是空，返回true。

- is_neg_inf

若集合是负无穷，返回true。

- is_pos_inf

若集合是正无穷，返回true。

- is_infinite

若集合是无穷的，返回true。

- is_finite

若集合是有限的，返回true。

- is_universal

若集合含有所有的整数，返回true。

### INTERFACE: Membership test

- contains_all

若集合包含所有特定的数字(specified numbers)，则返回true。

- contains_any

若集合包含任何特定的数字(specified numbers)之一，则返回true。

### INTERFACE: Member operations

- add_pair

```perl
$set -> add_pair($lower, $upper);
```

添加一对表示范围的整数(inclusive integers)到set中。

一对arguments构成一个范围。

- add_range

```perl
$set -> add_range($lower, $upper);
```

添加整数包含的区域到set中。

可以指定多个范围。每一对参数构成一个范围。

- add_runlist

```perl
$set -> add_runlist($runlist);
```

添加特定的runlist添加到set中。

- add

```perl
$set -> add($number1, $numer2, $number3 ...);
$set -> add($runlist);
```

将特定的整数或runlist添加到set中。

- invert

```perl
$set = $set -> invert;
```

set相对于整个集合的补集。假设`$set`为集合$A$，则`$set -> invert`相当于$\bar{A}$。要注意该插件目前是在一个有限集合内对一个有限集求补集——因此补集仍旧是一个有限集，只是`$NEG_INF`和`$POS_INF`是个非常大的整数。

- remove_range

```perl
$set -> remove_range($lower, $upper);
```

将某一范围内的整数从set中移除。

多个范围的移除需要明确指定。每一对arguments组成一个范围。

- remove

```perl
$set -> remove($number1, $number2, $numer3 ...);
$set -> remove($runlist);
```

将特定的整数或runlist从set中移除。

- merge

```perl
$set -> merge($another_set);
$set -> merge($set_spec);
```

将提供的another_set或者特定集合(set_spec)的成员合并到set中。可以提供任意数量的集合作为参数。

- subtract

```perl
$set -> subtract($another_set);
$set -> subtract($set_spec);
```

从set中减去提供的another_set或者特定集合(set_spec)的成员。可以提供任意数量的集合作为参数。

### INTERFACE: Set operations

- copy

```perl
my $new_set = $set -> copy;
```

返回set的相同副本到new_set中。

- union

```perl
# be called either as a method
my $new_set = $set -> union($other_set);

# or as a function
my $new_set = AlignDB::IntSpan::union($set1, $set2, $set3);
```

返回一个new_set，其包含了set和提供的other_set的并集。

- complement

```perl
my $new_set = $set -> complement;
```

返回一个new_set，是set的补集（关于这个`$set`最大范围的补集，这是与`invert`的区别）。

- diff

```perl
my $new_set = $set -> diff($other_set);
```

返回一个new_set，其包含了set中所有的元素，但是不包含所提供的集合(other_set)。

- intersect

```perl
# be called either as a method
my $new_set = $set -> intersect($other_set);

# or as a function
my $new_set = AlignDB::IntSpan::intersect($set1, $set2, $set3);
```

返回一个new_set，其包含了set和提供的other_set的交集。

- xor

```perl
# be called either as a method
my $new_set = $set -> xor($other_set);

# or as a function
my $new_set = AlignDB::IntSpan::xor($set1, $set2, $set3);
```

返回一个new_set，其包含了set或是提供的other_set的成员，但是不包含同时出现在这些集合中的元素（去除交集）。

可以实际上处理两个以上的集合，在集合数量超过两个时，实际返回的只是不包含所有集合的交集的那个部分的元素。

### INTERFACE: Set comparison

- equal

当`$set`和`$set_spec`相等时，返回true。

- subset

当`$set`是`$set_spec`的子集时，返回true。

- superset

当`$set`是`$set_spec`的超集时，返回true。

- smaller_than

当`$set`比`$set_spec`小时，返回true。

- larger_than

当`$set`比`$set_spec`大时，返回true。

### INTERFACE: Indexing

- at

返回集合中指定顺序（index）的数值，index从"1"开始。负的indices（index复数）从集合末尾开始计数。

- index

返回index of a element in the set，index从"1"开始。

- slice

对两个给定的indexes，返回一个子集。这些indexes必须是正数。

### INTERFACE: Extrema

- min

返回`$set`最小的元素，若`$set`为空时返回`undef`。

- max

返回`$set`最大的元素，若`$set`为空时返回`undef`。

### INTERFACE: Spans operations

- banish_span

- cover

返回一个包含单独的`$set -> min` to `$set -> max`的集合。

- holes

返回一个包含了`$set`中所有范围没有被包含的集合。

- inset

inset会返回一个集合，该集合是通过从`$set`的么个区间两端移除`$n`整数来构造的。如果`$n`为负，则`-$n`整数被加到每个span的端点。

- trim

与inset功能一致。

- pad

`$set -> pad($n)` 与 `$set -> inset(-$n)`一致。

- excise

```perl
my $new_set = $set -> excise($minlength)
```

去除`$set`中所有比`$minlength`小的范围。

- fill

```perl
my $new_set = $set -> fill($maxlength)
```

`$set`中所有比`$maxlength`小的范围都会被填满。

### INTERFACE: Inter-set operations

- overlap

```perl
my $overlap_amount = $set -> overlap($another_set)

# equivalent to
$set -> intersect($another_set) -> size;
```

返回两个集合交集的长度。

- distance

```perl
my $distance = $set -> distance($another_set);
```

返回集合之间的距离，按如下方式测量。

如果集合之间有重叠，那么距离会是负的

```perl
$d = - $set -> overlap($another_set);
```

如果集合不重叠，则`$d`是正的，集合中最近的两个islands之间的整数在直线上的距离给出。

### INTERFACE: Islands

- find_islands

```perl
my $island = $set -> find_islands($integer);
my $new_set = $set -> find_islands($another_set);
```

返回一个包含岛屿的集合(`$set`包含`$integer`)。如果`$integer`不在`$set`中，则返回空集合。

返回一个包含所有岛屿的集合(`$set`与`$another_set`的交集)。如果`$another_set`和`$set`交集为空，那么返回空集合。

- nearest_island

```perl
my $island = $set -> nearest_island($integer);
my $island = $set -> nearset_island($another_set);
```

返回`$set`最近的包含`$integer`但是不会与`$set`重叠的island(s)。如果`$integer`恰好位于两个islands之间，则返回的集合包含这两个islands。

返回`$set`中与`$another_set`相交但不重叠的最近的island(s)。如果`$another_set`恰好位于两个islands之间，则返回的集合包含这两个islands。

- at_island

```perl
my $island = $set -> at_island($island_index);
```

返回由`$island_index`索引了的island。Islands are 1-indexed。对于具有N个islands的集合，第一个island（从左到右）是index 1，最后一个为index N。如果`$island_index`是负的，计数则从最后一个island开始(c.f. negative indexes of Perl arrays)。

### INTERFACE: Aliases

```perl
runlist         => as_string
elements        => as_array
size, count     => cardinality
contains        => contains_all
intersection    => intersect
equals          => equal
```
