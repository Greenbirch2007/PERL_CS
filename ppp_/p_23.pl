use strict;
use warnings;

sub OPENFILE
{
    my ($filename)=@_;
    print "total number is";
    print (-s $filename);
    print "no contents are";
    open(FH,$filename);
    my @array =<FH>;
    print @array;
    close FH;
    return 1;

}

my $i =1;
while($i<6)
{
    my $file ="file_$i.txt";
    if (-e $file){
        print "$file \n";
        $a= OPENFILE($file);
        exit 1;

    }else{
        $i=$i+1;
    }

}
