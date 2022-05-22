# AlignDB::Stopwatch 使用说明

模块由导师编写，具体的详细情况请参考[AlignDB-Stopwatch](https://github.com/wang-q/AlignDB-Stopwatch)

本文主要是翻译模块使用说明，及大概的使用范例。

`AlignDB::Stopwatch` - 记录运行时间并打印标准信息(standard messages)。

## 使用概要 (SYNOPSIS)

- 在Perl中使用：

```perl
use AlignDB::Stopwatch;

# record command line
my $stopwatch = AlignDB::Stopwatch -> new -> record;

# record config
$stopwatch -> record_conf($opt)

$stopwatch -> start_message("Doing really bad things...");

$stopwatch -> end_message;
```

## 属性 (ATTRIBUTES)

- program_name

程序名称

- program_argv

程序命令行选项

- program_conf

程序配置

- start_time

开始时间

- div_char

输出信息中的分隔符，默认为`[=]`

- div_length

分隔符的长度，默认为`[30]`

- min_div_length

最小的单边(single-side)分隔符长度，默认为`[5]`

- uuid

使用`Data::UUID`生成一个UUID，防止在多线程模式下多次插入元信息(prevent inserting meta info)。

## 方法 (METHODS)

- record

将`$main::0`记入program_name，将`[@main::ARGV]`记入program_argv。

`Getopt::Long`可以操作@ARGV.

```perl
my $stopwatch = AlignDB::Stopwatch -> new -> record;
```

- record_conf

将hashref或者一个对象记入program_conf。

```perl
$stopwatch -> record_conf($opt);
```

- block_message

打印终止信息。

```perl
$stopwatch -> block_message($message, $with_duration);
```

- start_message

打印开始信息。

```perl
$stopwatch -> start_message($message, $embed_in_divider);
```

- end_message

打印结束信息。

```perl
$stopwatch -> end_message($message);
```
