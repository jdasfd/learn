# 正则匹配部分问题解决

## 贪婪与非贪婪模式问题

在写[methylation.md](methylation.md)时碰到了上述问题，其中有文件名如下：

`TetKO_bismark_bt2.deduplicated.bismark.cov.gz`

`WT_bismark_bt2.deduplicated.bismark.cov.gz`

现在需要在命令中得到一个合适的文件截取，想得到`TetKO`和`WT`最初结果见下：

```bash
for file in `ls *.cov.gz | perl -p -e 's/^(.+)_.+$/$1/'`
do
echo $file
done
#TetKO_bismark
#WT_bismark
```

造成这个结果的原因是`.+`是贪婪匹配，因此会尽量匹配到最后一个`_`，因此`_.+$`匹配到的是`_bt2 ... gz$`，所以结果是`TetKO_bismark`。

如果此时想要得到准确的第一个`_`之前的，就需要非贪婪模式。

非贪婪模式的使用：`?`。如`.+?`，`.*?`等

```bash
for file in `ls *.cov.gz | perl -p -e 's/^(.+?)_.+$/$1/'`
do
echo $file
done
#TetKO
#WT
```

注意贪婪和非贪婪模式的问题

## Perl - Regular Expressions

- The Match Operator

The match operator, m//, is used to match a string or statement to a regular expression. The m// actually works in the same fashion as the q// operator series.you can use any combination of naturally matching characters to act as delimiters for the expression. For example, m{}, m(), and m>< are all valid.

```perl5
$bar = "foo";
if ($bar =~ m[foo]) {
    print "Match.\n";
} else {
    print "Not match.\n";
}

# or
if ($bar =~ m{foo}) {
    print "Match.\n";
} else {
    print "Not match.\n";
}
```

Note that the entire match expression, that is the expression on the left of =~ or !~ and the match operator, returns true (in a scalar context) if the expression matches.

```perl5
$true = ($foo =~ m/foo/);
```

This will set `$true` to 1 if `$foo` matches the regex, or 0 if the match fails.

In a **list context**, the match returns the contents of any **grouped expressions**.

```perl5
my ($hours, $minutes, $seconds) = ($time =~ m/(\d+):(\d+):(\d+)/);
```

## References

- [Perl regular expressions](https://www.tutorialspoint.com/perl/perl_regular_expressions.htm)