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

### Metacharacters

The metacharacter `"|"` is used to match one thing or another. You aren't limited to just a single `|`.

```perl5
$foo =~ m/fee|fie|foe|fum/
```

The `"|"` binds less tightly than a sequence of ordinary characters. We can override this by using the grouping metacharacters, the parentheses `"("` and `")"`.

```perl5
$foo =~ m/th(is|at) thing/
```

The first alternative includes everything from the last pattern delimiter (`"("`, `"(?:"` (described later), etc. or the beginning of the pattern) up to the first `|`, and the last alternative contains everything from the last `|` to the next closing pattern delimiter. That's why it's common practice to include alternatives in parentheses: to minimize confusion about where they start and end.

Alternatives are tried from left to right, so the first alternative found for which the entire expression matches, is the one that is chosen. This means that alternatives are not necessarily greedy. For example: when matching `foo|foot` against `"barefoot"`, only the `"foo"` part will match, as that is the first alternative tried, and it successfully matches the target string. (This might not seem important, but it is important when you are capturing matched text using parentheses.)

Only the `"\"` is always a metacharacter. The others are metacharacters just sometimes. The following tables lists all of them, summarizes their use, and gives the contexts where they are metacharacters.

```txt
           PURPOSE                                  WHERE
\   Escape the next character                    Always, except when
                                                 escaped by another \
^   Match the beginning of the string            Not in []
      (or line, if /m is used)
^   Complement the [] class                      At the beginning of []
.   Match any single character except newline    Not in []
      (under /s, includes newline)
$   Match the end of the string                  Not in [], but can
      (or before newline at the end of the       mean interpolate a
      string; or before any newline if /m is     scalar
      used)
|   Alternation                                  Not in []
()  Grouping                                     Not in []
[   Start Bracketed Character class              Not in []
]   End Bracketed Character class                Only in [], and
                                                   not first
*   Matches the preceding element 0 or more      Not in []
      times
+   Matches the preceding element 1 or more      Not in []
      times
?   Matches the preceding element 0 or 1         Not in []
      times
{   Starts a sequence that gives number(s)       Not in []
      of times the preceding element can be
      matched
{   when following certain escape sequences
      starts a modifier to the meaning of the
      sequence
}   End sequence started by {
-   Indicates a range                            Only in [] interior
#   Beginning of comment, extends to line end    Only with /x modifier
```

To simplify multi-line substitutions, the `"."` character never matches a newline unless you use the `/s` modifier, which in effect tells Perl to pretend the string is a single line--even if it isn't.

### Modifiers

- `m`

    Treat the string being matched against as multiple lines. That is, change `"^"` and `"$"` from matching the start of the string's first line and the end of its last line to matching the start and end of each line within the string.

- `s`

    Treat the string as single line. That is, change `"."` to match any character whatsoever, even a newline, which normally it would not match.

- `i`

    Do case-insensitive pattern matching. For example, "A" will match "a" under `/i`.

- `x` and `xx`

    A single `/x` tells the regular expression parser to ignore most whitespace that is neither backslashed nor within a bracketed character class. You can use this to break up your regular expression into more readable parts. Also, the "#" character is treated as a metacharacter introducing a comment that runs up to the pattern's closing delimiter, or to the end of the current line if the pattern extends onto the next line.
    
    A common pitfall is to forget that "#" characters (outside a bracketed character class) begin a comment under /x and are not matched literally. Just keep that in mind when trying to puzzle out why a particular /x pattern isn't working as expected. Inside a bracketed character class, "#" retains its non-special, literal meaning.

### Extended Patterns

The syntax for most of these is a pair of parentheses with a question mark as the first thing within the parentheses. The character after the question mark indicates the extension.

- `(?#text)`

  A comment. The text is ignored. Note that Perl closes the comment as soon as it sees a `")"`, so there is no way to put a literal `")"` in the comment. The pattern's closing delimiter must be escaped by a backslash if it appears in the comment.


- `(?adlupimnsx-imnsx)` or `(?^alupimnsx)`

  Zero or more embedded pattern-match modifiers, to be turned on (or turned off if preceded by `"-"`) for the remainder of the pattern or the remainder of the enclosing pattern group (if any). 

  This is particularly useful for dynamically-generated patterns, such as those read in from a configuration file, taken from an argument, or specified in a table somewhere. Consider the case where some patterns want to be case-sensitive and some do not: The case-insensitive ones merely need to include `(?i)` at the front of the pattern.

  ```txt
  $pattern = "foobar";
  if ( /$pattern/i ) { }
  
  # more flexible:
  
  $pattern = "(?i)foobar";
  if ( /$pattern/ ) { }
  ```

  Starting in Perl 5.14, a `"^"` (caret or circumflex accent) immediately after the `"?"` is a shorthand equivalent to `d-imnsx`. Flags (except `"d"`) may follow the caret to override it. But a minus sign is not legal with it.

  Note also that the `"p"` modifier is special in that its presence anywhere in a pattern has a global effect.


- `(?:pattern)`, `(?adluimnsx-imnsx:pattern)`, `(?^aluimnsx:pattern)`

  This is for clustering, not capturing; it groups subexpressions like "()", but doesn't make backreferences as "()" does. So

  ```txt
  @fields = split(/\b(?:a|b|c)\b/)
  ```

  matches the same field delimiters as

  ```txt
  @fields = split(/\b(?:a|b|c)\b/)
  ```

  but doesn't spit out the delimiters themselves as extra fields (even though that's the behaviour of "split" in perlfunc when its pattern contains capturing groups). It's also cheaper not to capture characters if you don't need to.

## References

- [shift in Perl](https://perlmaven.com/shift)
- [shift](https://www.geeksforgeeks.org/perl-shift-function/)
- [Perl regular expressions](https://www.tutorialspoint.com/perl/perl_regular_expressions.htm)