[![Actions Status](https://github.com/sdondley/Directory/actions/workflows/test.yml/badge.svg)](https://github.com/sdondley/Directory/actions)

NAME
====

Directory - an object representing a directory

SYNOPSIS
========

```raku
use Directory;

# OBJECT CONSTRUCTION
my $dir = Directory.new('/home/user/dir');
my $dir = Directory.new('~');
my $dir = Directory.new();   # current working directory, '.'

# METHODS
my $bool = Directory.new('/some/dir').exists;
my $bool = Directory.new('/some/dir').is-empty;
my @entries = Directory.new('/some/dir').read;
my $bool = Directory.new('/some/dir').mktree;
my $bool = Directory.new('/some/dir').create;
my $bool = Directory.new('/some/dir').rmtree;
my $bool = Directory.new('/some/dir').empty-directory;
my $path = Directory.new('/some/dir').path;
Directory.new('/some/dir').open;
Directory.new('/some/dir').open.close;
```

DESCRIPTION
===========

A Directory object is a subclass of an IO::Dir object and also wraps the subroutines found in the File::Tree::Directory distribution with methods. The module aims to make working with directories very simple.

CONSTRUCTION
============

new(Str:D $path?)
-----------------

Creates a new Directory object from the `$path` supplied or with the path to the current working directory if no `$path` is given. An error is thrown if a file already exists at the `$path`. A path beginning with the `~` character is replaced with the value of the `$*HOME`> variable.

METHODS
=======

exists
------

Returns a boolean value of `True` if the directory exists, `False` otherwise.

is-empty
--------

Returns a boolean value of `True` if the directory is empty, `False` otherwise.

read
----

Returns an array of strings for each file and directory in the Directory object's path.

path
----

Returns the IO::Path object for the Directory object.

open
----

Opens the Directory object with the `open` method from `IO::Dir`

close
-----

Closes the Directory object with the `close` method from `IO::Dir`

mktree($mask = 0o777)
---------------------

A wrapper for the [File::Directory::Tree](File::Directory::Tree)'s mktree command.

create($mask = 0o777)
---------------------

Synonym for `mktree` method.

rmtree
------

A wrapper for the [File::Directory::Tree](File::Directory::Tree)'s rmtree command.

empty-directory
---------------

A wrapper for the [File::Directory::Tree](File::Directory::Tree)'s empty-directory command.

AUTHOR
======

Steve Dondley <s@dondley.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

