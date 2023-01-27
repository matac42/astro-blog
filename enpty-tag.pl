use strict;
use warnings;
use utf8;

my $filename = $ARGV[0];

my $sr;


open (DATAFILE, "< $filename");
my @indata = <DATAFILE>;
close (DATAFILE);

open(DATAFILE, "> $filename") or die("error :$!");
foreach(@indata) {
    $sr = $_;
    $sr =~ s/tags: \[\]/tags:\n  - hoge/;
    print DATAFILE $sr;
}
close (DATAFILE);
