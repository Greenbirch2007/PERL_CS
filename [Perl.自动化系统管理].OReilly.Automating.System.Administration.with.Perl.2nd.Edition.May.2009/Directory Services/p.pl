use strict;
use warnings;
use DBI;

use Net::Telnet;
my($username,$host) = split(/\@/,$ARGV[0]);
$host = $host ? $host : 'localhost';
# create a new connection
my $cn = new Net::Telnet(Host => $host,
    Port => 'finger');
# send the username down this connection
# /W for verbose information as per RFC 1288
unless ($cn->print("/W $username")){
    $cn->close;
    die 'Unable to send finger string: '.$cn->errmg."\n";
}
# grab all of the data we receive, stopping when the
# connection is dropped
my ($ret,$data);
while (defined ($ret = $cn->get)) {
    $data .= $ret;
}

# close the connection
$cn->close;
# display the data we collected
print $data;

use Net::Telnet;
my $host = $ARGV[0] ? $ARGV[0] : 'localhost';
my $cn = new Net::Telnet(Host => $host,
    Port => 'daytime'); port 13
my ($ret,$data);
while (defined ($ret = $cn->get)) {
    $data .= $ret;
}
$cn->close;
print $data;
use Net::Finger;
# finger() takes a user@host string and returns the data received
print finger($ARGV[0]);
Just to present all of the options, there’s also the fallback position of calling another
    executable (if it exists on the machine), like so:
my($username,$host) = split('@',$ARGV[0]);
$host = $host ? $host : 'localhost';
# location of finger executable
my $fingerex = ($^O eq 'MSWin32') ?
    $ENV{'SYSTEMROOT'}.'\\System32\\finger' :
    '/usr/bin/finger'; # (could also be /usr/ucb/finger)
print `$fingerex ${username}\@${host}`
    ;
use Net::Whois::Raw;
my $whois = whois('example.org');

use Net::Whois::Raw;
$Net::Whois::Raw::USE_CNAMES = 1;
my $whois = whois('example.org');

use Net::LDAP;
# create a Net::LDAP object and connect to server
my $c = Net::LDAP->new($server, port => $port) or
    die "Unable to connect to $server: $@\n";
# use no parameters to bind() for anonymous bind
# $binddn is presumably set to something like:
# "uid=bucky,ou=people,dc=example,dc=edu"
my $mesg = $c->bind($binddn, password => $passwd);
if ($mesg->code){
    die 'Unable to bind: ' . $mesg->error . "\n";
}
...
$c->unbind(); # not strictly necessary, but polite
my $searchobj = $c->search(base => $basedn,
    scope => $scope,
    filter => $filter);
die 'Bad search: ' . $searchobj->error() if $searchobj->code();


use Net::LDAP;
use Net::LDAP::LDIF;
my $server = $ARGV[0];
my $port = getservbyname('ldap','tcp') || '389';
my $basedn = 'c=US';
my $scope = 'sub';
# anonymous bind
my $c = Net::LDAP->new($server, port=>$port) or
    die "Unable to connect to $server: $@\n";
my $mesg = $c->bind();
if ($mesg->code){
    die 'Unable to bind: ' . $mesg->error . "\n";
}
my $searchobj = $c->search(base => $basedn,
    scope => $scope,
    filter => $ARGV[1]);
die "Bad search: " . $searchobj->error() if $searchobj->code();
# print the return values from search() found in our $searchobj
if ($searchobj){
    my $ldif = Net::LDAP::LDIF->new('-', 'w');
    $ldif->write_entry($searchobj->entries());
    $ldif->done();
}

my @attr = qw( sn cn );
my $searchobj = $c->search(base => $basedn,
    scope => $scope,
    filter => $ARGV[1],
    attrs => \@attr);
my $searchstruct = $searchobj->as_struct;
foreach my $dn (keys %$searchstruct){
    print $searchstruct->{$dn}{cn}[0],"\n";
}

# return a specific entry number
my $entry = $searchobj->entry($entrynum);
# acts like Perl shift() on entry list
my $entry = $searchobj->shift_entry;
# acts like Perl pop() on entry list
my $entry = $searchobj->pop_entry;
# return all of the entries as a list
my @entries = $searchobj->entries;

my $ldif = Net::LDAP::LDIF->new('-', 'w');
my $ldif = Net::LDAP::LDIF->new($filename, 'w');


