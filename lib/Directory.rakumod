use IO::Dir;
use File::Directory::Tree;

class Directory {
    has IO::Path $!dirpath is required where dir-check($_);
    has IO::Dir $!iodir handles('dir', 'close') = IO::Dir.new;
    sub dir-check(IO::Path:D $path is copy) {
        die (X::Directory::FileExists.new(:$path)) if $path.f.Bool || return True;
    }

    has Int $!dir-count;
    has Int $!file-count;

    # IO::Dir method
    method open() { $!iodir.open: $!dirpath; }

    # File::Tree::Directory wrappers
    method mktree(Int:D $mask = 0o777) { mktree($!dirpath, :$mask); }
    method rmtree() { rmtree($!dirpath); }
    method empty-directory() { empty-directory($!dirpath); }
    method create(Int:D $mask = 0o777) { self.mktree(:$mask) }

    # custom methods
    method exists() { $!dirpath.e; }
    method path() { $!dirpath; }

    method is-empty() {
        $!iodir.open: $!dirpath;
        my $count = self.dir.elems;
        $!iodir.close;
        return $count ?? False !! True;
    }

    method list(Bool :$Str, Bool :$absolute, *%_ ()) {
        my @entries;
        $!iodir.open: $!dirpath;
        @entries.push: self.dir(:$Str, :$absolute).Slip;
        $!iodir.close;
        return @entries;
    }

    method gist() {
        my $out ~= "Directory: " ~ $!dirpath.absolute;
         when !self.exists {
             $out ~= "\nDoes not exist\n\n";
        }
        $!iodir.open: $!dirpath;
        my $dircnt = 0;
        my $filecnt = 0;
        for self.dir(:absolute).list -> $entry {
            $dircnt++ if $entry.d;
            $filecnt++ if $entry.f;
        }
        $!iodir.close;
        my $subdir = $dircnt != 1 ?? 'subdirectories' !! 'subdirectory';
        my $file = $filecnt != 1 ?? 'files' !! 'file';
        $out ~= "\nContains: $dircnt $subdir, $filecnt $file\n\n";
    }

    #| Trivial pluralisation.
    #| 1, 'file'                      --> "1 file"
    #| 2, 'file'                      --> "2 files"
    #| 3, 'directory', 'directories'  --> "3 directories"
    #| 1, 'directory', 'directories'  --> "1 directory"
    #| 0, 'directory', 'directories'  --> "0 directories"
    sub _plural ( $count, $descr, $plural = '' --> Str ) {
        $count
            ~ ' '
            ~ (    $count == 1 ?? $descr
                !! $plural     ?? $plural
                !! $descr ~ 's' );
    }

    # Alternate to .gist (usually a short one-line Str)
    method Str ( --> Str ) {
        my @str = "Directory:", $!dirpath.Str;
        if self.exists {
            @str.append( _plural( self.file-count, 'file') )
                if self.file-count > 0;
            @str.append( _plural( self.dir-count, 'directory', 'directories' ) )
                if self.dir-count > 0;
        }
        else {
            @str.append('(non-existant)');
        }
        @str.join(' ');
    }

    #| only count content entries once
    method count-content ( --> Int ) {
        unless $!dir-count.defined {
            $!dir-count = 0;
            $!file-count = 0;
            $!iodir.open: $!dirpath;
            for self.dir(:absolute).list -> $entry {
                given $entry {
                    when .d { $!dir-count++ }
                    when .f { $!file-count++ }
                }
            }
            $!iodir.close;
        }
        $!dir-count + $!file-count;
    }

    #| number of directories
    method dir-count ( --> Int ) {
        self.count-content unless $!dir-count.defined;
        $!dir-count;
    }

    #| number of files
    method file-count ( --> Int ) {
        self.count-content unless $!file-count.defined;
        $!file-count;
    }

    # object construction
    method new(Str $path?) {
        $path ?? self.bless(path => $path.IO) !! self.bless(path => '.');
    }

    submethod BUILD(:$path is copy) {
        if ($path.Str eq '~' || $path.Str.substr(0, 2) eq '~/') {
            die (X::Directory::NoHome.new(:$path)) if !$*HOME;
            $path = $path.subst('~', $*HOME).IO;
        }
        $!dirpath = IO::Path.new($path);
    }
}

class X::Directory::FileExists is Exception {
    has IO::Path $!dirpath;
    method message() {
        "Cannot create a Directory object. A file already exists at '" ~ $!dirpath.Str ~ "'.";
    }
}

class X::Directory::NoHome is Exception {
    method message() {
        "The '~' was used in the path but \$*HOME variable is not set.";
    }
}

=begin pod

=head1 NAME

Directory - an object representing a directory

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

A Directory object wraps an L<IO::Dir|https://raku.land/zef:raku-community-modules/IO::Dir>
object as well as the the subroutines found in the L<File::Directory::Tree|https://raku.land/github:labster/File::Directory::Tree> distribution.
The module aims to make working with directories simpler. The primary motivation
was for type constraining class attributes representing directories.

=head1 CONSTRUCTION

=head2 new(Str:D $path?)

Creates a new Directory object from the C<$path> supplied or with the path to the
current working directory if no C<$path> is given.  An error is thrown
if a file already exists at the C<$path>. A path beginning with the C<~> character
is replaced with the value of the C<$*HOME>> variable, if it contains a value.

=head1 METHODS

=head2 Built-in methods

=head3 exists

Returns a boolean value of C<True> if the directory exists, C<False> otherwise.

=head3 is-empty

Returns a boolean value of C<True> if the directory is empty, C<False> otherwise.

=head3 list(:Str, :absolute)

Returns an array of C<IO::Path>s for each file and directory in the
Directory object's path. Pass C<:Str> to return strings instead and
C<:absolute> to return absolute paths.

=head3 path

Returns the IO::Path object for the Directory object.

=head2 C<IO::Dir> methods

=head3 open

Opens the Directory object with the C<open> method from C<IO::Dir>. Unlike with
the C<IO::Dir.open>, no path is passed to the method.

=head3 dir(:Str, :absolute)

Runs the C<dir> method from C<IO::Dir>, returning a sequence of IO paths for
files and directories contained by the Directory object. Pass C<:Str> to return
strings instead and C<:absolute> to return absolute paths.

The Directory object must be opened with the C<open> method before running this method.

=head3 close

Closes the Directory object with the C<close> method from C<IO::Dir>

=head2 C<File::Directory::Tree Wrapper> methods

=head3 mktree($mask = 0o777)

A wrapper for the L<File::Directory::Tree>'s mktree command.

=head3 create($mask = 0o777)

Synonym for C<mktree> method.

=head3 rmtree

A wrapper for the L<File::Directory::Tree>'s rmtree command.

=head3 empty-directory

A wrapper for the L<File::Directory::Tree>'s empty-directory command.

=head1 AUTHOR

Steve Dondley <s@dondley.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
