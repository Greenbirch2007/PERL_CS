use strict;
use warnings;
use DBI;

use Text::CSV_XS;
my $tasklist = "$ENV{'SystemRoot'}\\SYSTEM32\\TASKLIST.EXE";
my $csv = Text::CSV_XS->new();
# /v = verbose (includes User Name), /FO CSV = CSV format, /NH - no header
open my $TASKPIPE, '-|', "$tasklist /v /FO CSV /NH"
    or die "Can't run $tasklist: $!\n";
my @columns;
while (<$TASKPIPE>) {
    next if /^$/; # skip blank lines in the input
    $csv->parse($_) or die "Could not parse this line: $_\n";
    @columns = ( $csv->fields() )[ 0, 1, 6 ]; # grab name, PID, and User Name
    print join( ':', @columns ), "\n";
}
close $TASKPIPE;

use Win32::Process::Info;
use strict;
# the user running this script must be able to use DEBUG level privs
my $pi = Win32::Process::Info->new( { assert_debug_priv => 1 } );

my @processinfo = $pi->GetProcInfo();
use Win32::Process::Info;
my $pi = Win32::Process::Info->new( { assert_debug_priv => 1 } );
my @processinfo = $pi->GetProcInfo();
foreach my $process (@processinfo) {
    print join( ':',
        $process->{'Name'}, $process->{'ProcessId'},
        $process->{'Owner'} ),
        "\n";
}

use Win32::Process::Info;
use Data::Dumper;
my $pi = Win32::Process::Info->new( { assert_debug_priv => 1 } );
# PID 884 picked for this example because it has a small number of children
my %sp = $pi->Subprocesses(884);
print Dumper (\%sp);

$VAR1 = {
    '3320' => [],
    '884' => [
        3320
    ]
};
use Win32::Setupsup;
use Perl6::Form;
my $machine = ''; # query the list on the current machine
# define the output format for Perl6::Form
my $format = '{<<<<<<<} {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}';
my ( @processlist, @threadlist );
Win32::Setupsup::GetProcessList( $machine, \@processlist, \@threadlist )
    or die 'process list error: ' . Win32::Setupsup::GetLastError() . "\n";
pop(@processlist); # remove the bogus entry always appended to the list
print <<'EOH';
Process ID Process Name
========== ===============================
EOH
foreach my $processlist (@processlist) {
    print form $format, $processlist->{pid}, $processlist->{name};
}

KillProcess($pid, $exitvalue, $systemprocessflag) or
    die 'Unable to kill process: ' . Win32::Setupsup::GetLastError( ) . "\n";

Win32::Setupsup::EnumWindows(\@windowlist) or
    die 'process list error: ' . Win32::Setupsup::GetLastError( ) . "\n";

use Win32::Setupsup;
my @windowlist;
Win32::Setupsup::EnumWindows( \@windowlist )
    or die 'process list error: ' . Win32::Setupsup::GetLastError() . "\n";
my $text;
foreach my $whandle (@windowlist) {
    if ( Win32::Setupsup::GetWindowText( $whandle, \$text ) ) {
        print "$whandle: $text", "\n";


    }
    else {
        warn "Can't get text for $whandle"
            . Win32::Setupsup::GetLastError() . "\n";
    }
}

use Win32::Setupsup;
my @windowlist;
# get the list of windows
Win32::Setupsup::EnumWindows( \@windowlist )
    or die 'process list error: ' . Win32::Setupsup::GetLastError() . "\n";
# turn window handle list into a hash
# NOTE: this conversion populates the hash with plain numbers and
# not actual window handles as keys. Some functions, like
# GetWindowProperties (which we'll see in a moment), can't use these
# converted numbers. Caveat implementor.
my %windowlist;
for (@windowlist) { $windowlist{$_}++; }
# check each window for children
my %children;
foreach my $whandle (@windowlist) {
    my @children;
    if ( Win32::Setupsup::EnumChildWindows( $whandle, \@children ) ) {
        # keep a sorted list of children for each window
        $children{$whandle} = [ sort { $a <=> $b } @children ];
        # remove all children from the hash; we won't directly
        # iterate over them
        foreach my $child (@children) {
            delete $windowlist{$child};
        }
    }
}
# iterate through the list of windows and recursively print
# each window handle and its children (if any)
foreach my $window ( sort { $a <=> $b } keys %windowlist ) {
    PrintFamily( $window, 0, %children );
}
# print a given window handle number and its children (recursively)
sub PrintFamily {
    # starting window - how deep in a tree are we?
    my ( $startwindow, $level, %children ) = @_;
    # print the window handle number at the appropriate indentation
    print( ( ' ' x $level ) . "$startwindow\n" );
    return unless ( exists $children{$startwindow} ); # no children, done
    # otherwise, we have to recurse for each child
    $level++;
    foreach my $childwindow ( @{ $children{$startwindow} } ) {
        PrintFamily( $childwindow, $level, %children );
    }
}

