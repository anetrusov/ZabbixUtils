#!/usr/bin/env perl
# $Header:  logparse.pl v.0.1.2 2014/06/16    al.netrusov@gmail.com   $
# Author:   Alexander Netrusov
###################################################################################
use strict;
use warnings;
use utf8;

use English qw(-no_match_vars);
use Carp ();

use FindBin               ();
use Digest::MD5           ();
use File::Spec::Functions ();

Carp::confess
  "Usage: ${PROGRAM_NAME} <file>[+multiline] <mask> <match> [<except>]"
  if !@ARGV || scalar @ARGV < 3;

my $argv = {};

for (qw|file mask match except|) {
    $argv->{$_} = shift @ARGV;
}

my ( $file, $multiline ) = $argv->{file} =~ m/(.+?)([+]multi[line]{0,4})?$/xms;

open my $fh, '<', $file
  or Carp::confess sprintf "Failed to open '%s': %s", $file,
  $EXTENDED_OS_ERROR;

seek $fh, readpos($file), 0;

my $entry = {};

while (<$fh>) {
    undef $entry->{final};

    if (m/$argv->{mask}/xms) {
        $entry->{final} = $entry->{temp};
        $entry->{temp}  = $_;
    }
    else {
        $multiline ? $entry->{temp} .= $_ : undef $entry->{temp};
    }

    for ( eof $fh ? ( 'final', 'temp' ) : 'final' ) {
        if ( $entry->{$_} && $entry->{$_} =~ m/$argv->{match}/xms ) {
            next
              if $argv->{except}
              && $entry->{$_} =~ m/$argv->{except}/xms;

            print $entry->{$_};
        }
    }
}

writepos( $file, tell $fh );

close $fh
  or Carp::confess 'Failed to close filehandle: ' . $EXTENDED_OS_ERROR;

sub readpos {
    my ($file) = @_;

    $file = File::Spec::Functions::catfile( $FindBin::Bin,
        q{.} . Digest::MD5::md5_hex($file) );

    my $pos = 0;

    if ( -f $file ) {
        open my $fh, '<', $file
          or Carp::confess "Failed to open '$file': " . $EXTENDED_OS_ERROR;

        chomp( $pos = <$fh> );

        close $fh
          or Carp::confess 'Failed to close filehandle: ' . $EXTENDED_OS_ERROR;
    }

    return $pos;
}

sub writepos {
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

__END__
