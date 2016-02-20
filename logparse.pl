#!/usr/bin/env perl
# $Header:  logparse.pl v.0.1.2 2014/06/16    al.netrusov@gmail.com   $
# Author:   Alexander Netrusov
###################################################################################
use strict;
use warnings;
use English qw(-no_match_vars);
use Carp ();

use FindBin               ();
use Digest::MD5           ();
use File::Spec::Functions ();

Carp::confess "Usage: ${PROGRAM_NAME} <file> <mask> <match> [<except>]"
    if !@ARGV || scalar @ARGV < 3;

my $argv = {};

for (qw|file mask match except|) {
    $argv->{$_} = shift @ARGV;
}

open my $fh, '<', $argv->{file}
    or Carp::confess sprintf "Failed to open '%s': %s", $argv->{file},
    $EXTENDED_OS_ERROR;

seek $fh, _readpos( $argv->{file} ), 0;

my ( $entry, $pos );

while (<$fh>) {
    if ( m/($argv->{mask})/xms || eof $fh ) {
        $entry .= $_ if eof $fh;

        if ($entry) {
            if ( $entry =~ m/$argv->{match}/xms ) {
                next
                    if $argv->{except}
                    && $entry =~ m/$argv->{except}/xms;

                print $entry, $/;
            }
        }

        $entry = $_;
        next;
    }
    $entry .= $_;
}

_writepos( $argv->{file}, tell $fh );

close $fh
    or Carp::confess 'Failed to close filehandle: ' . $EXTENDED_OS_ERROR;

sub _readpos {
    my ($file) = @_;

    $file = File::Spec::Functions::catfile( $FindBin::Bin,
        q{.} . Digest::MD5::md5_hex($file) );

    my $pos = 0;

    if ( -f $file ) {
        open my $fh, '<', $file
            or Carp::confess "Failed to open '$file': " . $EXTENDED_OS_ERROR;

        chomp( $pos = <$fh> );

        close $fh
            or Carp::confess 'Failed to close filehandle: '
            . $EXTENDED_OS_ERROR;
    }

    return $pos;
}

sub _writepos {
    my ( $file, $pos ) = @_;

    $file = File::Spec::Functions::catfile( $FindBin::Bin,
        q{.} . Digest::MD5::md5_hex($file) );

    open my $fh, '>', $file
        or Carp::confess sprintf "Failed to open '%s': %s", $file,
        $EXTENDED_OS_ERROR;

    print {$fh} $pos
        or Carp::confess sprintf "Failed to write to '%s': %s", $file,
        $EXTENDED_OS_ERROR;

    close $fh
        or Carp::confess 'Failed to close filehandle: ' . $EXTENDED_OS_ERROR;

    return 1;
}