use Win32::Setupsup;
# Convert window ID into a form that GetWindowProperties can cope with.
# Note: 'U' is a pack template that is only available in Perl 5.6+ releases.
my $whandle = unpack 'U', pack 'U', $ARGV[0];
my %info;
Win32::Setupsup::GetWindowProperties( $whandle, ['rect'], \%info );
print "\t" . $info{rect}{top} . "\n";
print $info{rect}{left} . ' -' . $whandle . '- ' . $info{rect}{right} . "\n";
print "\t" . $info{rect}{bottom} . "\n";
Win32::Setupsup::SetWindowText($handle,$text);


use Win32::Setupsup;
my %info;
$info{rect}{left} = 0;
$info{rect}{right} = 600;
$info{rect}{top} = 10;
$info{rect}{bottom} = 500;
my $whandle = unpack 'U', pack 'U', $ARGV[0];
Win32::Setupsup::SetWindowProperties( $whandle, \%info );

use Win32::Setupsup;
my $texttosend = "\\DN\\Low in the gums";
my $whandle = unpack 'U', pack 'U', $ARGV[0];
Win32::Setupsup::SendKeys( $whandle, $texttosend, 0 ,0 );

use Win32::GuiTest qw(:ALL);
system("start notepad.exe");
sleep 1;
MenuSelect("F&ormat|&Font");
sleep(1);
my $fontdlg = GetForegroundWindow();
my ($combo) = FindWindowLike( $fontdlg, '', 'ComboBox', 0x470 );
for ( GetComboContents($combo) ) {
    print "'$_'" . "\n";
}
SendKeys("{ESC}%{F4}");

use Win32::GuiTest qw(:ALL);
system 'start notepad';
sleep 1;
my $menu = GetMenu( GetForegroundWindow() );
menu_parse($menu);
SendKeys("{ESC}%{F4}");
sub menu_parse {
    my ( $menu, $depth ) = @_;
    $depth ||= 0;
    foreach my $i ( 0 .. GetMenuItemCount($menu) - 1 ) {
        my %h = GetMenuItemInfo( $menu, $i );
        print ' ' x $depth;
        print "$i ";
        print $h{text} if $h{type} and $h{type} eq 'string';
        print "------" if $h{type} and $h{type} eq 'separator';
        print "UNKNOWN" if not $h{type};
        print "\n";
        my $submenu = GetSubMenu( $menu, $i );
        if ($submenu) {
            menu_parse( $submenu, $depth + 1 );
        }
    }
}

use Win32::OLE('in');
my $server = ''; # connect to local machine
# get an SWbemLocator object
my $lobj = Win32::OLE->new('WbemScripting.SWbemLocator') or
    die "can't create locator object: ".Win32::OLE->LastError()."\n";
# set the impersonation level to "impersonate"
$lobj->{Security_}->{impersonationlevel} = 3;
# use it to get an SWbemServices object
my $sobj = $lobj->ConnectServer($server, 'root\cimv2') or
    die "can't create server object: ".Win32::OLE->LastError()."\n";
# get the schema object
my $procschm = $sobj->Get('Win32_Process');

use Win32::OLE('in');
my $procschm = Win32::OLE->GetObject(
    'winmgmts:{impersonationLevel=impersonate}!Win32_Process')
    or die "can't create server object: ".Win32::OLE->LastError()."\n";

use Win32::OLE('in');
# connect to namespace, set the impersonation level, and retrieve the
# Win32_process object just by using a display name
my $procschm = Win32::OLE->GetObject(
    'winmgmts:{impersonationLevel=impersonate}!Win32_Process')
    or die "can't create server object: ".Win32::OLE->LastError()."\n";
print "--- Properties ---\n";
print join("\n",map {$_->{Name}}(in $procschm->{Properties_}));
print "\n--- Methods ---\n";
print join("\n",map {$_->{Name}}(in $procschm->{Methods_}));



