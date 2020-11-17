use strict;
use warnings;



#默认情况，子程序中最后一个语句的值将用作返回值
#可以使用return 来指定返回值
#子程序中，return 之后的语句被忽略


sub add
{
    my @array = @_;
    my $item;
    my $val =0;
    foreach $item(@array)
    {
        $val = $val + $item;

    }

}

sub add_A
{
    my @array = @_;
    my $item;
    my $val =0;
    foreach $item(@array)
    {
        $val = $val + $item;

    }
    $val =$val+1;
}

sub add_B
{
    my @array = @_;
    my $item;
    my $val =0;
    foreach $item(@array)
    {
        $val = $val + $item;

    }
    return $val+2;
    printf "it's asdfa";
}
my $result= add 1,2;
print "$result \n";
my $result1= add_A 1,2;
print "$result1 \n";

my $result2= add_B 1,2;
print "$result2 \n";