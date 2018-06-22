#!/usr/local/opt/perl/bin/perl

#
# Copyright (C) 2007-2008 by Qindel Formacion y Servicios S.L.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

use strict;
use warnings;
use JSON qw( decode_json ); # cpan install json
# use JSON qw( encode_json ); # cpan install json
use Data::Dumper;

my $usage = <<EOU;
Usage:
  $0 <config.json>

EOU

unless (@ARGV == 1) {
    die $usage;
}

my $configpath = $ARGV[0];
# my @args = @ARGV;
# @ARGV = ();

# print STDERR $configpath;

my $configtxt = do {
    open (my $configfile, "<$configpath") || die $!;
    local $/;
    <$configfile>
};

# print STDERR $configtxt;

my $config = decode_json($configtxt);

die("could not read config file $configpath") unless $config;

# print STDERR $config->{'map'};

# my @f2t;

# anything in map: will be the map (formerly args)
my $map = $config->{'map'};
my @f2re;

foreach my $pair(@$map) {
    # trim leading and trailing slashes
    # s|^/*|| for @$pair;
    # s|/*$|| for @$pair;
    my ($src, $targ) = @$pair;
    print STDERR "Map: $src — $targ\n";
    # $f2t{$src} = $targ;
    my @topush = ($src, $targ);
    push @f2re, \@topush;
}

# my @f = reverse sort keys %f2t;
# my @f2re = map { $_, qr|$_| } @f;

# anything in r0.mkdir will be created in the first revision

my $r1mkdir = $config->{'r1'}->{'mkdir'};

s|^/*|| for @$r1mkdir;
s|/*$|| for @$r1mkdir;


binmode STDIN;
binmode STDOUT;

$/ = "\x0A";

my $head = <STDIN>;
$head =~ /^SVN-fs-dump-format-version:\s*2\s*$/
    or die "invalid svn dump stream format: got $head\n";

print $head;

my $doInsertr1 = 0; # if 1: it means, we are at the end of r1's props.
my $nodeKind = 0;
my $nodeAction = 0;
my $nodePath = 0;

# print STDERR Dumper(@f2re);
my $nodePathIgnore = 0;
while (!eof STDIN) {
    my $line = <STDIN>;
    my $cl = 0;
    if (my ($k, $v) = $line =~ /^(.*?)\s*:\s*(.*)$/) {
        if ($k eq 'Node-path' or $k eq 'Node-copyfrom-path') {
            $nodePath = $v;
            if ($k eq 'Node-path') {
                foreach my $dir(@$r1mkdir) {
                    if ($v eq $dir) {
                        # print STDERR "$k !!! $v\n";
                        $nodePathIgnore = 1; # ignore this
                    }
                }
            }
            foreach my $pair (@f2re) {
                # print STDERR Dumper($pair);
                my $re = $pair->[0];
                my $targ = $pair->[1];
                # my ($re, $targ) = $pair;
                # my $re = $f2re{$from};
                my $oldv = $v;
                if ($v =~ s/$re/$targ/ee) {
                    # if (not $targ) {
                    # }
                    # if ($from eq '') {
                    #     $line = "$k: $f2t{$from}/$1$/";
                    # }
                    # else {
                        $line = "$k: $v\n";
                    # }
                    # print STDERR "from: $oldv, re: $re, to: $line\n";
                    last;
                }
            }
        }

        elsif ($k eq 'Content-length') {
            $cl = $v;
        }

        elsif ($k eq 'Revision-number' and $v eq '1') {
            $doInsertr1 = 1;
        }

        elsif ($k eq 'Node-kind') {
            $nodeKind = $v;
        }

        elsif ($k eq 'Node-action') {
            $nodeAction = $v;
            # if ($nodePathIgnore) {
            #     print STDERR "$nodeAction / $nodeKind / $line";
            # }
            if ($nodePathIgnore and $nodeAction eq 'add' and $nodeKind eq 'dir') {
                print STDERR "replacing $nodePath / $nodeAction / $nodeKind / $line";
                $line = "Node-action: change\n";
            }
        }
    } else {
        if ($doInsertr1) {
            # print STDOUT "-0\n\n\n";
            # additions
            print STDERR "# r1: mkdir...\n";
            foreach my $dir(@$r1mkdir) {
                print STDOUT <<EOU



Node-path: $dir
Node-kind: dir
Node-action: add
Prop-content-length: 10
Content-length: 10

PROPS-END
EOU
            }
            # print STDOUT "--1\n";
            $doInsertr1 = 0;
            $nodeKind = 0;
            $nodeAction = 0;
            $nodePath = '';
            $nodePathIgnore = 0;
        }
    }
    print $line;

    if ($cl) {
        dump_binary($cl);
        # reset stuff
        $nodeKind = 0;
        $nodeAction = 0;
        $nodePath = '';
        $nodePathIgnore = 0;
    }
}

sub path2re {
    my $p = shift;
    if (length $p) {
        my $re = quotemeta $p;
        return qr|^$re((?:/.*)?)$|;
    }
    else {
        return qr|^(.*)$|
    }
}

sub dump_binary {
    my $len = shift;
    while ($len) {
        my $max = 32 * 1024;
        $max = $len if $len < $max;
        my $b = read STDIN, my ($buf), $max;
        die "read failed\n" unless $b > 0;
        print $buf;
        $len -= $b;
    }
}


__END__

=head1 NAME

svn-dump-reloc - rewrite paths in a Subversion dump

=head1 SYNOPSIS

  svn-dump-reloc from to [from1 to1 [...]]

=head1 DESCRIPTION

This utility modifies a repository dump, rewriting file paths in
accordance with the passed arguments.

It reads the original repository dump from stdin and writes the
modified dump to stdout.

It is useful to import a repository as a subdirectory of another
already existent one. For instance:

  $ svnadmin dump /my/repos | svn-dump-reloc "/" "my/project" >dump

will relocate all the files in the dump to the subdirectory
C<my/project>.

Or to rename or move directories:

  $ svnadmin dump /my/repos | svn-dump-reloc "foo/doz" "bar" >dump

that will move the files in the directory C<foo/doz> to C<bar> leaving
the rest untouched.

Paths are always absolute and there is no need to begin them with a
slash (C</>). For instance, C<foo> and C</foo> are equivalent.

This program does not check for colisions on the file tree and so, it
is possible to generate corrupted dumps when some target path overlaps
with another directory present in the dump.

=head1 SEE ALSO

L<svnadmin>, L<svndumpfilter>, L<http://svnbook.red-bean.com/|the
Subversion book>.

=head1 AUTHOR

Salvador FandiE<ntilde>o <sfandino@yahoo.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007-2008 by Qindel Formacion y Servicios S.L.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
