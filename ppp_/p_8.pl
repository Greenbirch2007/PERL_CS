use strict;
use warnings;


sub add
{
    my @array =@_;
    my $val = 0;
    my $item;
    foreach $item(@array)
    {
        $val = $val + $item;
    }
    return $val;
}

my @test =(1,2,3);
my $result = add @test;
print $result;