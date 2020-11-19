use strict;
use warnings;
# 句柄是一个顺序号，对于打开的文件是唯一识别依据
# 是一个特殊的文件类型
# 间接文件句柄
# 不同于其他变量的是，间接perl文件句柄没有标志性的前缀
# 经常以全部大写字母表示他们
# 输入输出句柄：SIDIN,SDOUT,STDERR


print "please input the data\n";
my $data =<STDIN>;
print "$data";

print STDOUT "enter is the mesage";


