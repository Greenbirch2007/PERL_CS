use strict;
use warnings;


#open(filehandle,pathname)
# 打开成功，返回一个非0值，否则返回undef
# 使用文件句柄时，应该确保操作成功再进行下一步
# die
# open() || die
#  open() or die;
# 使用“$!”得到系统所需要的最后一个操作的出错消息
# warn 不会终止程序 die就会终止程序



if (open(MYFILE,"p_1.l") ||die $!) {
    print "success~";

}else{
    print "failed!";
    exit 1;

}