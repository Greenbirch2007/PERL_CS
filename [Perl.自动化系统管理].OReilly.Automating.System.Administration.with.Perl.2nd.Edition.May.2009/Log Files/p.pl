use strict;
use warnings;
use DBI;

open my $LOG, '<', "$logfile" or die "Unable to open $logfile:$!\n";
while(my $line = <$LOG>){
    print if $line =~ /\berror\b/i;
}
close $LOG;
my $template = 'A32 A4 A32 l s s s x2 l l l x20 s Z257 x';
my $recordsize = length( pack( $template, () ) );
open my $WTMP, '<', '/var/adm/wtmpx' or die "Unable to open wtmpx:$!\n";
my ($ut_user, $ut_id, $ut_line, $ut_pid,
    $ut_type, $ut_e_termination, $ut_e_exit, $tv_sec,
    $tv_usec, $ut_session, $ut_syslen, $ut_host,
) = ();
# read wtmpx one record at a time
my $record;

while ( read( $WTMP, $record, $recordsize ) ) {
    # unpack it using our template
    ( $ut_user, $ut_id, $ut_line, $ut_pid,
        $ut_type, $ut_e_termination, $ut_e_exit, $tv_sec,
        $tv_usec, $ut_session, $ut_syslen, $ut_host
    ) = unpack( $template, $record );
    # this makes the output more readable - the value 8 comes
    # from /usr/include/utmp.h:
    # #define DEAD_PROCESS 8
    if ( $ut_type == 8 ) {
        $ut_host = '(exit)';
    }
    print "$ut_line:$ut_user:$ut_host:" . scalar localtime($tv_sec) . "\n";
}
close $WTMP;

my $recordsize = length( pack( $template, () ) );

# location of the last command binary
my $lastexec = '/bin/last';
open my $LAST, '-|', "$lastexec" or die "Unable to run $lastexec:$!\n";
my %seen;
while(my $line = <$LAST>){
    last if $line =~ /^$/;
    my $user = (split(' ', $line))[0];
    print "$user\n" unless exists $seen{$user};
    $seen{$user}='';
}
close $LAST or die "Unable to properly close pipe:$!\n";


use Win32::EventLog;
# each event has a type - this is a translation of the common types
my %type = (1 => 'ERROR',
    2 => 'WARNING',
    4 => 'INFORMATION',
    8 => 'AUDIT_SUCCESS',
    16 => 'AUDIT_FAILURE');
# if this is set, we also retrieve the full text of every
# message on each Read()
$Win32::EventLog::GetMessageText = 1;
# open the System event log
my $log = new Win32::EventLog('System')
    or die "Unable to open system log:$^E\n";
my $event = '';
# read through it one record at a time, starting with the first entry
while ($log->Read((EVENTLOG_SEQUENTIAL_READ|EVENTLOG_FORWARDS_READ),
    1,$entry)){
    print scalar localtime($entry->{TimeGenerated}).' ';
    print $entry->{Computer}.'['.($entry->{EventID} &
        0xffff).'] ';
    print $entry->{Source}.':'.$type{$entry->{EventType}}.': ';
    print $entry->{Message};
}

use Logfile::Rotate;
my $logfile = new Logfile::Rotate(
    File => '/var/adm/log/syslog',
    Count => 5,
    Gzip => '/usr/local/bin/gzip',
    Post =>
        sub {
            open my $PID, '<', '/etc/syslog.pid' or
                die "Unable to open pid file:$!\n";
            chomp(my $pid = <$PID>);
            close $PID;
            kill 'HUP', $pid;
        }
);
# Log file locked (really) and loaded. Now let's rotate it.
$logfile->rotate();
# make sure the log file is unlocked (destroying object unlocks file)
undef $logfile;

