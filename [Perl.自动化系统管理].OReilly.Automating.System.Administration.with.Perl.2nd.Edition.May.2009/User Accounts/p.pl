use strict;
use warnings;
use DBI;


my $passwd = '/etc/passwd';
open my $PW, '<', $passwd or die "Can't open $passwd:$!\n";
my ( $name, $passwd, $uid, $gid, $gcos, $dir, $shell );
while ( chomp( $_ = <$PW> ) ) {
    ( $name, $passwd, $uid, $gid, $gcos, $dir, $shell ) = split(/:/);
    <your code here>;
}
close $PW;

my ( $name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell,
    $expire );
while (
    (
        $name, $passwd, $uid, $gid, $quota,
        $comment, $gcos, $dir, $shell, $expire
    )
        = getpwent()
)
{
    <your code here>; }
endpwent();

$name = getpwent( );

my $passwd = '/etc/passwd';
open my $PW, '<', $passwd or die "Can't open $passwd:$!\n";
my @fields;
my $highestuid;
while ( chomp( $_ = <$PW> ) ) {
    @fields = split(/:/);
    $highestuid = ( $highestuid < $fields[2] ) ? $fields[2] : $highestuid;
}

close $PW;
print 'The next available UID is ' . ++$highestuid . "\n";

# Table 3-1. Login name- and UID-related variables and functions
#     Function/variable Use
#         getpwnam($name) In a scalar context, returns the UID for the specified login name; in a list context, returns all of
#     the fields of a password entry
#         getpwuid($uid) In a scalar context, returns the login name for the specified UID; in a list context, returns all of
#     the fields of a password entry
#         $> Holds the effective UID of the currently running Perl program
#     $< Holds the real UID of the currently running Perl program


# Table 3-2. Group name- and GID-related variables and functions
#     Function/variable Use
#         getgrent() In a scalar context, returns the group name; in a list context, returns the fields $name, $passwd,
#     $gid, and $members
# getgrnam($name) In a scalar context, returns the group ID; in a list context, returns the same fields mentioned for
#     getgrent()a
#     getgrgid($gid) In a scalar context, returns the group name; in a list context, returns the same fields mentioned
#     for getgrent()
# $) Holds the effective GID of the currently running Perl program
#     $( Holds the real GID of the currently running Perl program

use User::pwent;
use File::stat;
# note: this code will beat heavily upon any machine using
# automounted homedirs
while ( my $pwent = getpwent() ) {
    # make sure we stat the actual dir, even through layers of symlink
    # indirection
    my $dirinfo = stat( $pwent->dir . '/.' );
    unless ( defined $dirinfo ) {
        warn 'Unable to stat ' . $pwent->dir . ": $!\n";
        next;
    }
    warn $pwent->name
        . ''s homedir is not owned by the correct uid ('
 . $dirinfo->uid
 . ' instead '
 . $pwent->uid . ")!\n"
 if ( $dirinfo->uid != $pwent->uid );
 # world writable is fine if dir is set "sticky" (i.e., 01000);
 # see the manual page for chmod for more information
 warn $pwent->name . "'s homedir is world-writable!\n"
 if ( $dirinfo->mode & 022 and ( !$dirinfo->mode & 01000 ) );
endpwent();

$gid = (stat('filename'))[5];

        }

       use File::stat;
my $stat = stat('filename');
my $gid = $stat->gid;
        '
       ;
        };


  use File::stat;
my $gid = stat('filename')->gid
