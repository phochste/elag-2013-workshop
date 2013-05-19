#!/usr/bin/env perl

use Catmandu -all;

my $importer = 'UGent';
my $max      = 1000;

die "usage: $0 importer" unless ($importer) ;

importer($importer)->take($max)->each(sub {
   my $obj = $_[0];
   print $obj;
});