use Net::LDAP;
use Net::LDAP::LDIF;
my $server = $ARGV[0];
my $LDIFfile = $ARGV[1];
my $port = getservbyname('ldap','tcp') || '389';
my $rootdn = 'cn=Manager, ou=Systems, dc=ccis, dc=hogwarts, dc=edu';
my $pw = 'secret';
# read in the LDIF file specified as the second argument on the command line;
# last parameter is "r" for open for read, "w" would be used for write
my $ldif = Net::LDAP::LDIF->new($LDIFfile,'r');
# copied from the deprecated read() command in Net::LDAP::LDIF
my ($entry,@entries);
push(@entries,$entry) while $entry = $ldif->read_entry;
my $c = Net::LDAP-> new($server, port => $port) or
    die "Unable to connect to $server: $@\n";
my $mesg = $c->bind(dn => $rootdn, password => $pw);
if ($mesg->code){
    die 'Unable to bind: ' . $mesg->error . "\n"; }
for (@entries){
    my $res = $c->add($_);
    warn 'Error in add for '. $_->dn().': ' . $res->error()."\n"
        if $res->code();


}
$c->unbind();

my $res = $c->add(
    dn => 'uid=jay, ou=systems, ou=people, dc=ccis, dc=hogwarts, dc=edu',
    attr => ['cn' => 'Jay Sekora',
        'sn' => 'Sekora',
        'mail' => 'jayguy@ccis.hogwarts.edu',
        'title' => ['Sysadmin','Part-time Lecturer'],
        'uid' => 'jayguy',
        'objectClass' => [qw(top person organizationalPerson inetOrgPerson)]]
);
die 'Error in add: ' . $res->error()."\n" if $res->code();



use Net::LDAP;
use Net::LDAP::Entry;
...
my $entry = Net::LDAP::Entry->new;
$entry->dn(
    'uid=jayguy, ou=systems, ou=people, dc=ccs, dc=hogwarts, dc=edu');
# these add statements could be collapsed into a single add()
$entry->add('cn' => 'Jay Sekora');
$entry->add('sn' => 'Sekora');
$entry->add('mail' => 'jayguy@ccis.hogwarts.edu');
$entry->add('title' => ['Sysadmin','Part-time Lecturer']);
$entry->add('uid' => 'jayguy');
$entry->add('objectClass' =>
    [qw(top person organizationalPerson inetOrgPerson)]);
# we could also call $entry->update($c) instead
# of add() if we felt like it
my $res = $c->add($entry);
die 'Error in add: ' . $res->error()."\n" if $res->code();
my $res = $c->delete($dn);
die 'Error in delete: ' . $res->error() . "\n" if $res->code();




my $res =
    $ldap->delete($dn, control =>
        {type => LDAP_CONTROL_TREE_DELETE});
# $oldDN could be something like
# "uid=johnny,ou=people,dc=example,dc=edu"
# $newRDN could be something like
# "uid=pedro"
my $res = $c->moddn($oldDN,
    newrdn => $newRDN,
    deleteoldrdn => 1);
die 'Error in rename: ' . $res->error()."\n" if $res->code();

my $oldDN = "uid=gmarx, ou=People, dc=freedonia, dc=com";
my $newRDN = "uid=cspaulding";
my $res = $c->moddn($oldDN, newrdn => $newRDN, deleteoldrdn => 1);


my $res = $c->moddn($oldDN, newrdn => $newRDN, deleteoldrdn => 0);


# $oldDN could be something like
# "uid=johnny,ou=people,dc=example,dc=edu"
# $newRDN could be something like
# "uid=pedro"
# $parenDN could be something like
# ou=boxdweller, dc=example,dc=edu
$result = $c->moddn($oldDN,
    newrdn => $newRDN,
    deleteoldrdn => 1,
    newsuperior => $parentDN);
die 'Error in rename: ' . $res->error()."\n" if $res->code();


use Net::LDAP;
my $server = $ARGV[0];
my $port = getservbyname('ldap','tcp') || '389';
my $basedn = 'dc=ccis,dc=hogwarts,dc=edu';
my $scope = 'sub';
my $rootdn = 'cn=Manager, ou=Systems, dc=ccis, dc=hogwarts, dc=edu';
my $pw = 'secret';
my $c = Net::LDAP->new($server, port => $port) or
    die "Unable to init for $server: $@\n";
my $mesg = $c->bind(dn => $rootdn, password => $pw);
if ($mesg->code){
    die 'Unable to bind: ' . $mesg->error . "\n";
}
my $searchobj = $c->search(base => $basedn, filter => '(l=Pittsburgh)',
    scope => $scope, attrs => [''],
    typesonly => 1);