use Win32::OLE('in');
# perform all of the initial steps in one swell foop
my $sobj = Win32::OLE->GetObject(
    'winmgmts:{impersonationLevel=impersonate}')
    or die "can't create server object: ".Win32::OLE->LastError()."\n";
foreach my $process (in $sobj->InstancesOf("Win32_Process")){
    print $process->{Name}." is pid #".$process->{ProcessId},"\n";
}

foreach $process (in $sobj->InstancesOf("Win32_Process")){
    $process->Terminate(1);
}

use Win32::OLE('in');
my $sobj = Win32::OLE->GetObject('winmgmts:{impersonationLevel=impersonate}')
    or die 'can't create server object: ' . Win32::OLE->LastError() . "\n";
my $query = $sobj->ExecQuery('SELECT Name, ProcessId FROM Win32_Process');
foreach my $process ( in $query ) {
 print $process->{Name} . ' is pid #' . $process->{ProcessId}, "\n";
}

use Win32::OLE('in');
my $sobj = Win32::OLE->GetObject('winmgmts:{impersonationLevel=impersonate}')
 or die "can't create server object: " . Win32::OLE->LastError() . "\n";
my $query = $sobj->ExecQuery(
 'SELECT ProcessId FROM Win32_Process WHERE Name = "svchost.exe"');
print "SvcHost processes: "
 . join( ' ', map { $_->{ProcessId} } ( in $query) ), "\n";

opendir my $PROC, '/proc' or die "Unable to open /proc:$!\n";
# only stat the items in /proc that look like PIDs
for my $process (grep /^\d+$/, readdir($PROC)){
 print "$process\t". getpwuid((lstat "/proc/$process")[4])."\n";
}
closedir $PROC;

use Proc::ProcessTable;
my $tobj = new Proc::ProcessTable;

my $proctable = $tobj->table( );

use Proc::ProcessTable;
my $tobj = new Proc::ProcessTable;
my $proctable = $tobj->table();
foreach my $process (@$proctable) {
 print $process->pid . "\t" . getpwuid( $process->uid ) . "\n";
}
use Proc::ProcessTable;
my $t = new Proc::ProcessTable;
foreach my $p (@{$t->table}){
 if ($p->pctmem > 95){
 $p->kill(9);
 }
}

print 'about to nuke '.$p->pid."\t". getpwuid($p->uid)."\n";
print 'proceed? (yes/no) ';
chomp($ans = <>);
next unless ($ans eq 'yes');

use Proc::ProcessTable;
my $logfile = 'eggdrops';
open my $LOG, '>>', $logfile or die "Can't open logfile for append:$!\n";
my $t = new Proc::ProcessTable;
foreach my $p ( @{ $t->table } ) {
 if ( $p->fname() =~ /eggdrop/i ) {
 print $LOG time . "\t"
 . getpwuid( $p->uid ) . "\t"
 . $p->fname() . "\n";
 }
}
close $LOG;

use Proc::ProcessTable;
my $interval = 300; # sleep interval of 5 minutes
my $partofhour = 0; # keep track of where in the hour we are
my $tobj = new Proc::ProcessTable; # create new process object
my %last; # to keep track of info from the previous run
my %current; # to keep track of data from the current run
my %collection; # to keep track of info over the entire hour
# forever loop, collecting stats every $interval secs
# and dumping them once an hour
while (1) {
 foreach my $process ( @{ $tobj->table } ) {
 # we should ignore ourselves
 next if ( $process->pid() == $$ );
 # save this process info for our next run
 # (note: this assumes that your PIDs won't recycle between runs,
 # but on a very busy system that may not be the case)
 $current{ $process->pid() } = $process->fname();
 # ignore this process if we saw it during the last iteration
 next if ( $last{ $process->pid() } eq $process->fname() );
 # else, remember it
 $collection{ $process->fname() }++;
 }
 $partofhour += $interval;
 %last = %current;
 %current = ();
 if ( $partofhour >= 3600 ) {
 print scalar localtime(time) . ( '-' x 50 ) . "\n";
 print "Name\t\tCount\n";
 print "--------------\t\t-----\n";
 foreach my $name ( sort reverse_value_sort keys %collection ) {
 print "$name\t\t$collection{$name}\n";
}
%collection = (); $partofhour = 0;
 }
 sleep($interval);
}
# (reverse) sort by values in %collection and by key name
sub reverse_value_sort {
 return $collection{$b} <=> $collection{$a} || $a cmp $b;
}


