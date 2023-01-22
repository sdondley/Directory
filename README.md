[![Actions Status](https://github.com/sdondley/Directory/actions/workflows/test.yml/badge.svg)](https://github.com/sdondley/Directory/actions)

NAME
====

Directory - an object representing a directory

SYNOPSIS
========

```raku
use Directory;

# OBJECT CONSTRUCTION
my $dir = Directory.new('/some/dir'); # relative paths OK, too
my $dir = Directory.new('~');
my $dir = Directory.new();   # current working directory, '.'

# METHODS
my $bool = Directory.new('/some/dir').exists;
my $bool = Directory.new('/some/dir').is-empty;
my @entries = Directory.new('/some/dir').list;
my $bool = Directory.new('/some/dir').mktree;
my $bool = Directory.new('/some/dir').create;
my $bool = Directory.new('/some/dir').rmtree;
my $bool = Directory.new('/some/dir').empty-directory;
my $path = Directory.new('/some/dir').path;
my $dir = Directory.new('/some/dir').open;
my $sequence = $dir.dir;
$dir.close;
```

DESCRIPTION
===========

A Directory object wraps an [IO::Dir](https://raku.land/zef:raku-community-modules/IO::Dir) object as well as the the subroutines found in the [File::Directory::Tree](https://raku.land/github:labster/File::Directory::Tree) distribution. The module aims to make working with directories simpler. The primary motivation was for type constraining class attributes representing directories.

CONSTRUCTION
============

new(Str:D $path?)
-----------------

Creates a new Directory object from the `$path` supplied or with the path to the current working directory if no `$path` is given. An error is thrown if a file already exists at the `$path`. A path beginning with the `~` character is replaced with the value of the `$*HOME`> variable, if it contains a value.

METHODS
=======

Built-in methods
----------------

### exists

Returns a boolean value of `True` if the directory exists, `False` otherwise.

### is-empty

Returns a boolean value of `True` if the directory is empty, `False` otherwise.

### list(:Str, :absolute)

Returns an array of `IO::Path`s for each file and directory in the Directory object's path. Pass `:Str` to return strings instead and `:absolute` to return absolute paths.

### path

Returns the IO::Path object for the Directory object.

`IO::Dir` methods
-----------------

### open

Opens the Directory object with the `open` method from `IO::Dir`. Unlike with the `IO::Dir.open`, no path is passed to the method.

### dir(:Str, :absolute)

Runs the `dir` method from `IO::Dir`, returning a sequence of IO paths for files and directories contained by the Directory object. Pass `:Str` to return strings instead and `:absolute` to return absolute paths.

The Directory object must be opened with the `open` method before running this method.

### close

Closes the Directory object with the `close` method from `IO::Dir`

`File::Directory::Tree Wrapper` methods
---------------------------------------

### mktree($mask = 0o777)

A wrapper for the [File::Directory::Tree](File::Directory::Tree)'s mktree command.

### create($mask = 0o777)

Synonym for `mktree` method.

### rmtree

A wrapper for the [File::Directory::Tree](File::Directory::Tree)'s rmtree command.

### empty-directory

A wrapper for the [File::Directory::Tree](File::Directory::Tree)'s empty-directory command.

AUTHOR
======

Steve Dondley <s@dondley.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

