use strict;
use warnings;

sub handle_10;
sub handle_20;
sub handle_30;
sub modify;

sub modify

{   my $tmp;
    my ($aref)=@_;
    if ($aref<10){
         $tmp = handle_10($aref);
    }
    elsif($aref<20){
          $tmp =handle_20($aref);
    }
    else{
          $tmp = handle_30($aref);
    }
    return $tmp

}


sub handle_10
{
    my($data)=@_;
    return $data+10;
}
sub handle_20
{
    my($data)=@_;
    return $data+20;
}

sub handle_30
{
    my($data)=@_;
    return $data+30;
}

sub remain
{
    my ($data)=@_;
    if ($data<10){
        $data = $data%7;
    }
    elsif ($data<20){
        $data= $data%16;

    }
    else{
        $data=$data%29;
    }
    return $data;


}

sub multi
{
    my ($idata)=@_;
    my $tmp1 =int($idata/10)*5*10;
    my $tmp2 = ($idata%10)*2;
    return $tmp1*$tmp2;
}

print "please type the initial value \n";
my $value =<STDIN>;
print "the initial value is:\n $value\n";
my $mid_value = modify($value);
print "$mid_value \n";
my $mid_value1 = remain($value);
print "$mid_value1 \n";
my $mid_v = multi($value);
print "$mid_v \n";