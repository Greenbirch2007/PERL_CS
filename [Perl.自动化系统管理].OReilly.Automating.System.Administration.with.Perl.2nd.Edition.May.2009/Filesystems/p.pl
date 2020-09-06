use strict;
use warnings;
use DBI;


$path = '\\\\server\\sharename\\directory\\file';

use File::Spec;
my $path = File::Spec->catfile(qw{home cindy docs resume.doc});

sub subname {
    my ($self) = @_;
    
}

use Path::Class;
my $pcfile = file(qw{home cindy docs resume.doc});
my $pcdir = dir(qw{home cindy docs});

print $pcfile;
print $pcdir;

my $absfile = $pcfile->absolute; # returns the absolute path for $pcfile
my @contents = $pcfile->slurp; # slurps in the contents of that file
$pcfile->remove(); # actually deletes the file

use Path::Class;
# handing it a full path (a string) instead of components
my $pcfile = file('/home/cindy/docs/resume.doc');
print $pcfile->dir(); # note: this returns a Path::Class::Dir,
# which we're stringify-ing
print $pcfile->parent(); # same as dir(), but can make code read better
print $pcfile->basename(); # removes the directory part of the name

use Path::Class qw(foreign_file foreign_dir);
my $fpcfile = foreign_file('Win32', qw{home cindy docs resume.doc});
my $fpcdir = foreign_dir('Win32', qw{home cindy});

opendir my $DIR, '.' or die "Can't open the current directory: $!\n";

# read file/directory names in that directory into @names
my @names = readdir $DIR or die "Unable to read current dir:$!\n";
We then close the open directory handle:
closedir $DIR;
Now we can work with those names:
foreach my $name (@names) {
    next if ($name eq '.'); # skip the current directory entry
    next if ($name eq '..'); # skip the parent directory entry
    if (-d $name) { # is this a directory?
        print "found a directory: $name\n";
        next; # can skip to the next name in the for loop
    }
    if ($name eq 'core') { # is this a file named "core"?
        print "found one!\n";
    }
}

#!/usr/bin/perl -s
# Note the use of -s for switch processing. Under Windows, you will need to
# call this script explicitly with -s (i.e., perl -s script) if you do not
# have perl file associations in place.
# -s is also considered 'retro' - many programmers prefer to load
# a separate module (from the Getopt:: family) for switch parsing.
use Cwd; # module for finding the current working directory
# This subroutine takes the name of a directory and recursively scans
# down the filesystem from that point looking for files named "core"
sub ScanDirectory {
    my $workdir = shift;
    my $startdir = cwd; # keep track of where we began
    chdir $workdir or die "Unable to enter dir $workdir: $!\n";
    opendir my $DIR, '.' or die "Unable to open $workdir: $!\n";
    my @names = readdir $DIR or die "Unable to read $workdir: $!\n";
    closedir $DIR;
    foreach my $name (@names) {
        next if ( $name eq '.' );
        next if ( $name eq '..' );
        if ( -d $name ) { # is this a directory?
            ScanDirectory($name);
            next;
        }
        if ( $name eq 'core' ) { # is this a file named "core"?
            # if -r specified on command line, actually delete the file
            if ( defined $r ) {
                unlink $name or die "Unable to delete $name: $!\n";
            }
            else {
                print "found one in $workdir!\n";
            }
        }
    }
    chdir $startdir or die "Unable to change to dir $startdir: $!\n";
}
ScanDirectory('.');


single line change from:
if ($name eq 'core') {
    to:
    if ($name eq 'MSCREATE.DIR') {if ( $name eq 'core' ) { # is this a file named "core"?
        # if -r specified on command line, actually delete the file
        if ( defined $r ) {
            unlink $name or die "Unable to delete $name: $!\n";
        }
        else {
            print "found one in $workdir!\n";
        }
    }
    }
    chdir $startdir or die "Unable to change to dir $startdir: $!\n";
}
ScanDirectory('.');


use Cwd; # module for finding the current working directory
$|=1; # turn off I/O buffering
sub ScanDirectory {
    my $workdir = shift;
    my $startdir = cwd; # keep track of where we began
    chdir $workdir or die "Unable to enter dir $workdir: $!\n";
    opendir my $DIR, '.' or die "Unable to open $workdir: $!\n";
    my @names = readdir $DIR;
    closedir $DIR;
    foreach my $name (@names) {
        next if ( $name eq '.' );
        next if ( $name eq '..' );
        if ( -d $name ) { # is this a directory?
            ScanDirectory($name);
            next;
        }
        CheckFile($name)
            or print cwd. '/' . $name . "\n"; # print the bad filename
    }
    chdir $startdir or die "Unable to change to dir $startdir:$!\n";
}
sub CheckFile {
    my $name = shift;
    print STDERR 'Scanning ' . cwd . '/' . $name . "\n";
    # attempt to read the directory entry for this file
    my @stat = stat($name);
    if ( !$stat[4] && !$stat[5] && !$stat[6] && !$stat[7] && !$stat[8] ) {
        return 0;
    }
    # attempt to open this file
    open my $T, '<', "$name" or return 0;
    # read the file one byte at a time, throw away actual data in $discard
    for ( my $i = 0; $i < $stat[7]; $i++ ) {
        my $r = sysread( $T, $discard, 1 );
        if ( $r != 1 ) {
            close $T;
            return 0;
        }
    }
    close $T;
    return 1;
}
ScanDirectory('.');

