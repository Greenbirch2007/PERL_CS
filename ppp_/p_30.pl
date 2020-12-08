use strict;
use warnings;

use DBI;
my $dbh = DBI->connect(qq(DBI:mysql:database=mysql;user=root;password=123456)) or die "can't connect";
my $sth =$dbh->;