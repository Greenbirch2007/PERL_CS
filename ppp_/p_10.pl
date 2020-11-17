use strict;
use warnings;

sub add
{
    my ($val,@array)=@_;
    print "$val \n";
    print "@array \n";
    my $date= $val;
    my $item;
    foreach $item(@array)
    {
        $date = $date+$item;
    }
    return $date;
}

my $test=1;
my @test =(3,6,8);
my $result = add $test,@test;
print $result;