use Win32::ChangeNotify;
my $dir = 'c:\importantdir';
# watch this directory (second argument says don't watch for changes
# to subdirectories) for changes in the filenames found there
my $cnot = Win32::ChangeNotify->new( $dir, 0, 'FILE_NAME' );
while (1) {
 # blocks for 10 secs (10,000 milliseconds) or until a change takes place
 my $waitresult = $cnot->wait(10000);
 if ( $waitresult == 1 ) {
 ... # call or include some other code here to figure out what changed
 # reset the ChangeNotification object so we can continue monitoring
 $cnot->reset;
 }
 elsif ( $waitresult == 0 ) {
 print "no changes to $dir in the last 10 seconds\n";
 }
 elsif ( $waitresult == −1 ) {
 print "something went blooey in the monitoring\n";
last;
}
}

use Text::Wrap;
my $lsofexec = '/usr/local/bin/lsof'; # location of lsof executable
# (F)ield mode, NUL (0) delim, show (L)ogin, file (t)ype and file (n)ame
my $lsofflag = '-FL0tn';
open my $LSOFPIPE, '-|', "$lsofexec $lsofflag"
 or die "Unable to start $lsofexec: $!\n";
my $pid; # pid as returned by lsof
my $pathname; # pathname as returned by lsof
my $login; # login name as returned by lsof
my $type; # type of open file as returned by lsof
my %seen; # for a pathname cache
my %paths; # collect the paths as we go

while ( my $lsof = <$LSOFPIPE> ) {
 # deal with a process set
 if ( substr( $lsof, 0, 1 ) eq 'p' ) {
 ( $pid, $login ) = split( /\0/, $lsof );
 $pid = substr( $pid, 1, length($pid) );
 }
 # deal with a file set; note: we are only interested
 # in "regular" files (as per Solaris and Linux, lsof on other
 # systems may mark files and directories differently)
 if ( substr( $lsof, 0, 5 ) eq 'tVREG' or # Solaris
 substr( $lsof, 0, 4 ) eq 'tREG') { # Linux
 ( $type, $pathname ) = split( /\0/, $lsof );
 # a process may have the same pathname open twice;
 # these two lines make sure we only record it once
 next if ( $seen{$pathname} eq $pid );
 $seen{$pathname} = $pid;
 $pathname = substr( $pathname, 1, length($pathname) );
 push( @{ $paths{$pathname} }, $pid );
 }
}
close $LSOFPIPE;
foreach my $path ( sort keys %paths ) {
 print "$path:\n";
 print wrap( "\t", "\t", join( " ", @{ $paths{$path} } ) ), "\n";
}

my $lsofexec = '/usr/local/bin/lsof'; # location of lsof executable
my $lsofflag = '-FL0c -iTCP:6660-7000'; # specify ports and other lsof flags
# This is a hash slice being used to preload a hash table, the
# existence of whose keys we'll check later. Usually this gets written
# like this:
# %approvedclients = ('ircII' => undef, 'xirc' => undef, ...);
# (but this is a cool idiom popularized by Mark-Jason Dominus)
my %approvedclients;
@approvedclients{ 'ircII', 'xirc', 'pirc' } = ();
open my $LSOFPIPE, "$lsofexec $lsofflag|"
 or die "Unable to start $lsofexec:$!\n";
my $pid;
my $command;
my $login;
while ( my $lsof = <$LSOFPIPE> ) {
 ( $pid, $command, $login ) =
 $lsof =~ /p(\d+)\000
 c(.+)\000
 L(\w+)\000/x;
 warn "$login using an unapproved client called $command (pid $pid)!\n"
 unless ( exists $approvedclients{$command} );
}
close $LSOFPIPE;

# Module Information for This Chapter
# Module CPAN ID Version
# Text::CSV_XS HMBRAND 0.32
# Win32::Process::Info WYANT 1.011
# Win32::Setupsup JHELBERG 1.0.1.0
# Win32::GuiTest KARASIC 1.54
# Win32::OLE (ships with ActiveState Perl) JDB 0.1703
# Proc::ProcessTable DURIST 0.41
# Data::Dumper (ships with Perl) GSAR 2.121
# Win32::ChangeNotify JDB 1.05
# Win32::FileNotify RENEEB 0.1
# Text::Wrap (ships with Perl) MUIR 2006.1117
