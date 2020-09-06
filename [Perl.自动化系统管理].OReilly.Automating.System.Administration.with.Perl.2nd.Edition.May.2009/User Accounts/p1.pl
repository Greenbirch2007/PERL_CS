use strict;
use warnings;
use DBI;

use User::pwent;
my $shells = '/etc/shells';
open my $SHELLS, '<', $shells or die "Unable to open $shells:$!\n";
my %okshell;
while (<$SHELLS>) {
    chomp;
    $okshell{$_}++;
}
close $SHELLS;
while ( my $pwent = getpwent() ) {
    warn $pwent->name . ' has a bad shell (' . $pwent->shell . ")!\n"
        unless ( exists $okshell{ $pwent->shell } );
}
endpwent();


use Win32API::Net qw(:User);
UserEnum( '', \my @users );
foreach my $user (@users) {
    # '3' in the following call refers to the "User info level",
    # basically a switch for how much info we want back. Here we
    # ask for one of the more verbose user info levels (3).
    UserGetInfo( '', $user, 3, \my %userinfo );
    print join( ':',
        $user, '*', $userinfo{userId},
        $userinfo{primaryGroupId},
        '',
        $userinfo{comment},
        $userinfo{fullName},
        $userinfo{homeDir},
        '' ),"\n";
}


use Win32API::Net qw(:User);
UserGetInfo( '', $user, 3, \my %userinfo );
print $userinfo{userId},"\n";


use Win32::Security::NamedObject;
my $nobj = Win32::Security::NamedObject->new('FILE',$filename);
$nobj->ownerTrustee($NewAccountName);


use Win32::Perms;
$my acl = new Win32::Perms( );
$acl->Owner($NewAccountName);
my $result = $acl->SetRecurse($dir);
$acl->Close( );

use Win32API::Net qw(:Get :Group);
my $domain = 'my-domain';
# Win32::FormatMessage converts the numeric error code to something
# we can read
GetDCName('' , $domain , my $dc)
    or die Win32::FormatMessage( Win32::GetLastError() );
GroupAddUser($dc,'Domain Admins','dnbe')
    or die Win32::FormatMessage( Win32::GetLastError() );

use Win32::OLE;
$Win32::OLE::Warn = 3; # throw verbose errors
# from ADS_GROUP_TYPE_ENUM in the Microsoft ADSI Doc
my %ADSCONSTANTS = (
    ADS_GROUP_TYPE_GLOBAL_GROUP => 0x00000002,
    ADS_GROUP_TYPE_DOMAIN_LOCAL_GROUP => 0x00000004,
    ADS_GROUP_TYPE_LOCAL_GROUP => 0x00000004,
    ADS_GROUP_TYPE_UNIVERSAL_GROUP => 0x00000008,
    ADS_GROUP_TYPE_SECURITY_ENABLED => 0x80000000
);
my $groupname = 'testgroup';
my $descript = 'Test Group';
my $group_OU = 'ou=groups,dc=windows,dc=example,dc=edu';
my $objOU = Win32::OLE->GetObject( 'LDAP://' . $group_OU );
my $objGroup = $objOU->Create( 'group', "cn=$groupname" );
$objGroup->Put( 'samAccountName', $groupname );
$objGroup->Put( 'groupType',
    $ADSCONSTANTS{ADS_GROUP_TYPE_UNIVERSAL_GROUP}
        | $ADSCONSTANTS{ADS_GROUP_TYPE_SECURITY_ENABLED} );
$objGroup->Put( 'description', $descript );
$objGroup->SetInfo;


use Win32::Lanman;
my $server = 'servername';

Win32::Lanman::LsaLookupNames( $server, ['Guest'], \my @info )
    or die "Unable to lookup SID: " . Win32::Lanman::GetLastError() . "\n";

Win32::Lanman::LsaEnumerateAccountRights( $server, ${ $info[0] }{sid},
    \my @rights )
    or die "Unable to query rights: " . Win32::Lanman::GetLastError() . "\n";
use Win32::Lanman;
my $server = 'servername';
Win32::Lanman::LsaLookupNames( $server, ['Guest'], \my @info )
    or die "Unable to lookup SID: " . Win32::Lanman::GetLastError() . "\n";
Win32::Lanman::LsaAddAccountRights( $server, ${ $info[0] }{sid},
    [&SE_SHUTDOWN_NAME] )
    or die "Unable to change rights: " . Win32::Lanman::GetLastError() . "\n";


