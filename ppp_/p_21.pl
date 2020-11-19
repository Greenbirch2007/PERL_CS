use strict;
use warnings;


#测试文件的必要性
# 实际的读写速度比较慢
# 读写时容易产生错误
# perl提供了文件测试运算符
# -r （可读测试） ,-r "file" ,可以读取"file",则返回真
# -w （可写测试）, -w $a, $a中包含的文件明是可以写入的文件名，则返回真
# -e(存在测试),-e "myfile",'myfile'存在，则返回值真
# -z (存在且为空),-z'data','data'存在，但是它是空的，则返回真
# -s(存在且返回大小),-s 'data','data'存在，则返回'data'的大小


# -f (普通文件测试)，-f "novel.txt",“novel.txt”是个普通文件，则返回真
# -d (目录测试)，-d "/tmp",“/tmp”是个目录，则返回真
# -T (文本文件测试),-T 'unknow',"unknown"显示为一个文本文件，则返回真
# -B (二进制文件测试),-B "unknow",  "unknown"显示为一个二进制文件，则返回真
# -M(文件被修改后的时间),-M "foo",返回程序启动运行以来"foo"文件被修改后经过的时间

my $myfile ="s.txt";
if (-z $myfile){
    print "we can visit it\n";
}else{
    print "failed";
}
print -M $myfile;