die 'Error in search: '.$searchobj->error()."\n" if ($searchobj->code());
if ($searchobj){
    @entries = $searchobj->entries;
    for (@entries){# we could also use replace {'l' => 'Los Angeles'} here
        $res=$c->modify($_->dn(), # dn() yields the DN of that entry
            delete => {'l' => 'Pittsburgh'},
            add => {'l' => 'Los Angeles'});
        die 'unable to modify, errorcode #'.$res->error() if $res->code();
    }
}
$c->unbind( );


# Table 9-3. Net::LDAP entry modification methods
#     Parameter Effect
#         add => {$attrname => $attrvalue} Adds a named attribute with the given value.
#     add => {$attrname => [$attrvalue1,
#     $attrvalue2...]}
# Adds a named attribute with the specified set of values.
#     delete => {$attrname => $attrvalue} Deletes a named attribute with the specified value.
#     delete => {$attrname => []}
# delete => [$attrname1, $attrname2...]
# Deletes an attribute or set of attributes independent of their
#     value or values.
#     replace => {$attrname => $attrvalue} Like add, but replaces the current named attribute value.
#     If $attrvalue is a reference to an empty anonymous list
#     ([]), this becomes a synonym for the delete operation.

$c->modify($dn,replace => {'l' => 'Medford'},
    add => {'l' => 'Boston'},
    add => {'l' => 'Cambridge'});
$c->modify($dn, changes =>
    [ replace => ['l' => 'Medford'],
        add => ['l' => 'Boston'],
        add => ['l' => 'Cambridge']
    ]);
$c->unbind();
my $c = Net::LDAP-> new ($uri->host(), port => $uri->port()) or
    die 'Unable to init for ' . $uri->$host . ": $@\n";
my $mesg = $c->bind(dn => $rootdn, password => $pw);
if ($mesg->code){
    die 'Unable to bind: ' . $mesg->error . "\n";
}
# RFC 2251 says we must use the filter in the referral URL if one
# is returned; otherwise, we should use the original filter
#
# Note: we're using $uri->_filter() instead of just $uri->filter()
# because the latter returns a default string when no filter is
# present in the URL. We want to use our original filter in that case
# instead of the default of (objectClass=*).
$searchobj = $c->search(base => $uri->dn(),
    scope => $scope,
    filter => $uri->_filter() ? $uri->_filter() :
        $filter,
...);
}

my $uri = URI->new($reference);
 my $c = Net::LDAP-> new ($uri->host(), port => $uri->port()) or
 die 'Unable to init for ' . $uri->$host . ": $@\n";
 my $mesg = $c->bind(dn => $rootdn, password => $pw);
 if ($mesg->code){
 die 'Unable to bind: ' . $mesg->error . "\n";
 }
 my $searchobj = $c->search(base => $uri->dn(),
 scope => $scope,
 filter => $uri->_filter() ? $uri->_filter() :
 $filter,
 ...);
 # assuming we got a result, collect the entries and the references into
 # different lists
 if ($searchobj){
 my @returndata = $searchobj->entries;
 my @references = ();
 foreach my $entry (@returndata){
 if ($entry->isa('Net::LDAP::Reference'){
 # @references will contain a list of LDAP URLs
 push(@references,$entry->references());
 }
 else { push @entries, $entry );
 }
 }
 # now, chase any more references we received from that last search
 # (here's the recursion part)
 foreach my $reference (@references){
ChaseReference($reference)
}
}


use Net::LDAP;
use Net::LDAP::Control::Sort;
...
# create a control object that will ask to sort by surname
$control = Net::LDAP::Control::Sort->new(order => 'sn');
Once we have the control object, it is trivial to use it to modify a search:
# this should return back the entries in a sorted order
$searchobj= $c->search (base => $base,
 scope => $scope,
 filter => $filter,
 control => [$control]);

use Net::LDAP;
use Net::LDAP::Extension::SetPassword;
... # usual connection and bind here
$res = $c->set_password( user => $username,
 oldpassword => $oldpw,
 newpassword => $newpw, );
die 'Error in password change : ' . $res->error()."\n" if $res->code();
use Net::LDAP;
use Net::LDAP::RootDSE;
my $server = 'ldap.hogwarts.edu';
my $c = Net::LDAP->new($server) or
 die "Unable to init for $server: $@\n";
