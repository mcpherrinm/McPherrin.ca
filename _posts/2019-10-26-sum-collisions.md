---
layout: post
title: Colliding the sum checksum
---

The `sum` command-line tool is a simple checksum utility included in BSD and
GNU Coreutils.  It is not a cryptographically secure hash, and so I wrote a
tool to set the `sum` of a file to an arbitrary value.

You can find that tool and associated code from this post on my github account
[in the sumcoll repository](https://github.com/mcpherrinm/sumcoll/)

## Usage

Sum takes file(s) on the command line and prints a checksum value in decimal,
along with a count of 1024-byte blocks.

```bash
$ echo abcdef > file
$ sum file
33901     1
```

## Backstory
Some years ago I was asked to include the BSD sums of a homework assignment, to
verify I had not modified the code after the assignment deadline.  The sums of
the files were included with a written portion submitted on paper in class, and
the code was graded later.

## Security
Using a non-cryptographically secure hash for this task is totally insecure, as
a malicious student could find another file which has the same checksum as what
was submitted on the paper handout.  The property needed to prevent that is
called **Second Preimage Resistance**.  The malicious student gets to pick `m1`
before the assignment deadline, and then afterwards, if they can find `m2` such
that `hash(m1) = hash(m2)`, they can submit `m2`, a second preimage, without
detection.  Whether `m2` will get them more marks is left as an exercise to the
student.

Even with no knowledge of the algorithm used, we can tell it's not secure.  We
can observe the output of the `sum` utility is a 16-bit number (printed in
decimal usually), along with a count of how many 1024 byte blocks are in the
input.  The output being only 16 bits is simply not large enough, and we can
use brute force to find collisions: If we sum `2^16 + 1` files, we are
guaranteed to find a collision.  That's not quite the 2nd preimage we want,
but it's illustrative of how a small checksum value cannot be cryptographically
secure.

## The Algorithm
There's no need blindly brute-force, as we can examine how `sum` works and be a
bit more intelligent about how we attack it.  The algorithm is very simple:
Each byte is added into a 16 bit counter, and the counter is rotated right
between each addition.  Or, in Python:

```python
def rotate_right_16bit(data: int) -> int:
  return (data >> 1) | ((data & 1) << 15)
for byte in data:
    sum = rotate_right_16bit(sum) + byte
    sum = sum & 0xffff # clamp to 16 bits
```

## Going Backwards
From looking at this algorithm, the first thing to notice is that all the
operations are reversible:  We can subtract and rotate left to go backwards.
That lets us add or change characters at any point in the file, and easily work
backwards to find out what the intermediate value of the checksum we need to
get our final goal value.

```python
def rotate_left_16bit(data: int) -> int:
  return (0xffff & (data << 1)) | (data >> 15)
for byte in reversed(suffix):
  sum = rotate_left_16bit((sum - byte) & 0xffff)
```

## Making Changes
The tool we're writing is going to insert bytes at a particular offset into the
file.  We'll put the extra inserted characters in a comment, string, or some
location that can be modified.  We'll compute the sum over a prefix up to the
insertion point, and use the backwards sum computation to approach that same
point from the opposite direction.

Our task now is to find a set of characters that will, when inserted after the
prefix, cause the sum to that point to equal the backwards sum.  This is likely
brute-forceable, but because we can go backwards, we can do a bit better.

## Meet In The Middle
The strategy we'll take for our tool is going to take advantage of the fact
that the set of possible hashes is small, and that we can go backwards.

We'll alternate extending prefix and suffix strings by an extra character and
then checking if the resulting hash is in the opposite set.  That is, we add to
the end of the prefix and check if we've hit any of the suffix hashes, and then
prepend to the suffix and check if we've hit any of the prefix hashes.

Because of the birthday paradox, and the fact that the set of hashes is only
2^16, the attack takes only a split second on my computer to run.

## Character Sets
The code for generating collisions takes a bytstring as input, and will only
use bytes from that.  This means you can, say, only feed it printable
characters, only ascii lowercase characters, or whatever you need to not break
the file you're trying to collide.

Typically that means you want printable characters without newline for many
comment "to the end of the line" style comments, or you can avoid `/` if you
are using something like CSS that only does `/* */` style comments.

## Block Size

Inserting a few bytes could change the number of blocks in the input.  You'll
have to figure out what to do about that yourself.  Try inserting the new bytes
at a different location, or removing some other bytes first.

## Conclusion

This isn't exactly a hardened target, so there's nothing really novel here, but
I haven't found any documentation of how to accomplish this elsewhere.

I doubt anyone will ever need this, but there is both an implementation of the
[sum tool and the attack tool here](https://github.com/mcpherrinm/sumcoll/).
If you have feedback on that tool or this blog post, feel free to post issues
there, or to email me.

