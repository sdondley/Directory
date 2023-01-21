use IO::Dir;
use File::Directory::Tree;
class X::Directory::FileExists is Exception {
    has IO::Path $.path;
    method message() {
        "Cannot create a Directory object. A file already exists at '" ~ $!path.Str ~ "'.";
    }
}

class X::Directory::NoHome is Exception {
    has IO::Path $.path;
    method message() {
        "The '~' was used in the path but no \$HOME environment variable exists.";
    }
}

class Directory is IO::Dir {
    has IO::Path $.path is required where dir-check($_);

    sub dir-check(IO::Path:D $path is copy) {
        die (X::Directory::FileExists.new(:$path)) if $path.f.Bool;
        return True;
    }

    method exists() {
        $!path.e;
    }

    method mktree(Int:D $mask = 0o777) {
        mktree($!path, :$mask);
    }

    method create(Int:D $mask = 0o777) {
        self.mktree(:$mask)
    }

    method rmtree() {
        rmtree($!path);
    }

    method empty-directory() {
        empty-directory($!path);
    }

    method read() {
        my @entries;
        self.open: $.path;
        @entries.push: self.dir(:Str).Slip;
        self.close;
        return @entries;
    }

    submethod BUILD(:$path is copy) {
        if ($path.Str eq '~' || $path.Str.substr(0, 2) eq '~/') {
            die (X::Directory::NoHome.new(:$path)) if !%*ENV<HOME>;
            my $home = %*ENV<HOME>;
            $path = $path.Str.subst('~', $home).IO;
        }
        $!path = $path;
    }

    method new(Str:D $path?) {
        if ($path) {
            self.bless(path => $path.IO);
        } else {
            self.bless(path => $*CWD);
        }
    }

}

=begin pod

=head1 NAME

Directory - an object representing a directory

=head1 SYNOPSIS

=begin code :lang<raku>

use Directory;

# OBJECT CONSTRUCTION
my $dir = Directory.new('/home/user/dir');
my $dir = Directory.new('~');
my $dir = Directory.new();   # current working directory, '.'

# METHODS
my $bool = Directory.new('/some/dir').exists;
my @entries = Directory.new('/some/dir').read;
my $bool = Directory.new('/some/dir').mktree;
my $bool = Directory.new('/some/dir').create;
my $bool = Directory.new('/some/dir').rmtree;
my $bool = Directory.new('/some/dir').empty-directory;
my $path = Directory.new('/some/dir').path;
Directory.new('/some/dir').open;
Directory.new('/some/dir').open.close;

=end code

=head1 DESCRIPTION

A Directory object is a subclass of an IO::Dir object and also wraps
the subroutines found in the File::Tree::Directory distribution with methods.
The module aims to make working with directories very simple.

=head1 CONSTRUCTION

=head2 new(Str:D $path?)

Creates a new Directory object from the C<$path> supplied or with the path to the
current working directory if no C<$path> is given.  An error is thrown
if a file already exists at the C<$path>. A path beginning with the C<~> character
is replaced with the value of the C<%*ENV<HOME\>> environment variable.

=head1 METHODS

=head2 exists

Returns a boolean value of C<True> if the directory exists, C<False> otherwise.

=head2 read

Returns an array of strings for each file and directory in the
Directory object's path.

=head2 path

Returns the IO::Path object for the Directory object.

=head2 open

Opens the Directory object with the C<open> method from C<IO::Dir>

=head2 close

Closes the Directory object with the C<close> method from C<IO::Dir>

=head2 mktree($mask = 0o777)

A wrapper for the L<File::Directory::Tree>'s mktree command.

=head2 create($mask = 0o777)

Synonym for C<mktree> method.

=head2 rmtree

A wrapper for the L<File::Directory::Tree>'s rmtree command.

=head2 empty-directory

A wrapper for the L<File::Directory::Tree>'s empty-directory command.

=head1 AUTHOR

Steve Dondley <s@dondley.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
