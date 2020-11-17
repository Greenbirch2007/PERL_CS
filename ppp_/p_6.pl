use strict;
use warnings;


# perl默认使用@_代表所有子程序的输入参数了你报
# &sub1(&n1,$n2,$n3);
# sub sub1
#{ my($n1,$n2,$n3)=@_;};

sub add
{
    my ($n1,$n2,$n3)=@_;
    $n1=$n1+1;
    $n2=$n2+2;
    $n3=$n3+3;
    my $val = $n1+$n2+$n3;
    return $val;

}
my $val1=1;
my $val2=2;
my $val3=3;
print "$val1,$val2,$val3 \n";
my $result= add($val1,$val2,$val3);
print $result;
