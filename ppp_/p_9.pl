use strict;
use warnings;

#  参数为数组时，子程序只赋值给一个数组变量
# 子程序中多余的数组变量为空
# 变量和数组可以同时传递
sub add
{
    my (@a1,@a2) =@_;
    print "@a1\n";
    print "@a2 \n";
}

my @test = (1,2,3);
my @test1 = (4,5,6);
my $result = add @test,@test1;
print $result;
