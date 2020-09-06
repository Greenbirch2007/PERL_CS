use strict;
use warnings;
use DBI;

use DBI;
# connect to the database named $database using the given
# username and password, and return a database handle
my $database = 'sysadm';
my $dbh = DBI->connect("DBI:mysql:$database",$username,$pw);
die "Unable to connect: $DBI::errstr\n" unless (defined $dbh);

$dbh = DBI->connect("DBI:mysql:$database",
    $username,$pw,{RaiseError => 1});
my $results=$dbh->do(q{UPDATE hosts
 SET bldg = 'Main'
 WHERE name = 'bendir'});
die "Unable to perform update:$DBI::errstr\n" unless (defined $results);
my $sth = $dbh->prepare(q{SELECT * from hosts}) or
    die 'Unable to prep our query:'.$dbh->errstr."\n";
my $rc = $sth->execute or
    die 'Unable to execute our query:'.$dbh->errstr."\n";
my @machines = qw(bendir shimmer sander);
my $sth = $dbh->prepare(q{SELECT name, ipaddr FROM hosts WHERE name = ?});
foreach my $name (@machines){
    $sth->execute($name);
    do-something-with-the-results
}

$sth->prepare(
    q{SELECT name, ipaddr FROM hosts
 WHERE (name = ? AND bldg = ? AND dept = ?)});
$sth->execute($name,$bldg,$dept);
# imagine we just finished a query like SELECT first,second,third FROM table
my $first;
my $second;
my $third;
$sth->bind_col(1, \$first); # bind first column of search result to $first
$sth->bind_col(2, \$second); # bind second column
$sth->bind_col(3, \$third); # bind third column, and so on
# or perform all of the binds in one shot:
$sth->bind_columns(\$first, \$second, \$third);

$sth->bind_columns( \(@array) ); # $array[0] gets the first column
# $array[1] get the second column...
# we can only bind to the hash elements, not to the hash itself
$sth->bind_col(1, \$hash{first} );
$sth->bind_col(2, \$hash{second} );

while ($sth->fetch){
    # do something with $first, $second and $third
    # or $array[0], $array[1],...
    # or $hash{first}, $hash{second}
}
# Name Returns Returns if no more rows
#     fetchrow_arrayref() An array reference to an anonymous array
#     with values that are the columns of the next
#         row in a result set
#     undef
#         fetchrow_array() An array with values that are the columns of
#     the next row in a result set
#     An empty list
#         fetchrow_hashref() A hash reference to an anonymous hash with
#     keys that are the column names and values
#         that are the values of the columns of the next
#             row in a result set
#     undef
#         fetchall_arrayref() A reference to an array of arrays data
#     structure
#         A reference to an empty
#             array
#                 fetchall_hashref($key_field) A reference to a hash of hashes. The top-level
#     hash is keyed by the unique values returned
#         from the $key_field column, and the
#     inner hashes are structured just like the ones
#         we get back from
#             fetchrow_hashref()



$sth = $dbh->prepare(q{SELECT name,ipaddr,dept from hosts}) or
    die 'Unable to prepare our query: '.$dbh->errstr."\n";
$sth->execute or die "Unable to execute our query: ".$dbh->errstr."\n";

while (my $aref = $sth->fetchrow_arrayref){
    print 'name: ' . $aref->[0] . "\n";
    print 'ipaddr: ' . $aref->[1] . "\n";
    print 'dept: ' . $aref->[2] . "\n";
}
while (my $href = $sth->fetchrow_hashref){
    print 'name: ' . $href->{name} . "\n";
    print 'ipaddr: ' . $href->{ipaddr}. "\n";
    print 'dept: ' . $href->{dept} . "\n";
}

$aref_aref = $sth->fetchall_arrayref;
foreach my $rowref (@$aref_aref){
    print 'name: ' . $rowref->[0] . "\n";
    print 'ipaddr: ' . $rowref->[1] . "\n";
    print 'dept: ' . $rowref->[2] . "\n";
    print '-'x30,"\n";
}

my $aref_aref = $sth->fetchall_arrayref;
my $numfields = $sth->{NUM_OF_FIELDS};
foreach my $rowref (@$aref_aref){
    for (my $i=0; $i < $numfields; $i++){
        print $sth->{NAME}->[$i].": ".$rowref->[$i]."\n";
    }
    print '-'x30,"\n";
}


