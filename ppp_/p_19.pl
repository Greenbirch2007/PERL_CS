use strict;
use warnings;


# 写入文件
# open(FILE,">pathname") 覆盖写入文件
# open(FILE,">>pathname") 追加写入文件

# 写入具体内容
# print filehandle LSIT
# 注意，上面语句中没有都好分隔符

open(MYFILE,">>s.txt") || die("can't open file $!");
print MYFILE "abc";
close MYFILE;
open(MYFILE,"s.txt") || die("can'tn");
# while($a=<MYFILE>){
#     print $a;
# }

my @array = <MYFILE>;
print @array;