my $dse = $c->root_dse();
# let's find out which suffixes can be found on this server
print join("\n",$dse->get_value('namingContexts')),"\n";
use Net::LDAP;
use Net::LDAP::DSML;
open my $OUTPUTFILE, '>', 'output.xml'
 or die "Can't open file to write:$!\n";
my $dsml = Net::LDAP::DSML->new(output => $OUTPUTFILE,
 pretty_print => 1 )
 or die "OUTPUTFILE problem: $!\n";
... # bind and search here to @entries
$dsml->start_dsml();
foreach my $entry (@entries){
 $dsml->write_entry($entry);
}
$dsml->end_dsml();
close $OUTPUTFILE;

my $datafile = 'database';
my $recordsep = "-=-\n";
my $suffix = 'ou=data, ou=systems, dc=ccis, dc=hogwarts, dc=edu';
my $objectclass = <<"EOC";
objectclass: top
objectclass: machine
EOC
open my $DATAFILE, '<', $datafile or die "unable to open $datafile:$!\n";
print "version: 1\n"; #

while (<$DATAFILE>) {
 # print the header for each entry
 if (/name:\s*(.*)/){
 print "dn: cn=$1, $suffix\n";
 print $objectclass;
 print "cn: $1\n";
 next;
 }
 # handle the multivalued aliases attribute
 if (s/^aliases:\s*//){
 my @aliases = split;
 foreach my $name (@aliases){
 print "aliases: $name\n";
 }
 next;
 }
 # handle the end of record separator
 if ($_ eq $recordsep){
 print "\n";
 next;
 }
 # otherwise, just print the attribute as we found it
 print;
}
close $DATAFILE;
use Net::LDAP;
use Net::LDAP::Entry;
my $datafile = 'database';
my $recordsep = '-=-';
my $server = $ARGV[0];
my $port = getservbyname('ldap','tcp') || '389';
my $suffix = 'ou=data, ou=systems, dc=ccis, dc=hogwarts, dc=edu';
my $rootdn = 'cn=Manager, ou=Systems, dc=ccis, dc=hogwarts, dc=edu';
my $pw = 'secret';
my $c = Net::LDAP-> new ($server,port => $port) or
 die "Unable to init for $server: $@\n";
my $mesg = $c->bind(dn => $rootdn,password => $pw);
if ($mesg->code){
 die 'Unable to bind: ' . $mesg->error . "\n";
}
open my $DATAFILE, '<', $datafile or die "unable to open $datafile:$!\n";
while (<$DATAFILE>) {
 chomp;
 my $entry;
 my $dn;
 # at the start of a new record, create a new entry object instance
 if (/^name:\s*(.*)/){
 $dn="cn=$1, $suffix";
 $entry = Net::LDAP::Entry->new;
 $entry->add('cn',$1);
 next;
 }
 # special case for multivalued attribute
 if (s/^aliases:\s*//){
 $entry->add('aliases',[split()]);
 next;
} # if we've hit the end of the record, add it to the server
 if ($_ eq $recordsep){
 $entry->add('objectclass',['top','machine']);
 $entry->dn($dn);
 my $res = $c->add($entry);
 warn 'Error in add for ' . $entry->dn() . ':' .
 $res->error()."\n" if $res->code();
 undef $entry;
 next;
 }
 # add all of the other attributes
 $entry->add(split(':\s*')); # assume single valued attributes
}
close $DATAFILE;
$c->unbind();


use Net::LDAP;
...
my $searchobj = $c->search (base => $basedn,
 scope => 'one',
 filter => '(objectclass=machine)'
 attrs => ['cn','address','aliases']);
