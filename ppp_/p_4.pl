use strict;
use warnings;
sub add;

my $result= add(1,2);
$result= $result +1;
print "$result \n";

my $data =$result + add(1,3);

sub add
{
   my @arr = @_;
    my $val = 0;
    my $item;
    foreach $item(@arr)
    {
        $val = $val+$item;

    }
    return $val;
}