use Getopt::Long;
my @buffer; # buffer for storing input
my $dbuffsize = 200; # default circular buffer size (in lines)
my $whatline = 0; # start line in circular buffer
my $dumpnow = 0; # flag to indicate dump requested
# parse the options
my ( $buffsize, $dumpfile );
GetOptions(
    'buffsize=i' => \$buffsize,
    'dumpfile=s' => \$dumpfile,
);
$buffsize ||= $dbuffsize;
# set up the signal handler and initialize a counter
die "USAGE: $0 [--buffsize=<lines>] --dumpfile=<filename>"
    unless ( length($dumpfile) );
$SIG{'USR1'} = \&dumpnow; # set a signal handler for dump
# and away we go! (with just a simple
# read line-store line loop)
while ( defined( $_ = <> ) ) {
    # Insert line into data structure.
    # Note: we do this first, even if we've caught a signal.
    # Better to dump an extra line than lose a line of data if
    # something goes wrong in the dumping process.
    $buffer[$whatline] = $_;
    # where should the next line go?
    $whatline = ++$whatline % $buffsize;
    # if we receive a signal, dump the current buffer
    if ($dumpnow) {
        dodump();
    }
}
# simple signal handler that just sets an exception flag,
# see perlipc(1)
sub dumpnow {
    $dumpnow = 1;
}

# dump the circular buffer out to a file, appending to file if
# it exists
sub dodump {
    my $line; # counter for line dump
    my $exists; # flag, does the output file exist already?
    my $DUMP_FH; # filehandle for dump file
    my ( @firststat, @secondstat ); # to hold output of lstats
    $dumpnow = 0; # reset the flag and signal handler
    $SIG{'USR1'} = \&dumpnow;
    if ( -e $dumpfile and ( ! -f $dumpfile or -l $dumpfile ) ) {
        warn 'ALERT: dumpfile exists and is not a plain file, '.
            "skipping dump.\n";
        return undef;
    }
    # We have to take special precautions when we're doing an
    # append. The next set of "if" statements performs a set of
    # security checks while opening the file for appending.
    if ( -e $dumpfile ) {
        $exists = 1;
        unless ( @firststat = lstat $dumpfile ) {
            warn "Unable to lstat $dumpfile, skipping dump.\n";
            return undef;
        }
        if ( $firststat[3] != 1 ) {
            warn "$dumpfile is a hard link, skipping dump.\n";
            return undef;
        }
    }
    unless ( open $DUMP_FH, '>>', $dumpfile ) {
        warn "Unable to open $dumpfile for append, skipping dump:$!.\n";
        return undef;
    }
    if ($exists) {
        unless ( @secondstat = lstat $DUMP_FH ) {
            warn "Unable to lstat opened $dumpfile, skipping dump.\n";
            return undef;
        }
        if (
            $firststat[0] != $secondstat[0] or # check dev num
                $firststat[1] != $secondstat[1] or # check inode
                $firststat[7] != $secondstat[7] # check sizes
        )
        {
            warn "SECURITY PROBLEM: lstats don't match, skipping dump.\n";
            return undef;
        }
    }
    $line = $whatline;
    print {$DUMP_FH} '-' . scalar(localtime) . ( '-' x 50 ) . "\n";do {
        # print only valid lines in case buffer was not full
        print {$DUMP_FH} $buffer[$line] if defined $buffer[$line];
        $line = ++$line % $buffsize;
    } until $line == $whatline;
    close $DUMP_FH;
    # zorch the active buffer to avoid leftovers
    # in future dumps
    $whatline = 1;
    @buffer = ();
    return 1;
}

# template for Solaris 10 wtmpx
my $template = 'A32 A4 A32 l s s s x2 l l l x20 s Z257 x';
# determine the size of a record
my $recordsize = length( pack( $template, () ) );
# open the file
open my $WTMP, '<', '/var/adm/wtmpx' or die "Unable to open wtmpx:$!\n";
my ($ut_user, $ut_id, $ut_line, $ut_pid,
    $ut_type, $ut_e_termination, $ut_e_exit, $tv_sec,
    $tv_usec, $ut_session_pad, $ut_syslen, $ut_host
)
    = ();