# disconnects handle from database
$dbh->disconnect;
use Win32::ODBC; # we only use this to create DSNs; everything else is
# done via DBI through DBD::ODBC
# Creates a user DSN to a Microsoft SQL Server
# Note: to create a system DSN, substitute ODBC_ADD_SYS_DSN
# for ODBC_ADD_DSN - be sure to use a system DSN for
# situations where your code will be run as another user
# (e.g., in a web application)
#
if (Win32::ODBC::ConfigDSN(
    ODBC_ADD_DSN,
    'SQL Server',
    ('DSN=PerlSysAdm',
        'DESCRIPTION=DSN for PerlSysAdm',
        'SERVER=mssql.example.edu', # server name
        'ADDRESS=192.168.1.4', # server IP addr
        'DATABASE=sysadm', # our database
        'NETWORK=DBMSSOCN', # TCP/IP Socket Lib
    ))){
    print "DSN created\n";
}
else {
    die "Unable to create DSN:" . Win32::ODBC::Error( ) . "\n";
}

use DBI;
$dbh = DBI->connect('DBI:ODBC:PerlSysAdm',$username,$pw);
die "Unable to connect: $DBI::errstr\n" unless (defined $dbh);

use DBI;
print 'Enter user for connect: ';
chomp(my $user = <STDIN>);
print 'Enter passwd for $user: ';
chomp(my $pw = <STDIN>);
my $start= 'mysql'; # connect initially to this database
# connect to the start MySQL database
my $dbh = DBI->connect("DBI:mysql:$start",$user,$pw,
    { RaiseError => 1, ShowErrorStatement => 1 });
# find the databases on the server
my $sth=$dbh->prepare(q{SHOW DATABASES});
$sth->execute;
my @dbs = ( );
while (my $aref = $sth->fetchrow_arrayref) {
    push(@dbs,$aref->[0]);
}
# find the tables in each database
foreach my $db (@dbs) {
    print "---$db---\n";
    $sth=$dbh->prepare(qq{SHOW TABLES FROM $db});
    $sth->execute;
    my @tables=( );
    while (my $aref = $sth->fetchrow_arrayref) {
        push(@tables,$aref->[0]);
    }
    # find the column info for each table
    foreach my $table (@tables) {
        print "\t$table\n";
        $sth=$dbh->prepare(qq{SHOW COLUMNS FROM $table FROM $db});
        $sth->execute;
        while (my $aref = $sth->fetchrow_arrayref) {
            print "\t\t",$aref->[0],' [',$aref->[1],"]\n";
        }
    }
}
$dbh->disconnect;


use DBI;
use DBD::Oracle qw(:ora_session_modes);
print 'Enter passwd for sys: ';
chomp(my $pw = <STDIN>);
my $dbh =
    DBI->connect( 'DBI:Oracle:perlsysadm', 'sys', $pw,
        { RaiseError => 1, AutoCommit => 0, ora_session_mode => ORA_SYSDBA } );
my ( $catalog, $schema, $name, $type, $remarks ); # table_info returns this
my $sth = $dbh->table_info( undef, undef, undef, 'TABLE' );
my (@tables);
while ( ( $catalog, $schema, $name, $type, $remarks ) = $sth->fetchrow_array() )
{
    push( @tables, [ $schema, $name ] );
}
for my $table ( sort @tables ) {
    $sth = $dbh->column_info( undef, $table->[0], $table->[1], undef );
    # if you encounter an ORA-24345 error from the following fetchrow_arrayref(),
    # you can set $sth->{LongTruncOk} = 1 here as described in the DBD::Oracle doc
    print join( '.', @$table ), "\n";
    while ( my $aref = $sth->fetchrow_arrayref ) {
        # [3] = COLUMN_NAME, [5] = TYPE_NAME, [6] = COLUMN_SIZE
        print "\t\t", $aref->[3], ' [', lc $aref->[5], "(", $aref->[6], ")]\n";
    }
}
$sth->finish;
$dbh->disconnect;

use DBI;
# this assumes a privileged user called mssqldba; your
# username will probably be different
print 'Enter passwd for mssqldba: ';
chomp(my $pw = <STDIN>);
# assumes there is a predefined DSN with the name "PerlSys"
my $dbh =
    DBI->connect( 'dbi:ODBC:PerlSys', 'mssqldba', $pw, { RaiseError => 1 });
# fetch the names of all of the databases
my (@dbs) =
    map { $_->[0] }
        @{ $dbh->selectall_arrayref("select name from master.dbo.sysdatabases") };
my ( $catalog, $schema, $name, $type, $remarks ); # table_info returns this
foreach my $db (@dbs) {
    my $sth = $dbh->table_info( $db, undef, undef, 'TABLE' );
    my (@tables);
    while ( ( $catalog, $schema, $name, $type, $remarks ) =
        $sth->fetchrow_array() ) {
        push( @tables, [ $schema, $name ] );
    }
    for my $table ( sort @tables ) {
        $sth = $dbh->column_info( $db, $table->[0], $table->[1], undef );
        print join( '.', @$table ), "\n";
        while ( my $aref = $sth->fetchrow_arrayref ) {
            # [3] = COLUMN_NAME, [5] = TYPE_NAME, [6] = COLUMN_SIZE
            print "\t\t", $aref->[3], ' [', lc $aref->[5], "(", $aref->[6],
                ")]\n";
        }
    }
}
$dbh->disconnect;


