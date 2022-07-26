# Perl Learning

## Perl shift() Function

### shift syntax and function

`shift()` function in Perl returns the first value in an array, removing it and shifting the elements of the array list to the left by one. Shift operation removes the value like pop but is taken from the start of the array instead of the end as in pop.

```perl5
shift(Array)
#Returns: -1 if array is Empty otherwise first element of the array
```

### shift without parameters

In case no array is passed to it, `shift` has two defaults depending on the location of `shift`.

- Shift outside any function

If `shift` is outside any function it takes the first element of `@ARGV` (the parameter list of the program).

**shift_argv.pl**

```perl5
use strict;
use warnings;

my $first = shift;
print "$first\n";
```

```bash
perl examples/shift_argv.pl one two
#one
```

- Shift inside a fuction

If `shift` is inside a function it takes the first element of `@_` (the parameter list of the function).

**shift_in_sub.pl**

```perl5
use strict;
use warnings;
 
sub something {
    my $first = shift;
    print "$first\n";
}
 
something('hello', 'world');
```

```bash
perl examples/shift_in_sub.pl one two
#hello
```

### Shift on empty array

`shift` will return `undef`. Regardless if the array was explicitely given to it or implicely selected based on the location of `shift`.

## Perl RE

### The Match Operator

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

- [shift in Perl](https://perlmaven.com/shift)
- [shift](https://www.geeksforgeeks.org/perl-shift-function/)
- [Perl regular expressions](https://www.tutorialspoint.com/perl/perl_regular_expressions.htm)