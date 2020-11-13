use strict;
use warnings;


my @array = ("hello","world",1..99,qw/loang string/,2..16);
# foreach (@array){
#     print "$_\n";
# }

print $array[$#array];