die 'Bad search: ' . $searchobj->error() if $searchobj->code();
if ($searchobj){
 print "#\n\# host file - GENERATED BY $0\n
 # DO NOT EDIT BY HAND!\n#\n";
 foreach my $entry ($searchobj->entries()){
 print $entry->get_value(address),"\t",
 $entry->get_value(cn)," ",
 join(' ', $entry->get_value(aliases),"\n";
}
}
$c->close();

use Net::LDAP;
...
my $searchobj = $c->search(base => $basedn,
 filter => '(manufacturer=Apple)',
 scope => 'one',
 attrs => ['cn']);
die 'Bad search: ' . $searchobj->error() if $searchobj->code();
if ($searchobj){
 foreach my $entry ($searchobj->entries){
 print $entry->get_value('cn'),"\n";
 }
}
$c->unbind();
my $hostname = hostname;
my $hostname =~ s/\..*//; # strip domain name off of host
...
my $searchobj = $c->search (base => "cn=$hostname,$suffix",
 scope => 'base',
 filter => "(owner=$user)"
 typesonly => 1);
if ($searchobj){
 print "Owner ($user) can log on to machine $hostname.\n";
}
else {
 print "$user is not the owner of this machine ($hostname).\n";
}
use Win32::OLE;
$adsobj = Win32::OLE->GetObject($ADsPath) or
 die "Unable to retrieve the object for $ADsPath\n";

use Win32::OLE;
use Win32::OLE::Enum;
eval {$enobj = Win32::OLE::Enum->new($adsobj)};
print 'object is ' . ($@ ? 'not ' : '') . "a container\n";

use Win32::OLE;
$ADsPath = 'WinNT://BEESKNEES,computer';
$adsobj = Win32::OLE->GetObject($ADsPath) or
 die "Unable to retrieve the object for $ADsPath\n";
print 'This is a '.$adsobj->{Class}."object, schema is at:\n".
 $adsobj->{Schema},"\n";

$schmobj = Win32::OLE->GetObject($adsobj->{Schema}) or
 die "Unable to retrieve the object for $ADsPath\n";
print join("\n",@{$schmobj->{MandatoryProperties}},
 @{$schmobj->{OptionalProperties}}),"\n";


use Win32::OLE qw(in);
# get the ADO object, set the provider, open the connection
$c = Win32::OLE->new('ADODB.Connection');
$c->{Provider} = 'ADsDSOObject';
$c->Open('ADSI Provider');
die Win32::OLE->LastError() if Win32::OLE->LastError();
# prepare and then execute the query
$ADsPath = 'LDAP://ldapserver/dc=example,dc=com';
$rs = $c->Execute("<$ADsPath>;(objectClass=Group);Name;SubTree");
die Win32::OLE->LastError() if Win32::OLE->LastError();


until ($rs->EOF){
 print $rs->Fields(0)->{Value},"\n";
 $rs->MoveNext;
}
$rs->Close;
$c->Close;
use Win32::OLE qw(in);
# 'WinNT://CurrentComputername,computer' - accounts local to this computer
# 'WinNT://DCname, computer' - accounts for the client's current domain
# 'WinNT://DomainName/DCName,computer' - to specify the domain
my $ADsPath= 'WinNT://DomainName/DCName,computer';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
foreach my $adsobj (in $c){
 print $adsobj->{Name},"\n" if ($adsobj->{Class} eq 'User');
}

use Win32::OLE;
my $ADsPath='WinNT://LocalMachineName,computer';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
# create and return a User object
my $u = $c->Create('user',$username);
$u->SetInfo(); # we have to create the user before we modify it
# no space between "Full" and "Name" allowed with WinNT namespace
$u->{FullName} = $fullname;
$u->SetInfo();


use Win32::OLE;
# This creates the user under the cn=Users branch of your directory tree.
# If you keep your users in a sub-OU of Users, just change the next line.
my $ADsPath= 'LDAP://ldapserver,CN=Users,dc=example,dc=com';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
# create and return a User object
my $u=$c->Create('user','cn='.$commonname);
$u->{samAccountName} = $username;
# IMPORTANT: we have to create the user in the dir before we modify it
$u->SetInfo();
# space between "Full" and "Name" required with LDAP namespace (sigh)
$u->{'Full Name'} = $fullname;
$u->SetInfo();
use Win32::OLE;
my $ADsPath= 'WinNT://DomainName/ComputerName,computer';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
# delete the User object; note that we are bound to the container object
$c->Delete('user',$username);
$c->SetInfo();


use Win32::OLE;
# or 'LDAP://cn=$username,ou=staff,ou=users,dc=example,dc=com' (for example)
my $ADsPath= 'WinNT://DomainName/ComputerName/'.$username;
my $u = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
$u->ChangePasssword($oldpassword,$newpassword);
$u->SetInfo();

use Win32::OLE;
my $ADsPath= 'WinNT://DomainName/GroupName,group';
my $g = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
# this uses the ADsPath to a specific user object
$g->Add($userADsPath);

$c->Remove($userADsPath);
use Win32::OLE;
my $ADsPath= 'WinNT://ComputerName/lanmanserver';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
my $s = $c->Create('fileshare',$sharename);
$s->{path} = 'C:\directory';
$s->{description} = 'This is a Perl created share';
$s->SetInfo();
use Win32::OLE qw(in);
my $ADsPath='WinNT://DomainName/PrintServerName,computer';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
foreach my $adsobj (in $c){
 print $adsobj->{Name}.':'.$adsobj->{Model}."\n"
 if ($adsobj->{Class} eq 'PrintQueue');
}

use Win32::OLE qw(in);
# this table comes from this section in the ADSI 2.5 SDK:
# 'Active Directory Service Interfaces 2.5->ADSI Reference->
# ADSI Interfaces->Dynamic Object Interfaces->IADsPrintQueueOperations->
# IADsPrintQueueOperations Property Methods' (phew)
my %status =
 (0x00000001 => 'PAUSED', 0x00000002 => 'PENDING_DELETION',
 0x00000003 => 'ERROR' , 0x00000004 => 'PAPER_JAM',
 0x00000005 => 'PAPER_OUT', 0x00000006 => 'MANUAL_FEED',
 0x00000007 => 'PAPER_PROBLEM', 0x00000008 => 'OFFLINE',0x00000100 => 'IO_ACTIVE', 0x00000200 => 'BUSY',
 0x00000400 => 'PRINTING', 0x00000800 => 'OUTPUT_BIN_FULL',
 0x00001000 => 'NOT_AVAILABLE', 0x00002000 => 'WAITING',
 0x00004000 => 'PROCESSING', 0x00008000 => 'INITIALIZING',
 0x00010000 => 'WARMING_UP', 0x00020000 => 'TONER_LOW',
 0x00040000 => 'NO_TONER', 0x00080000 => 'PAGE_PUNT',
 0x00100000 => 'USER_INTERVENTION', 0x00200000 => 'OUT_OF_MEMORY',
 0x00400000 => 'DOOR_OPEN', 0x00800000 => 'SERVER_UNKNOWN',
 0x01000000 => 'POWER_SAVE');
my $ADsPath = 'WinNT://PrintServerName/PrintQueueName';
my $p = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
print 'The printer status for ' . $c->{Name} . ' is ' .
 ((exists $p->{status}) ? $status{$c->{status}} : 'NOT ACTIVE') . "\n";

use Win32::OLE qw(in);
# this table comes from this section in the ADSI 2.5 SDK:
# 'Active Directory Service Interfaces 2.5->ADSI Reference->
# ADSI Interfaces->Dynamic Object Interfaces->IADsPrintJobOperations->
# IADsPrintJobOperations Property Methods' (double phew)
my %status = (0x00000001 => 'PAUSED', 0x00000002 => 'ERROR',
 0x00000004 => 'DELETING',0x00000010 => 'PRINTING',
 0x00000020 => 'OFFLINE', 0x00000040 => 'PAPEROUT',
 0x00000080 => 'PRINTED', 0x00000100 => 'DELETED');
my $ADsPath = 'WinNT://PrintServerName/PrintQueueName';
my $p = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
$jobs = $p->PrintJobs();
foreach my $job (in $jobs){
 print $job->{User} . "\t" . $job->{Description} . "\t" .
 $status{$job->{status}} . "\n";
}

use Win32::OLE qw(in);
# this table comes from this section in the ADSI 2.5 SDK:
# 'Active Directory Service Interfaces 2.5->ADSI Reference->
# ADSI Interfaces->Dynamic Object Interfaces->IADsServiceOperations->
# IADsServiceOperations Property Methods'
my %status =
 (0x00000001 => 'STOPPED', 0x00000002 => 'START_PENDING',
 0x00000003 => 'STOP_PENDING', 0x00000004 => 'RUNNING',
 0x00000005 => 'CONTINUE_PENDING',0x00000006 => 'PAUSE_PENDING',
 0x00000007 => 'PAUSED', 0x00000008 => 'ERROR');
my $ADsPath = 'WinNT://DomainName/ComputerName,computer';
my $c = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
foreach my $adsobj (in $c){
 print $adsobj->{DisplayName} . ':' . $status{$adsobj->{status}} . "\n"
 if ($adsobj->{Class} eq 'Service');
}

use Win32::OLE;
my $ADsPath = 'WinNT://DomainName/ComputerName/W32Time,service';
my $s = Win32::OLE->GetObject($ADsPath) or die "Unable to get $ADsPath\n";
$s->Start();
# may wish to check status at this point, looping until it is started
use Win32::OLE;
my $d = Win32::OLE->GetObject('WinNT://Domain');
my $c = $d->GetObject('Computer', $computername);
my $s = $c->GetObject('Service', 'W32Time');
$s->Start();
$s->Stop();
# may wish to check status at this point, sleep for a second or two
# and then loop until it is stopped