sub CollectInformation {
    use Term::Prompt; # we'll move these use statements later
    use Crypt::PasswdMD5;
    # list of fields init'd here for demo purposes - this should
    # really be kept in a central configuration file
    my @fields = qw{login fullname id type password};
    my %record;
    foreach my $field (@fields) { # if it is a password field, encrypt it using a random salt before storing
        if ( $field eq 'password' ) {
            # believe it or not, we may regret the decision to store
            # the password in a hashed form like this; we'll talk about
            # this a little later on in this chapter
            $record{$field} = unix_md5_crypt(
                prompt( 'p', 'Please enter password:', '', '' ), undef );
        }
        else {
            $record{$field} = prompt( 'x', "Please enter $field:", '', '' );
        }
    }
    print "\n";
    $record{status} = 'to_be_created';
    $record{modified} = time();
    return \%record;
}

use DBM::Deep;
my $db = DBM::Deep->new('accounts.db');
# imagine we received a hash of hashes constructed from repeated
# invocations of CollectInformation()
foreach my $user ( keys %users ) {
    # could also be written as $db->put($login => $users{$login});
    $db->{$login} = $users{$login};
}
# then, later on in the program or in another program...
foreach my $login ( keys %{$db} ) {
    print $db->{$login}->{fullname}, "\n";
}


sub AppendAccount {
    use DBM::Deep; # will move this to another place in the script
    # receive the full path to the file
    my $filename = shift;
    # receive a reference to an anonymous record hash
    my $record = shift;
    my $db = DBM::Deep->new($filename);
    $db->{ $record->{login} } = $record;
}


AppendAccount( $addqueue, &CollectInformation );

sub CreateUnixAccount {
    my ( $account, $record ) = @_;
    ### construct the command line, using:
    # -c = comment field
    # -d = home dir
    # -g = group (assume same as user type)
    # -m = create home dir
    # -k = copy in files from this skeleton dir
    # -p = set the password
    # (could also use -G group, group, group to add to auxiliary groups)
    my @cmd = (
        $useraddex,
        '-c', $record->{fullname},
        '-d', "$homeUnixdirs/$account",
        '-g', $record->{type},
        '-m',
        '-k', $skeldir,
        '-s', $defshell,
        '-p', $record->{password},
        $account
    );
    # this gets the return code of the @cmd called, not of system() itself
    my $result = 0xff & system @cmd;
    # the return code is 0 for success, non-0 for failure, so we invert
    return ( ($result) ? 0 : 1 );
}

sub DeleteUnixAccount {
    my ( $account, $record ) = @_;
    ### construct the command line, using:
    # -r = remove the account's home directory for us
    my @cmd = ( $userdelex, '-r', $account );
    my $result = 0xff & system @cmd;
    # the return code is 0 for success, non-0 for failure, so we invert
    return ( ($result) ? 0 : 1 );
}

$result = InitUnixPasswd( $account, $record->{'password'} ) );
return 0 if (!$result);
# if it is a password field, encrypt it using a random salt before storing
if ( $field eq 'password' ) {
    # believe it or not, we may regret the decision to store
    # the password in a hashed form like this; we'll talk about
    # this a little later on in this chapter
    $record{$field} = unix_md5_crypt(
        prompt( 'p', 'Please enter password:', '', '' ), undef );
}


# this code DOES NOT WORK
open my $PW, "|passwd $account";
print $PW $newpasswd,"\n";
print $PW $newpasswd,"\n";
close $PW;


sub InitUnixPasswd {
    use Expect; # we'll move this later
    my ( $account, $passwd ) = @_;
    # return a process object
    my $pobj = Expect->spawn( $passwdex, $account );
    die "Unable to spawn $passwdex:$!\n" unless ( defined $pobj );
    # do not log to stdout (i.e., be silent)
    $pobj->log_stdout(0);
    # wait for password & password re-enter prompts,
    # answering appropriately
    $pobj->expect( 10, 'New password: ' );
    # Linux sometimes prompts before it is ready for input, so we pause
    sleep 1;
    print $pobj "$passwd\r";
    $pobj->expect( 10, 'Re-enter new password: ' );
    print $pobj "$passwd\r";
    # did it work?
    $result
        = ( defined( $pobj->expect( 10, 'successfully changed' ) ) ? 1:0 );
    # close the process object, waiting up to 15 secs for
    # the process to exit
    $pobj->soft_close();
    return $result;
}

