use strict;
use warnings;
use utf8;

my $filename = $ARGV[0];
my @tags;
my $buff;
my $output = "";
my $sr;

open(DATAFILE, "<", "$filename") or die("error :$!");
while (my $line = <DATAFILE>) {
    chomp($line);
    $buff = $line;
    if ($buff =~ /tags: /) {
        $buff =~ s/tags: |\[?|\]?| ?//g;
        @tags = split /,/, $buff;
        foreach my $tag(@tags) {
            $output = $output."\n  - $tag";
        }
    }
}
close (DATAFILE);

open (DATAFILE, "< $filename");
my @indata = <DATAFILE>;
close (DATAFILE);

open(DATAFILE, "> $filename") or die("error :$!");
foreach(@indata) {
    $sr = $_;
    $sr =~ s/tags: \[[\s\S]+\]/tags: $output/;
    print DATAFILE $sr;
}
close (DATAFILE);
