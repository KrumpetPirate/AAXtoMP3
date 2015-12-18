#!/usr/bin/env perl
use strict;
use warnings;
use v5.22.0;
use autodie;
use Getopt::Long qw/GetOptions/;
Getopt::Long::Configure qw/gnu_getopt/;
use File::Basename qw/fileparse/;
use IO::CaptureOutput qw/capture_exec/;

say "Starting $0...";

my $VERBOSE;
my $AUTHCODE;
my $INPUT_FILE;
GetOptions(
    'auth|a=s' => \$AUTHCODE,
    'input|i=s' => \$INPUT_FILE,
    'verbose|v' => \$VERBOSE,
) or die "Usage: $0 -verbose -auth <AUDIBLE AUTH CODE> -input <INPUT FILE PATH>";
die "Usage: $0 -verbose -auth <AUDIBLE AUTH CODE> -input <INPUT AAX PATH>"
    unless ($INPUT_FILE && $AUTHCODE);
die "$INPUT_FILE is not a valid path" unless (-f $INPUT_FILE);

my ($filename, $dir, $extension) = fileparse($INPUT_FILE, qr/\.[^.]*/);
my $ret = system_execute("ffprobe $INPUT_FILE");

my @fflines = split /\n/, $ret;
my $file_type = pull_from_ffprobe("major_brand", @fflines);
my $file_title = pull_from_ffprobe("title", @fflines);
my $file_author = pull_from_ffprobe("artist", @fflines);
die "Input file ffprobe does not appear to match an AAX file type metadata"
    unless $file_type =~ /aax/;

my $output;
if ($file_title && $file_author) {
    $output = "$file_title by $file_author";
} else {
    $output = $filename;
}
my $output_sh_safe = quotemeta $output;
say "Using Audible auth code to copy AAX audio directly to MP3 format...";
$ret = system_execute("ffmpeg -activation_bytes $AUTHCODE -i $INPUT_FILE -vn -c:a libmp3lame -ab 128k $dir$output_sh_safe.mp3");
say $ret if $VERBOSE;

say "End of $0...";

sub system_execute {
    my ($stdout, $stderr, $success, $exit_code) = capture_exec(@_);
    say "stdout: $stdout\nstderr: $stderr\nsuccess: $success\nexit code: $exit_code" if ($VERBOSE);
    if ($success) {
        return $stdout if $stdout;
        return $stderr if $stderr;
    } else {
        my $command = join " ", @_;
        die "Command $command was not successful, debug.";
    }
}

sub pull_from_ffprobe {
    my $desired = shift;
    my @fflines = @_;
    return unless ($desired && @fflines);
    my ($line) = grep { m/^\s+$desired/ } @fflines;
    $line =~ s/^\s*(.*?)\s*$/$1/;
    my @parts = split /\:/, $line;
    shift @parts; 
    $line = join ':', @parts;
    $line =~ s/^\s*(.*?)\s*$/$1/;
    return $line;
}