use Win32::ODBC;
print 'Enter user for connect: ';
chomp(my $user = <STDIN>);
print 'Enter passwd for $user: ';
chomp(my $pw = <STDIN>);
my $dsn='sysadm'; # name of the DSN we will be using
# find the available DSNs, creating $dsn if it doesn't exist already
die 'Unable to query available DSN's'.Win32::ODBC::Error()."\n"
 unless (my %dsnavail = Win32::ODBC::DataSources());
if (!defined $dsnavail{$dsn}) {
 die 'unable to create DSN:'.Win32::ODBC::Error()."\n"
 unless (Win32::ODBC::ConfigDSN(ODBC_ADD_DSN,
 "SQL Server",
 ("DSN=$dsn",
 "DESCRIPTION=DSN for PerlSysAdm",
 "SERVER=mssql.happy.edu",
 "DATABASE=master",
 "NETWORK=DBMSSOCN", # TCP/IP Socket Lib
 )));
}
# connect to the master database via the DSN we just defined
#
# the DSN specifies DATABASE=master so we don't have to
    # pick it as a starting database explicitly
    my $dbh = new Win32::ODBC("DSN=$dsn;UID=$user;PWD=$pw;");
die "Unable to connect to DSN $dsn:".Win32::ODBC::Error()."\n"
    unless (defined $dbh);
# find the databases on the server, Sql returns an error number if it fails
if (defined $dbh->Sql(q{SELECT name from sysdatabases})){
    die 'Unable to query databases:'.Win32::ODBC::Error()."\n";
}
my @dbs = ( );
my @tables = ( );
my @cols = ( );
# ODBC requires a two-step process of fetching the data and then
# accessing it with a special call (Data)
while ($dbh->FetchRow()){
    push(@dbs, $dbh->Data("name"));
}
$dbh->DropCursor(); # this is like DBI's $sth->finish()
# find the user tables in each database
foreach my $db (@dbs) {
    if (defined $dbh->Sql("use $db")){
        die "Unable to change to database $db:" .
            Win32::ODBC::Error() . "\n";
    }
    print "---$db---\n";
    @tables=();
    if (defined $dbh->Sql(q{SELECT name from sysobjects
 WHERE type="U"})){
        die "Unable to query tables in $db:" .
            Win32::ODBC::Error() . "\n";
    }
    while ($dbh->FetchRow()) {
        push(@tables,$dbh->Data("name"));
    }
    $dbh->DropCursor();
    # find the column info for each table
    foreach $table (@tables) {
        print "\t$table\n";
        if (defined $dbh->Sql(" {call sp_columns (\'$table\')} ")){
            die "Unable to query columns in $table:" .
                Win32::ODBC::Error() . "\n";
        }
        while ($dbh->FetchRow()) {
            @cols=$dbh->Data("COLUMN_NAME","TYPE_NAME","PRECISION");
            print "\t\t",$cols[0]," [",$cols[1],"(",$cols[2],")]\n";
        }
        $dbh->DropCursor();
    }
}
$dbh->Close();
die "Unable to delete DSN:".Win32::ODBC::Error()."\n"
    unless (Win32::ODBC::ConfigDSN(ODBC_REMOVE_DSN,
        "SQL Server","DSN=$dsn"));
use DBI;
my $userquota = 10000; # K of user space given to each user
my $usertmpquota = 2000; # K of temp tablespace given to each user


my $admin = 'system';
print "Enter passwd for $admin: ";
chomp(my $pw = <STDIN>);
my $user=$ARGV[0];
# generate a *bogus* password based on username reversed
# and padded to at least 6 chars with dashes
# note: this is a very bad algorithm; better to use something
# like Crypt::GeneratePassword
my $genpass = reverse($user) . '-' x (6-length($user));
my $dbh = DBI->connect("dbi:Oracle:instance",$admin,$pw,{PrintError => 0});
die "Unable to connect: $DBI::errstr\n"
    unless (defined $dbh);
# prepare the test to see if user name exists
my $sth = $dbh->prepare(q{SELECT USERNAME FROM dba_users WHERE USERNAME = ?})
    or die 'Unable to prepare user test SQL: '.$dbh->errstr."\n";
my $res = $sth->execute(uc $user);
$sth->fetchrow_array;
die "user $user exists, quitting" if ($sth->rows > 0);
if (!defined $dbh->do (
    qq {
 CREATE USER ${LOGIN} PROFILE DEFAULT
 IDENTIFIED BY ${PASSWORD}
 DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP
 QUOTA $usertmpquota K ON TEMP QUOTA $userquota K ON USERS
 ACCOUNT UNLOCK
 })){
    die 'Unable to create database:'.$dbh->errstr."\n";
}
# grant the necessary permissions
$dbh->do("GRANT CONNECT TO ${LOGIN}") or
    die "Unable to grant connect privs to ${LOGIN}:".$dbh->errstr."\n";
