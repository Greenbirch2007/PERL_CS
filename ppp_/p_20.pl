use strict;
use warnings;


# 二进制文件的读写
# windows中，对文本文件和二进制文件进行了区分
# perl无法区分它们
# 如写入二进制书(GIF文件，EXE文件，MS Word)使用binmode

open(FH,"g.git") ||die "$!";
binmode(FH); # 使用binmode转换为二进制格式
#开始写入数据
print FH "asdf\34\safda\as";
close(FH);