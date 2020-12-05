use strict;
use warnings;


my $pid = fork or die("can't fok:$! \n");

if ($pid){
    print "i'm father\n";
    sleep;
}else{
    print "i'm child\n";
    require(IO::Socket);
    sleep;
}

sub get_mx{
    my @info= gethostbyname "\n";
    my @addr = splice(@info,4);
    my @rt;
    foreach(@addr){
        push(@rt,join(".",unpack('c4',$_)));
    }
    \@rt;
}

sub autoblush{
    my $io =$_[0];
    select((select($io),$1=1)[0]);

}

my $answer = 42;
my $pi = 3.14;
my $pet= "can";
my $sign = "I love my $pet";
my $cose = "i cose $answer";

my $thence = my $where;
my $salsa = my $model * $answer;
my $exit = system("vi $file");
my $cmd = `pwd`; #从一个明令输出的字符



my $fido = new Camel "amli";
if (not $fido){die "dead canmel";}
$fido =>saddle();