# perhaps a better approach would be to explicity grant the parts of
# RESOURCE the users need rather than grant them everything and
# removing things like UNLIMITED TABLESPACE later
$dbh->do("GRANT RESOURCE TO ${LOGIN}") or
    die "Unable to grant resource privs to ${LOGIN}:".$dbh->errstr."\n";
# set the correct roles
$dbh->do("ALTER USER ${LOGIN} DEFAULT ROLE ALL") or
    die "Unable to use set correct roles for ${LOGIN}:".$dbh->errstr."\n";
# make sure the quotas are enforced
$dbh->do("REVOKE UNLIMITED TABLESPACE FROM ${LOGIN}") or
    die "Unable to revoke unlimited tablespace from ${LOGIN}:".$dbh->errstr."\n";
$dbh->disconnect;
use DBI;
$admin = 'system';
print "Enter passwd for $admin: ";
chomp(my $pw = <STDIN>);
my $user=$ARGV[0];
my $dbh = DBI->connect("dbi:Oracle:instance",$admin,$pw,{PrintError => 0});
die "Unable to connect: $DBI::errstr\n"
    if (!defined $dbh);
die "Unable to drop user ${user}:".$dbh->errstr."\n"
    if (!defined $dbh->do("DROP USER ${user} CASCADE"));
$dbh->disconnect;

use DBI;
use DBD::Oracle qw(:ora_session_modes);
use POSIX; # for ceil rounding function
use strict;
print 'Enter passwd for sys: ';
chomp( my $pw = <STDIN> );
# connect to the server
my $dbh = DBI->connect( 'DBI:Oracle:', 'sys', $pw,
    { RaiseError => 1, ShowErrorStatement => 1, AutoCommit => 0,
        ora_session_mode => ORA_SYSDBA } );
# get the quota information
my $sth = $dbh->prepare(
    q{SELECT USERNAME,TABLESPACE_NAME,BYTES,MAX_BYTES
 FROM SYS.DBA_TS_QUOTAS
 WHERE TABLESPACE_NAME = 'USERS' or TABLESPACE_NAME = 'TEMP'}
);
$sth->execute;
# bind the results of the query to these variables, later to be stored in %qdata
my ( $user, $tablespace, $bytes_used, $bytes_quota, %qdata );
$sth->bind_columns( \$user, \$tablespace, \$bytes_used, \$bytes_quota );
while ( defined $sth->fetch ) {
    $qdata{$user}->{$tablespace} = [ $bytes_used, $bytes_quota ];
}
$dbh->disconnect;
# show this information graphically
foreach my $user ( sort keys %qdata ) {
    graph(
        $user,$qdata{$user}->{'USERS'}[0], # bytes used
        $qdata{$user}->{'TEMP'}[0],
        $qdata{$user}->{'USERS'}[1], # quota size
        $qdata{$user}->{'TEMP'}[1]
    );
}
# print out nice chart given username, user and temp sizes,
# and usage info
sub graph {
    my ( $user, $user_used, $temp_used, $user_quota, $temp_quota ) = @_;
    # line for user space usage
    if ( $user_quota > 0 ) {
        print ' ' x 15 . '|'
            . 'd' x POSIX::ceil( 49 * ( $user_used / $user_quota ) )
            . ' ' x ( 49 - POSIX::ceil( 49 * ( $user_used / $user_quota ) ) )
            . '|';
        # percentage used and total M for data space
        printf( "%.2f", ( $user_used / $user_quota * 100 ) );
        print "%/" . ( $user_quota / 1024 / 1000 ) . "MB\n";
    }
    # some users do not have user quotas
    else {
        print ' ' x 15 . '|- no user quota' . ( ' ' x 34 ) . "|\n";
    }
    print $user . '-' x ( 14 - length($user) ) . '-|' . ( ' ' x 49 ) . "|\n";
    # line for temp space usage
    if ( $temp_quota > 0 ) {
        print ' ' x 15 . '|'
            . 't' x POSIX::ceil( 49 * ( $temp_used / $temp_quota ) )
            . ' ' x ( 49 - POSIX::ceil( 49 * ( $temp_used / $temp_quota ) ) )
            . '|';
        # percentage used and total M for temp space
        printf( "%.2f", ( $temp_used / $temp_quota * 100 ) );
        print "%/" . ( $temp_quota / 1024 / 1000 ) . "MB\n";
    }
    # some users do not have temp quotas
    else {
        print ' ' x 15 . '|- no temp quota' . ( ' ' x 34 ) . "|\n";
    }
    print "\n";
}