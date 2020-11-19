use strict;
use warnings;

sub above_average;
sub sum;
sub average;

sub above_average
{
    my($aref)=@_;
    my $average = average($aref);
    my @redata =();
    foreach (@$aref)
    {
        if ($_>$average)
        {
            push(@redata,$_);
        }
    }
    return @redata;
}

sub average
{
    my ($ref)=@_;
    my $number = @$ref;
    print "the number is $number\n";
    my $num = sum($ref);
    my $avalue=$num/$number;
    print "the average value is $avalue\n";
    return $avalue;
}

sub sum
{
    my ($aref)=@_;
    my $total = 0;
    foreach (@$aref)
    {
        $total +=$_;
    }
    return($total);
}

my @idate = (1,2,3,64);
my @above_aver = above_average(\@idate);
print "the idate hte above value:\n";
print @above_aver;