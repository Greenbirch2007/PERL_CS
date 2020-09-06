use strict;
use warnings;
use DBI;

# permanently drops privs
($<,$>) = (getpwnam('nobody'),getpwnam('nobody'));

if ($user ne "root"){ <call the necessary C library routine> }

$input =~ tr/\000//d;

use File::Temp qw(tempfile);
# returns both an open filehandle and the name of that file
my ($fh, $filename) = tempfile();
print $fh "Writing to the temp file now...\n";

