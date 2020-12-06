use strict;
use warnings;

package Pet;
require("p_2.pl");
use CGI;
sub new{
    my $class = shift;
    my $pet = {
        "Name"=>undef,
        "Owner"=>undef,
        "Type"=>undef,
    };
    bless($pet,$class);
}

sub set_pet{
    my $self = shift;
    my ($name,$owner,$type)=@_;
    $self->{'Name'}=$name;
    $self->{'Owner'}=$owner;
    $self->{'Type'}=$type;
}

sub get_pet{
    my $self=shift;
    while(($key,$value)=each($%self)){
        print "$key::$value\n";

    }
}


