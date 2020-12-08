use strict;
use warnings;

use DBI;

my @drivers = DBI->available_drivers;
print join(" ," ,", @drivers"),"\n";

# dbi:$driver:$database,$prot,$username,$password"


