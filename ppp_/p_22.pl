use strict;
use warnings;

# 判断文件是否存在
# 创建一个文件
# 追加写入一个
#

my $file = "ss.txt";
if (-e $file) {
    #写入文件
    open FH, ">>$file";
    print FH "TETETE";
    close(FH);

    # 读取文件
    open(FH, $file);
    my @array = <FH>;
    print @array;
    close(FH);
}else{
    #创建我呢见
    print "create the file";
    open FH, ">$file";
    print FH "NEW FILE";;
    close(FH);
}