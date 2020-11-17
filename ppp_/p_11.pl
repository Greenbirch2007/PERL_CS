use strict;
use warnings;

sub add
{
    print "initial value is \n";
    print "$n1,$n2 \n";
    my ($n1,$n2) = @_;
    print "received $n1,$n2 \n";
    $n1 =$n1+1;
    $n2=$n2+2;
    my $val = $n1+$n2;
    print $val;
}

# local往上看不到，只能往下看
local $n1 = 1;
my $n2 =2;
print "$n1,$n2 \n";
my $result= add $n1,$n2;
print "this is result $result \n";
print "$n1,$n2 \n";
