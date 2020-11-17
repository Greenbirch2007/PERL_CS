use warnings;
use strict;

# 子程序之间的变量值交互
# 通过引用来传递变量

sub sum
{
    my ($aref) =@_;
    print "aref is $aref \n";
    my $total =0;
    foreach (@$aref)# 解 引用
    {
        $total += $_;

    }
        return $total;
}

sub minum
{
    my ($aref) =@_;
    print "aref is $aref \n";
    my $total =100;
    foreach (@$aref)# 解 引用
    {
        $total -= $_;

    }
    return $total;
}

# 通过引用，精简内存占用
my @test=(1,2,3);
my $total = sum(\@test);
print "$total\n";
my $total1 = minum(\@test);
print "$total1\n";