# Walking the Filesystem Using the File::Find Module

#! /usr/bin/perl -w
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
    if 0; #$running_under_some_shell
use strict;
use File::Find ();
# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.
# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name = *File::Find::name;
*dir = *File::Find::dir;
*prune = *File::Find::prune;
sub wanted;
# traverse desired filesystems
File::Find::find({wanted => \&wanted}, '/home');
exit;
sub wanted {
    /^beesknees\z/s &&
        print("$name\n");
}

use strict;
use File::Find ();
use vars qw/*name *dir *prune/;
*name = *File::Find::name;
*dir = *File::Find::dir;
*prune = *File::Find::prune;
File::Find::find({wanted => \&wanted}, '.');
sub wanted {
    /^core\z/s &&
        print("$name\n");
}
my $r;
sub wanted {
    /^core$/ && print("$name\n") && defined $r && unlink($name);
}


my $r;
sub wanted {
    /^core$/ && -s $name && print("$name\n") &&
        defined $r && unlink($name);
}

*name = *File::Find::name;
*dir = *File::Find::dir;
*prune = *File::Find::prune;

# Table 2-2. File::Find variables
#     Variable name Meaning
#         $_ Current filename
#     $File::Find::dir Current directory name
#     $File::Find::name Full path of current filename (e.g., "$File::Find::dir/$_")


use File::Find ();
use Win32::File;
File::Find::find( { wanted => \&wanted }, '\\' );
my $attr; # defined globably instead of in wanted() to avoid repeatedly
# defining a local copy of $attr every time it is called
sub wanted {
    -f $_
        && ( Win32::File::GetAttributes( $_, $attr ) )
        && ( $attr & HIDDEN )
        && print "$File::Find::name\n";
}

use File::Find;
use Win32::FileSecurity;
# determine the DACL mask for Full Access
my $fullmask = Win32::FileSecurity::MakeMask(qw(FULL));
File::Find::find( { wanted => \&wanted }, '\\' );
sub wanted {
    # this time we're happy to make sure we get a fresh %users each time
    my %users;
    ( -f $_ )
        && eval {Win32::FileSecurity::Get( $_, \%users )}
        && ( defined $users{'Everyone'} )
        && ( $users{'Everyone'} == $fullmask )
        && print "$File::Find::name\n";
}

use File::Find;
my $max;
my $maxlength;
File::Find::find( { wanted => \&wanted }, '.' );
print "max:$max\n";
sub wanted {
    return unless -f $_;
    if ( length($_) > $maxlength ) {
        $max = $File::Find::name;
        $maxlength = length($_);
    }
    if ( length($File::Find::name) > 200 ) { print $File::Find::name, "\n"; }
}
#When Not to Use the File::Find Module
# When is the File::Find method we’ve been discussing not appropriate? Three situations come to mind:
# 1. If the filesystem you are traversing does not follow the normal semantics, you can’t
# use it. For instance, in the bouncing laptop scenario described at the beginning of
#     the chapter, the Linux NTFS filesystem driver I was using had the strange property
#         of not listing “.” or “..” in empty directories. This broke File::Find badly.
#     2. If you need to change the names of the directories in the filesystem you are traversing while you are traversing it, File::Find gets very unhappy and behaves in
#     an unpredictable way.
#         3. If you need to walk a nonnative filesystem mounted on your machine (for example,
#     an NFS mount of a Unix filesystem on a Windows machine), File::Find will
#     attempt to use the native operating system’s filesystem semantics.
# It is unlikely that you’ll encounter these situations, but if you do, refer to the first
#     filesystem-walking section of this chapter for information on how to traverse
#     filesystems by hand.


use File::Find;
use File::Basename;
use strict;
# hash of fname extensions and the extensions they can be derived from
my %derivations = (
    '.dvi' => '.tex',
    '.aux' => '.tex',
    '.toc' => '.tex',
    '.o' => '.c',
);
my %types = (
    'emacs' => 'emacs backup files',
    'tex' => 'files that can be recreated by running La/TeX',
    'doto' => 'files that can be recreated by recompiling source',
);
my $targets; # we'll collect the files we find into this hash of hashes
my %baseseen; # for caching base files


my $homedir = ( getpwuid($<) )[7]; # find the user's home directory
chdir($homedir)
    or die "Unable to change to your homedir $homedir:$!\n";
$| = 1; # print to STDOUT in an unbuffered way
print 'Scanning';
find( \&wanted, '.' );
print "done.\n";

sub wanted {
    # print a dot for every dir so the user knows we're doing something
    print '.' if ( -d $_ );
    # we're only checking files
    return unless -f $_;
    # check for core files
    $_ eq 'core'
        && ( $targets->{core}{$File::Find::name} = ( stat(_) )[7] )
        && return;
    # check for emacs backup and autosave files
    ( /^#.*#$/ || /~$/ )
        && ( $targets->{emacs}{$File::Find::name} = ( stat(_) )[7] )
        && return;
    # check for derivable tex files
    ( /\.dvi$/ || /\.aux$/ || /\.toc$/ )
        && BaseFileExists($File::Find::name)
        && ( $targets->{tex}{$File::Find::name} = ( stat(_) )[7] )
        && return;
    # check for derivable .o files
    /\.o$/
        && BaseFileExists($File::Find::name)
        && ( $targets->{doto}{$File::Find::name} = ( stat(_) )[7] )
        && return;
}

sub BaseFileExists {
    my ( $name, $path, $suffix ) = File::Basename::fileparse( $_[0], '\..*' );
    # if we don't know how to derive this type of file
    return 0 unless ( defined $derivations{$suffix} );
    # easy, we've seen the base file before
    return 1
        if ( defined $baseseen{ $path . $name . $derivations{$suffix} } );
    # if file (or file to which link points) exists and has non-zero size
    # return success once we have cached the information
    return 1
        if ( -s $name . $derivations{$suffix}
            && ++$baseseen{ $path . $name . $derivations{$suffix} } );
}


print 'Found a core file taking up '
    . BytesToMeg( $targets->{core}{$path} )
    . 'MB in '
    . File::Basename::dirname($path) . ".\n";
}
foreach my $kind ( sort keys %types ) {
 ReportDerivFiles( $kind, $types{$kind} );
}
sub ReportDerivFiles {
 my $kind = shift; # kind of file we're reporting on
 my $message = shift; # a message so we can describe it
 my $tempsize = 0;
 return unless exists $targets->{$kind};
 print "\nThe following are most likely $message:\n";
 foreach my $path ( keys %{ $targets->{$kind} } ) {
 $tempsize += $targets->{$kind}{$path};
 $path =~ s|^\./|~/|; # change the path for prettier output
 print "$path ($targets->{$kind}{$path} bytes)\n";
 }
 print 'These files take up ' . BytesToMeg($tempsize) . "MB total.\n\n";
}
sub BytesToMeg { # convert bytes to X.XXMB
 return sprintf( "%.2f", ( $_[0] / 1024000 ) );
}

# Walking the Filesystem Using the File::Find::Rule Module

use File::Find::Rule;
my @files_or_dirs = File::Find::Rule->in('.');

my @files = File::Find::Rule->file()->in('.');
my @perl_files = File::Find::Rule->file()->name('*.pl')->in('.');
my @perl_files = find( file => name => '*.pl', in => '.' );

my $ffr = File::Find::Rule->file()->name('*.pl')->start('.');

while ( my $perl_file = $ffr->match ){
# do something interesting with $perl_file
}

use File::Find::Rule;
@interesting =
 File::Find::Rule
 ->file()
 ->executable()
 ->size('<1M')
 ->uid( 6588, 6070 )
 ->name('*.pl')
 ->in('.');

#!/usr/bin/perl
use Getopt::Std;
use File::Temp qw(tempfile);
my $edquota = '/usr/sbin/edquota'; # edquota path
my $autoedq = '/bin/editquota.pl'; # full path for this script
my %opts;
# are we the first or second invocation?
# if there is more than one argument, we're the first invocation
# so parse the arguments and call the edquota binary
if ( @ARGV != 1 ) {
 # colon (:) means this flag takes an argument
 # $opts{u} = user ID, $opts{f} = filesystem name,
 # $opts{s} = soft quota amount, $opts{h} = hard quota amount
 getopt( 'u:f:s:h:', \%opts );
 die "USAGE: $0 -u <uid> -f <fsystem> -s <softq> -h <hardq>\n"
 unless ( exists $opts{u}
 and exists $opts{f}
 and exists $opts{s}
 and exists $opts{h} );
 CallEdquota();
}
# else - we're the second invocation and will have to perform the edits
else {
EdQuota();

sub CallEdquota {
 $ENV{'EDITOR'} = $autoedq; # set the EDITOR variable to point to us
 open my $EPROCESS, '|-', "$edquota $opts{u}"
 or die "Unable to start $edquota: $!\n";
 # send the changes line to the second script invocation
 print $EPROCESS "$opts{f}|$opts{s}|$opts{h}\n";
close $EPROCESS;
}


sub EdQuota {
 my $tfile = $ARGV[0]; # get the name of edquota's temp file
open my $TEMPFILE, '<', $tfile
 or die "Unable to open temp file $tfile:$!\n";
 my ( $SCRATCH_FH, $scratch_filename ) = tempfile()
 or die "Unable to open scratch file: $!\n";
 # receive line of input from first invocation and lop off the newline
 chomp( my $change = <STDIN> );
 my ( $fs, $soft, $hard ) = split( /\|/, $change ); # parse the communique
 # Read in a line from the temp file. If it contains the
 # filesystem we wish to modify, change its values. Write the input
 # line (possibly changed) to the scratch file.
 while ( my $quotaline = <$TEMPFILE> ) {
 if ( $quotaline =~ /^fs \Q$fs\E\s+/ ) {
 $quotaline
 =~ s/(soft\s*=\s*)\d+(, hard\s*=\s*)\d+/$1$soft$2$hard/;
 }
 print $SCRATCH_FH $quotaline;
 }
 close $TEMPFILE;
 close $SCRATCH_FH;
 # overwrite the temp file with our modified scratch file so
 # edquota will get the changes
 rename( $scratch_filename, $tfile )
 or die "Unable to rename $scratch_filename to $tfile: $!\n";
}


use Getopt::Std;
use Quota;
my %opts;
getopt( 'u:f:s:h:', \%opts );
die "USAGE: $0 -u <uid> -f <fsystem> -s <softq> -h <hardq>\n"
 unless ( exists $opts{u}
 and exists $opts{f}
 and exists $opts{s}
 and exists $opts{h} );
my $dev = Quota::getqcarg( $opts{f} )
 or die "Unable to translate path $opts{f}: $!\n";
my ( $curblock, $soft, $hard, $btimeo, $curinode, $isoft, $ihard, $itimeo )
 = Quota::query( $dev, $opts{u} )
 or die "Unable to query quota for $opts{u}: $!\n";
Quota::setqlim( $dev, $opts{u}, $opts{s}, $opts{h}, $isoft, $ihard ) == undef
 or die 'Unable to set quota: ' . Quota::strerr() . "\n";



use Win32::OLE;
my $wobj = Win32::OLE->GetObject('winmgmts:\\\\.\\root\\cimv2');
# next line requires elevated privileges to work under Vista
my $quota
 = $wobj->Get(
 'Win32_DiskQuota.QuotaVolume=\'Win32_LogicalDisk.DeviceID="c:"\','
 . 'User=\'Win32_Account.Domain="WINDOWS",Name="dnb"\'' );
$quota->{Limit} = 1024 * 1024 * 100; # 100MB
$quota->{WarningLimit} = 1024 * 1024 * 80; # 80MB
$quota->Put_;

use Win32::DriveInfo;
my ($sectors, $bytessect, $freeclust, $clustnum,
 $userfree, $total, $totalfree
) = Win32::DriveInfo::DriveSpace('c');
# if quotas are in effect we can show the amount free from
# our user's perspective by printing $userfree instead
print "$totalfree bytes of $total bytes free\n";

use Filesys::Df;
my $fobj = df('/');
print $fobj->{su_bavail}* 1024 . ' bytes of ' .
 $fobj->{su_blocks}* 1024 . " bytes free\n";


# Module Information for This Chapter
# Name CPAN ID Version
# MacOSX::File DANKOGA 0.71
# File::Find (ships with Perl) 1.12
# File::Spec (ships with Perl as part of the PathTools module) KWILLIAMS 3.2701
# Path::Class KWILLIAMS 0.16
# Cwd (ships with Perl as part of the PathTools module) KWILLIAMS 3.2701
# Win32::File (ships with ActiveState Perl) JDB 0.06
# Win32::FileSecurity (ships with ActiveState Perl) JDB 1.06
# File::Basename (ships with Perl) 2.76
# File::Find::Rule RCLAMP 0.30
# Getopt::Std (ships with Perl)
# File::Temp (ships with Perl) TJENNESS 0.20
# Quota TOMZO 1.6.2
# Win32::OLE (ships with ActiveState Perl) JDB 0.1709
# Win32::DriveInfo MBLAZ 0.06
# Filesys::Df IGUTHRIE 0.92
# Filesys::DfPortable IGUTHRIE 0.85