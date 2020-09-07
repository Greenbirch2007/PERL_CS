use strict;
use warnings;
use DBI;

USE sysadm
    -- Last reminder: you need to type GO or ; here (if you are using
    -- an interactive client that requires this) before entering the
    -- next statement
CREATE TABLE hosts (
    name varchar(30) NOT NULL,
    ipaddr varchar(15) NOT NULL,
    aliases varchar(50) NULL,
    owner varchar(40) NULL,
    dept varchar(15) NULL,
    bldg varchar(10) NULL,
    room varchar(4) NULL,
    manuf varchar(10) NULL,
    model varchar(10) NULL
    )
for my $objMember (in $objGroup->{Members}){
    # using the access syntax we saw in tactic #3
    print $objMember->{Name},"\n";
}

use Win32::OLE qw(in);
my $objGroup =
    Win32::OLE->
        GetObject('LDAP://cn=managers,ou=management,dc=fabrikam,dc=com');
for my $objMember (in $objGroup->{Members}){
    print $objMember->{Name},"\n";
}

# Creates a new global security group -- atl-users02 -- within Active
# Directory.
use Win32::OLE;
my $objOU = Win32::OLE->
    GetObject('LDAP://OU=management,dc=fabrikam,dc=com');
my $objGroup = $objOU->Create('Group', 'cn=atl-users02');
$objGroup->Put('sAMAccountName', 'atl-users02')
$objGroup->SetInfo;