use Win32API::Net qw(:User :LocalGroup); # for account creation
use Win32::Security::NamedObject; # for home directory perms
use Readonly;
# each user will get a "data dir" in addition to her home directory
# (the OS will create the home dir for us with the right permissions the first
# time the user logs in)
Readonly my $homeWindirs => '\\\\homeserver\\home'; # home directory root dir
Readonly my $dataWindirs => '\\\\homeserver\\data'; # data directory root dir
sub CreateWinAccount {
    my ( $account, $record ) = @_;
    my $error; # used to send back error messages in next call
# ideally the default values for this sort of add would come out of a database
    my $result = UserAdd(
        '', # create this account on the local machine
        3, # will specify USER_INFO_3 level of detail
        { acctExpires => −1, # no expiration
        authFlags => 0, # read only, no value necessary
        badPwCount => 0, # read only, no value necessary
        codePage => 0, # use default
        comment => '', # didn't ask for this from user
        countryCode => 0, # use default
        # must use these flags for normal acct
        flags => (
            Win32API::Net::UF_SCRIPT() & Win32API::Net::UF_NORMAL_ACCOUNT()
        ),
        fullName => $record->{fullname},
        homeDir => "$homeWindirs\\$account",
        homeDirDrive => 'H', # we map H: to home dir
        lastLogon => 0, # read only, no value necessary
        lastLogoff => 0, # read only, no value necessary
        logonHours => [], # no login restrictions
        logonServer => '', # read only, no value necessary
        maxStorage => −1, # no quota set
        name => $account,
        numLogons => 0, # read only, no value necessary
        parms => '', # unused
        password => $record->{password}, # plain-text passwd
        passwordAge => 0, # read only
        passwordExpired =>
            0, # don't force user to immediately change passwd
        primaryGroupId => 0x201, # magic value as instructed by doc
        priv => USER_PRIV_USER(), # normal (not admin) user
        profile => '', # don't set one at this time
        scriptPath => '', # no logon script
        unitsPerWeek => 0, # for logonHours, not used here
        usrComment => '', # didn't ask for this from user
        workstations => '', # don't specify specific wkstns
        userId => 0, # read only
},
$error
    );
return 0 unless ($result); # could return Win32::GetLastError()
# add to appropriate LOCAL group
# we assume the group name is the same as the account type
$result = LocalGroupAddMembers( '', $record->{type}, [$account] );
return 0 if (!$result);
# create data directory
    mkdir "$dataWindirs\\$account", 0777
    or (warn "Unable to make datadir:$!" && return 0);
# change the owner of the directory
my $datadir = Win32::Security::NamedObject->new( 'FILE',
    "$dataWindirs\\$account" );
eval { $datadir->ownerTrustee($account) };
if ($@) {
    warn "can't set owner: $@";
    return 0;
}
# we give the user full control of the directory and all of the
# files that will be created within it
my $dacl
    = Win32::Security::ACL->new( 'FILE',
    [ 'ALLOW', 'FULL_INHERIT', 'FULL', $account ],
);
eval { $datadir->dacl($dacl) };
if ($@) {
    warn "can't set permissions: $@";
    return 0;
}
}

use Win32API::Net qw(:User :LocalGroup); # for account deletion
use File::Path 'remove_tree'; # for recursive directory deletion
use Readonly;
sub DeleteWinAccount {
 my ( $account, $record ) = @_;
 # Remove user from LOCAL groups only. If we wanted to also
 # remove from global groups we could remove the word "Local" from
 # the two Win32API::Net calls (e.g., UserGetGroups/GroupDelUser)
 # also: UserGetGroups can take a flag to search for indirect group
 # membership (for example, if user is in group because that group
 # contains another group that has that user as a member)
 UserGetLocalGroups( '', $account, \my @groups );
 foreach my $group (@groups) {
 return 0 if (! LocalGroupDelMembers( '', $group, [$account] );
 }
 # delete this account on the local machine
 # (i.e., empty first parameter)
 unless ( UserDel( '', $account ) ) {
 warn 'Can't delete user: ' . Win32::GetLastError();
 return 0;
 }
 # delete the home and data directory and its contents
 # remove_tree puts its errors into $err (ref to array of hash references)
 # note: remove_tree() found in File::Path 2.06+; before it was rmtree
 remove_tree( "$homeWindirs\\$account", { error => \my $err } );
 if (@$err) {
 warn "can't delete $homeWindirs\\$account\n" ;
 return 0;
 }
 remove_tree( "$dataWindirs\\$account", { error => \my $err } );
 if (@$err) {
 warn "can't delete $dataWindirs\\$account\n" ;
 return 0;
 }
 else {
 return 1;
 }
}
my $result = Recycle("$homeWindirs\\$account");
my $result = Recycle("$dataWindirs\\$account");