my $reboots = 0;
# read through it one record at a time
while ( read( $WTMP, $record, $recordsize ) ) {
    ( $ut_user, $ut_id, $ut_line, $ut_pid,
        $ut_type, $ut_e_termination, $ut_e_exit, $tv_sec,
        $tv_usec, $ut_session, $ut_syslen, $ut_host
    )
        = unpack( $template, $record );
    if ( $ut_line eq 'system boot' ) {
        print "rebooted " . scalar localtime($tv_sec) . "\n";
        $reboots++;
    }
}
close $WTMP;
print "Total reboots: $reboots\n";



use Win32::EventLog;
# this is the equivalent of $event{Length => NULL, RecordNumber =>NULL, ...}
my %event;
my @fields = qw(Length RecordNumber TimeGenerated TimeWritten EventID
    EventType Category ClosingRecordNumber Source Computer Strings Data);
@event{@fields} = (NULL) x @fields;
# partial list of event types: Type 1 is "Error",
# 2 is "Warning", etc.
my @types = ('','Error','Warning','','Information");
my $EventLog = ''; # the handle to the event Log
my $event = ''; # the event we'll be returning
my $numevents = 0; # total number of events in log
my $oldestevent = 0; # oldest event in the log
Win32::EventLog::Open($EventLog,'System','')
    or die "Could not open System log:$^E\n";


$EventLog->GetNumber($numevents);
$EventLog->GetOldest($oldestevent);
$EventLog->Read( ( EVENTLOG_SEEK_READ | EVENTLOG_FORWARDS_READ ),
    $numevents + $oldestevent, $event );
my %source;
my %types;
for ( my $i = 0; $i < $numevents; $i++ ) {
    $EventLog->Read( ( EVENTLOG_SEQUENTIAL_READ | EVENTLOG_FORWARDS_READ ),
        0, $event );
    $source{ $event->{Source} }++;
    $types{ $event->{EventType} }++;
}
# now print out the totals
print "--> Event Log Source Totals:\n";
for ( sort keys %source ) {
    print "$_: $source{$_}\n";
}
print '-' x 30, "\n";
print "--> Event Log Type Totals:\n";
for ( sort keys %types ) {
    print "$types[$_]: $types{$_}\n";
}
print '-' x 30, "\n";
print "Total number of events: $numevents\n";
my $eldump = 'c:\bin\eldump'; # path to ElDump
# output data field separated by ~ and without full message
# text (faster)
my $dumpflags = '-l system -c ~ -M';
open my $ELDUMP, '-|', "$eldump $dumpflags" or die "Unable to run $eldump:$!\n";
print 'Reading system log.';
my ( $date, $time, $source, $type, $category, $event, $user, $computer );
while ( defined ($_ = <$ELDUMP>) ) {
    ( $date, $time, $source, $type, $category, $event, $user, $computer ) =
        split('~');
    $$type{$source}++;
    print '.';
}
print "done.\n";
close $ELDUMP;
# for each type of event, print out the sources and number of
# events per source
foreach $type (qw(Error Warning Information AuditSuccess AuditFailure))
{
    print '-' x 65, "\n";
    print uc($type) . "s by source:\n";
    for ( sort keys %$type ) {
        print "$_ ($$type{$_})\n";
    }
}
print '-' x 65, "\n";


use Perl6::Form;
use User::Utmp qw(:constants);
my ( $user, $ignore ) = @ARGV;
my $format
    = '{<<<<<<<} {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<} {<<<<<<<<<<<<<<<<<<<<<<<}';
User::Utmp::utmpxname('/var/adm/wtmpx');
print "-- scanning for first host contacts from $user --\n";

my %contacts = ();# hostnames that have contacted us for specified user
while ( my $entry = User::Utmp::getutxent() ) {
    if ( $entry->{ut_user} eq $user ) {
        next if ( defined $ignore and $entry->{ut_host} =~ /$ignore/o );
        if ( $entry->{ut_type} == USER_PROCESS
            and !exists $contacts{ $entry->{ut_host} } )
        {
            $contacts{ $entry->{ut_host} } = $entry->{ut_time};
            print form $format, $entry->{ut_user}, $entry->{ut_host},
                scalar localtime( $entry->{ut_time} );
        }
    }
}
print "-- scanning for other contacts from those hosts --\n";
User::Utmp::setutxent(); # reset to start of database
while ( my $entry = User::Utmp::getutxent() ) {
    # if it is a user's process, and we're looking for this host,
    # and this is a connection from a user *other* than the
    # compromised account, then output this record
    if ( $entry->{ut_type} == USER_PROCESS
        and exists $contacts{ $entry->{ut_host} }
        and $entry->{ut_user} ne $user )
    {
        print form $format, $entry->{ut_user}, $entry->{ut_host},
            scalar localtime( $entry->{ut_time} );
    }
}
User::Utmp::endutxent(); # close database (not strictly necessary)

my $xferlog = '/var/adm/log/xferlog';
my %files = ();
open my $XFERLOG, '<', $xferlog or die "Unable to open $xferlog:$!\n";
while (defined ($line = <$XFERLOG>)){
    $files{(split(' ',$line))[8]}++;
}
close $XFERLOG;
for (sort {$files{$b} <=> $files{$a}||$a cmp $b} keys %files){
    print "$_:$files{$_}\n";
}


$files{(split)[8]}++;
for (sort {$files{$b} <=> $files{$a}||$a cmp $b} keys %files){

}

# tcpd log file location
my $tcpdlog = '/var/log/tcpd/tcpdlog';
print "-- connections found in tcpdlog --\n";
open my $TCPDLOG, '<', $tcpdlog or die "Unable to read $tcpdlog:$!\n";
my ( $connecto, $connectfrom );
while ( defined( $_ = <$TCPDLOG> ) ) {
    next if !/connect from /; # we only care about connections
    ( $connecto, $connectfrom ) = /(.+):\s+connect from\s+(.+)/;
    $connectfrom =~ s/^.+@//;
    print
        if ( exists $contacts{$connectfrom}
            and $connectfrom !~ /$ignore/o );
}
close $TCPDLOG;


use Time::Local; # for date->Unix time (secs from Epoch) conversion
use User::Utmp qw(:constants);
use Readonly; # to create read-only constants for legibility
# location of transfer log
my $xferlog = '/var/log/xferlog';
# location of wtmpx
my $wtmpx = '/var/adm/wtmpx';
# month name to number mapping
my %month = qw{Jan 0 Feb 1 Mar 2 Apr 3 May 4 Jun 5 Jul 6
    Aug 7 Sep 8 Oct 9 Nov 10 Dec 11};




# scans a wu-ftpd transfer log and populates the %transfers
# data structure
print 'Scanning $xferlog...';
open my $XFERLOG, '<', $xferlog or die "Unable to open $xferlog:$!\n";
# fields we will parse from the log
my ( $time, $rhost, $fname, $direction );
my ( $sec, $min, $hours, $mday, $mon, $year );
my $unixdate; # the converted date
my %transfers; # our data structure for holding transfer info
while (<$XFERLOG>) {
    # using an array slice to select the fields we want
    ( $mon, $mday, $time, $year, $rhost, $fname, $direction )
        = (split)[ 1, 2, 3, 4, 6, 8, 11 ];
    $fname =~ tr/ -~//cd; # remove "bad" chars
    $rhost =~ tr/ -~//cd; # remove "bad" chars
    # 'i' is "transferred in"
    $fname = ( $direction eq 'i' ? '-> ' : '<- ') . $fname;
    # convert the transfer time to Unix epoch format
    ( $hours, $min, $sec ) = split( ':', $time );
    $unixdate = timelocal( $sec, $min, $hours, $mday, $month{$mon}, $year );
    # put the data into a hash of lists of lists, i.e.:
    # $transfers{hostname} = ( [time1, $filename1],
    # [time2, $filename2],
    # ...)
    push( @{ $transfers{$rhost} }, [ $unixdate, $fname ] );
}
close $XFERLOG;
print "done.\n";


$fname =~ tr/ -~//cd; # remove "bad" chars
$rhost =~ tr/ -~//cd; # remove "bad" chars

push( @{ $transfers{$rhost} }, [ $unixdate, $fname ] );
$transfers{hostname} =
    ([time1, filename1], [time2, filename2],[time3, filename3]...);
# scans the wtmpx file and populates the @sessions structure with ftp sessions
my ( %connections, @sessions );
print "Scanning $wtmpx...\n";
User::Utmp::utmpxname($wtmpx);
while ( my $entry = User::Utmp::getutxent() ) {
    next if ( $entry->{ut_id} ne 'ftp' ); # ignore non-ftp sessions
    # "open" connection record using a hash of lists of lists (where the LoL
    # is used like a a stack stored in a hash, keyed on the device name)
    if ( $entry->{ut_user} and $entry->{ut_type} == USER_PROCESS ) {
        $entry->{ut_host} =~ tr/ -~//cd; # remove "bad" chars
        push(
            @{ $connections{ $entry->{ut_line} } },
            [ $entry->{ut_host}, $entry->{ut_time} ]
        );
    }
    # found close connection entry, try to pair with open
    if ( $entry->{ut_type} == DEAD_PROCESS ) {
        if ( !exists $connections{ $entry->{ut_line} } ) {
            warn "found lone logout on $entry->{ut_line}:"
                . scalar localtime( $entry->{ut_time} ) . "\n";
            next;
        }
        # create a list of sessions, where each session is represented by
        # a list of this form: (hostname, login, logout)
        push(
            @sessions,
            [ @{ shift @{ $connections{ $entry->{ut_line} } } },
                $entry->{ut_time}
            ]
        );
        # if there are no more connections under that tty, remove it from hash
        delete $connections{ $entry->{ut_line} }
            unless ( @{ $connections{ $entry->{ut_line} } });
    }
}
User::Utmp::endutxent();
print "done.\n";

push(
    @sessions,
    [ @{ shift @{ $connections{ $entry->{ut_line} } } },
        $entry->{ut_time}
    ]
);

push(
    @sessions,
    [ @{ shift @{ $connections{ $entry->{ut_line} } } },
        $entry->{ut_time}
    ]
);


push(
    @sessions,
    [ @{ shift @{ $connections{ $entry->{ut_line} } } },
        $entry->{ut_time}
    ]
);

push(
    @sessions,
    [ @{ shift @{ $connections{ $entry->{ut_line} } } },
        $entry->{ut_time}
    ]
);

push(
    @sessions,
    [ @{ shift @{ $connections{ $entry->{ut_line} } } },
        $entry->{ut_time}
    ]
);
delete $connections{ $entry->{ut_line} }
    unless ( @{ $connections{ $entry->{ut_line} } });

# constants to make the connection triad data structure more readable;
# the list consists of ($HOSTNAME,$LOGIN,$LOGOUT) in those positions
Readonly my $HOSTNAME => 0;
Readonly my $LOGIN => 1;
Readonly my $LOGOUT => 2;
# iterate over the session log, pairing sessions with transfers
foreach my $session (@sessions) {
    # print session times
    print scalar localtime( $session->[$LOGIN] ) . '-'
        . scalar localtime( $session->[$LOGOUT] ) . ' '
        . $session->[$HOSTNAME] . "\n ";
    # returns all of the files transferred for a given connect session
    # easy case, no transfers in this login
    if ( !exists $transfers{ $session->[$HOSTNAME] } ) {print " \t( no transfers in xferlog ) \n ";
        next;
    }
    # easy case, first transfer we have on record is after this login
    if ( $transfers{ $session->[$HOSTNAME] }->[0]->[0] > $session->[$LOGOUT] )
    {
        print " \t( no transfers in xferlog ) \n ";
        next;
    }
    my (@found) = (); # to hold the transfers we find per each session
    # find any files transferred in this session
    foreach my $transfer ( @{ $transfers{ $session->[$HOSTNAME] } } ) {
        # if transfer happened before login
        next if ( $transfer->[0] < $session->[$LOGIN] );
        # if transfer happened after logout
        next if ( $transfer->[0] > $session->[$LOGOUT] );
        # if we've already reported on this entry
        next if ( !defined $transfer->[1] );
        # record that transfer and mark as used by undef'ing the filename
        push( @found, " \t " . $transfer->[1] . " \n " );
        undef $transfer->[1];
    }
    print( scalar @found ? @found : " \t( no transfers in xferlog ) \n" )
        . " \n ";
}
use Log::Procmail;
my $procl = new Log::Procmail '/var/log/procmail';
while (my $entry = $procl->next){
    print $entry->from . ' => ' . $entry->folder . "\n";
}

use File::Tail;
use Parse::Syslog;
my $file = File::Tail->new( name => '/var/log/mail/mail.log' );
my $syslg = Parse::Syslog->new( $file );
while ( my $parsed = $syslg->next ) {
    print $parsed->{host} . ':'
        . $parsed->{program} . ':'
        . $parsed->{text} . "\n";
}

use Regexp::Log::DateRange;
# construct a regexp for May 31 8:00a to May 31 11:00a
my $regexp = Regexp::Log::DateRange->new('syslog', [ qw(5 31 8 00) ],
    [ qw(5 31 11 00) ]);
# $regexp now contains: 'may\s+31\s+(?:(?:0?[8-9]|10)\:|11\:0?0\:)'
# compile that regular expression for better performance
$regexp = qr/$regexp/i;
# now use that regexp
if ($input =~ /$regexp/) { print "$input matched\n" };

use Regexp::Log::Common;
my $rlc = Regexp::Log::Common->new( format => ':extended' );
$rlc->capture( qw(:none referer) );
my $regexp = $rlc->regexp;
# now we have a regexp that will capture the referer field
# from each line in the Extended Common Log Format
# as in
# ($referer) = $logline =~ /$regexp/


use Log::Statistics;
my $ls = Log::Statistics->new();
$ls->add_line_regexp(
    '^(\d+)\s+(.*)\s+(\w+)\s(.*)\s+(U|D)\s+(\d+)\s+(\d+)\s+(.*)');
$ls->add_field( 3, 'ip' );
$ls->add_field( 4, 'direction' );
open my $LOG, '<', 'pureftpd.log';
my $line = '';
while ( defined ($line = <$LOG>) ) {
    $ls->parse_line($line);
}
close($LOG);
print $ls->get_xml();
$ls->register_field( 'ip', 3 );
$ls->register_field( 'file', 7 );
$ls->add_group(['ip','file']);


use DB_File;
use FreezeThaw qw(freeze thaw);
use Sys::Hostname;
use Fcntl;
use strict;
# note for Solaris, if you don't want the hostnames truncated you can use
# last -a, but that requires a change to the field parsing code below
my $lastex = '/bin/last' if ( -x '/bin/last' );
$lastex = '/usr/ucb/last' if ( -x '/usr/ucb/last' );
my $userdb = 'userdata';
my $connectdb = 'connectdata';
my $thishost = &hostname;
open my $LAST, '-|', "$lastex" or die "Can't run the program $lastex:$!\n";
my ( $user, $tty, $host, $day, $mon, $date, $time, $when );
my ( %users, %connects );
while ( defined( $_ = <$LAST> ) ) {
    next if /^reboot/ or /^shutdown/ or /^ftp/ or /^account/ or /^wtmp/;
    ( $user, $tty, $host, $day, $mon, $date, $time ) = split;
    next if $tty =~ /^:0/ or $tty =~ /^console$/;
    next if ( length($host) < 4 );
    $when = $mon . ' ' . $date . ' ' . $time;
    push( @{ $users{$user} }, [ $thishost, $host, $when ] );
    push( @{ $connects{$host} }, [ $thishost, $user, $when ] );
}
close $LAST;
tie my %userdb, 'DB_File', $userdb, O_CREAT | O_RDWR, 0600, $DB_BTREE
    or die "Unable to open $userdb database for r/w:$!\n";
my $userinfo;
for my $user ( keys %users ) {
    if ( exists $userdb{$user} ) {
        ($userinfo) = thaw( $userdb{$user} );
        push( @{$userinfo}, @{ $users{$user} } );
        $userdb{$user} = freeze $userinfo;
    }
    else {
        $userdb{$user} = freeze $users{$user};
    }
}
untie %userdb;
tie my %connectdb, 'DB_File', $connectdb, O_CREAT | O_RDWR, 0600, $DB_BTREE
    or die "Unable to open $connectdb database for r/w:$!\n";
my $connectinfo;
for my $connect ( keys %connects ) {
    if ( exists $connectdb{$connect} ) {
        ($connectinfo) = thaw( $connectdb{$connect} );
        push( @{$connectinfo}, @{ $connects{$connect} } );
        $connectdb{$connect} = freeze($connectinfo);
    }
    else {
        $connectdb{$connect} = freeze( $connects{$connect} );
    }
}
untie %connectdb;

$users{username} =
    [[current host, connecting host, connect time],
        [current host, connecting host, connect time]
            ...
    ];
$connects{host} =
    [[current host, username1, connect time],
        [current host, username2, connect time],
...
];
use DB_File;
use FreezeThaw qw(freeze thaw);
use Perl6::Form;
use Fcntl;
my ( $user, $ignore ) = @ARGV;
my $userdb = 'userdata';
my $connectdb = 'connectdata';
my $hostformat = '{<<<<<<<<<<<<<<<} -> {<<<<<<<<<<<<<<<} on {<<<<<<<<<<<}';
my $userformat
    = '{<<<<<<<<}: {<<<<<<<<<<<<<<<} -> {<<<<<<<<<<<<<<<} on {<<<<<<<<<<<}';
tie my %userdb, 'DB_File', $userdb, O_RDONLY, 666, $DB_BTREE
    or die "Unable to open $userdb database for reading:$!\n";
tie my %connectdb, 'DB_File', $connectdb, O_RDONLY, 666, $DB_BTREE
    or die "Unable to open $connectdb database for reading:$!\n";
# we can exit if we've never seen a connect from this user
if ( !exists $userdb{$user} ) {
    print "No logins from that user\n";
    untie %userdb;
    untie %connectdb;
    exit;
}
my ($userinfo) = thaw( $userdb{$user} );
print "-- first host contacts from $user --\n";
my %otherhosts;
foreach my $contact ( @{$userinfo} ) {
    next if ( $ignore and $contact->[1] =~ /$ignore/o );
    print form $hostformat, $contact->[1], $contact->[0], $contact->[2];
    $otherhosts{ $contact->[1] } = 1;
}

print "-- other connects from suspect machines --\n";
my %userseen;
foreach my $host ( keys %otherhosts ) {
    next if ( $ignore and $host =~ /$ignore/o );
    next if ( !exists $connectdb{$host} );
    my ($connectinfo) = thaw( $connectdb{$host} );
    foreach my $connect ( @{$connectinfo} ) {
        next if ( $ignore and $connect->[0] =~ /$ignore/o );
        $userseen{ $connect->[1] } = 1;
    }
}

foreach my $user ( sort keys %userseen ) {
    next if ( !exists $userdb{$user} );
    ($userinfo) = thaw( $userdb{$user} );
    foreach my $contact ( @{$userinfo} ) {
        next if ( $ignore and $contact->[1] =~ /$ignore/o );
        print form $userformat, $user, $contact->[1], $contact->[0],
            $contact->[2]
            if ( exists $otherhosts{ $contact->[1] } );
    }
}

untie %userdb;
untie %connectdb;

use DBI;
use Sys::Hostname;
use strict;
my $db = 'lastdata';
my $table = 'lastinfo';
# field names we'll use in that table
my @fields = qw( username localhost otherhost whenl );
my $lastex = '/bin/last' if ( -x '/bin/last' );
$lastex = '/usr/ucb/last' if ( -x '/usr/ucb/last' );
# database-specific code (note: no username/pwd used, unusual)
# RaiseError is used so we don't have to check that each operation succeeds
my $dbh = DBI->connect(
    'dbi:SQLite:dbname=$db.sql3',
    '', '',
    { PrintError => 0,
        RaiseError => 1,
        ShowErrorStatement => 1,
    }
);



# Determine the names of the tables currently in the database.
# This code is mildly database engine-specific because of the
# need to map() to strip off the quotes DBD::SQLite returns around
# table names. Most database engines don't require that handholding,
# so $dbh->tables()'s results can be used directly.
my %dbtables;
@dbtables{ map { /\"(.*)\"/, $1 } $dbh->tables() } = ();
if ( !exists $dbtables{$table} ) {
# More database engine-specific code.

    # This creates the table with all fields of type text. With other database
    # engines, you might want to use char and varchar as appropriate.
    $dbh->do(
        "CREATE TABLE $table (" . join( ' text, ', @fields ) . ' text)' );
}
my $thishost = &hostname;
# this constructs and prepares a SQL statement with placeholders, as in:
# "INSERT INTO lastinfo(username,localhost,otherhost,whenl)
# VALUES (?, ?, ?, ?)"
my $sth = $dbh->prepare( "INSERT INTO $table ("
    . join( ', ', @fields )
    . ') VALUES ('
    . join( ', ', ('?') x @fields )
    . ')' );
open my $LAST, '-|', "$lastex" or die "Can't run the program $lastex:$!\n";
my ( $user, $tty, $host, $day, $mon, $date, $time, $whenl );
my ( %users, %connects );
while ( defined( $_ = <$LAST> ) ) {
    next if /^reboot/ or /^shutdown/ or /^ftp/ or /^account/ or /^wtmp/;
    ( $user, $tty, $host, $day, $mon, $date, $time ) = split;
    next if $tty =~ /^:0/ or $tty =~ /^console$/;
    next if ( length($host) < 4 );
    $whenl = $mon . ' ' . $date . ' ' . $time;
    # actually insert the data into the database
    $sth->execute( $user, $thishost, $host, $whenl );
}
close $LAST;
$dbh->disconnect;

open my $LOGFILE, '>>', 'logfile' or
    die "can't open logfile for append: $!\n";
print $LOGFILE 'began logfile example: ' .
    scalar localtime . "\n";
close $LOGFILE;
use Tie::LogFile;
tie( *LOG, 'Tie::LogFile', 'filename', format => '(%p) [%d] %m' );
print LOG 'message'; # (pid) [dt] message
close(LOG);


use Log::Dispatch;
my $ld = Log::Dispatch->new;




$ld->add(
    Log::Dispatch::File->new(
        name => 'to_file',
        filename => 'filename',
        min_level => 'info',max_level => 'alert',
        mode => 'append'
    )
);
$ld->add(
    Log::Dispatch::Email::MailSend->new(
        name => 'to_email',
        min_level => 'alert',
        to => [qw ( operators@example.com )],
        subject => 'log alert'
    )
);


$ld->add(
    Log::Dispatch::Syslog->new(
        name => 'to_syslog',
        min_level => 'warning',
        facility => 'local2'
    )
);

$ld->log( level => 'notice', message => 'here is a log message' );



$ld->notice( 'here is a log message' );

$ld->emergency( 'printer on fire!' );

$ld->log_to( name => 'to_syslog',
    level => 'debug',
    message => 'sneeble component is failing' );


