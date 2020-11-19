use strict;
use warnings;


# open() || die "can't open file";
# $line=<FILE>; # 读取文件

# 文件一次只读取一行
# open(MYFILE,"s.txt") || die("can'tn");
# my $line= <MYFILE>;
# print "$line";
# close MYFILE;

open(MYFILE,"s.txt") || die("can'tn");
# while($a=<MYFILE>){
#     print $a;
# }

my @array = <MYFILE>;
print @array;