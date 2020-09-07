use strict;
use warnings;
use DBI;

my @information = stat('filename');

use Getopt::Std;
# we use this for prettier output later in PrintChanged()
my @statnames = qw(dev ino mode nlink uid gid rdev
    size mtime ctime blksize blocks);
getopt( 'p:c:', \my %opt );
die "Usage: $0 [-p <filename>|-c <filename>]\n"
    unless ( $opt{p} or $opt{c} );
if ( $opt{p} ) {
    die "Unable to stat file $opt{p}:$!\n"
        unless ( -e $opt{p} );
    print $opt{p}, '|', join( '|', ( lstat( $opt{p} ) )[ 0 .. 7, 9 .. 12 ] ),
        "\n";
    exit;
}
# if ( $opt{c} ) {
#     open my $CFILE, '<', $opt{c}
#         or die "Unable to open check file $opt{c}:$!\n";
#     while (<$CFILE>) {
#         chomp;
#         my @savedstats = split('\|');
#         die "Wrong number of fields in line beginning with "$savedstats[0]\n"
#  unless ( scalar @savedstats == 13 );
#  my @currentstats = ( lstat( $savedstats[0] ) )[ 0 .. 7, 9 .. 12 ];
# 436 | Chapter 11: Security
#  # print the changed fields only if something has changed
#  PrintChanged( \@savedstats, \@currentstats )
#  if ( "@savedstats[1..12]" ne "@currentstats" );
#  }
#  close $CFILE;
# }

            sub PrintChanged {
 my ( $saved, $current ) = @_;
 # prints the name of the file after popping it off of the array read
 # from the check file
 print shift @{$saved}, ":\n";
 for ( my $i = 0; $i <= $#{$saved}; $i++ ) {
            if ( $saved->[$i] ne $current->[$i] ) {
 print "\t" . $statnames[$i] . ' is now ' . $current->[$i];
 print ' (should be ' . $saved->[$i] . ")\n";
 }
 }
}
sub PrintChanged {
 my ( $saved, $current ) = @_;
 # prints the name of the file after popping it off of the array read
 # from the check file
 print shift @{$saved}, ":\n";
 for ( my $i = 0; $i <= $#{$saved}; $i++ ) {
            if ( $saved->[$i] ne $current->[$i] ) {
 print "\t" . $statnames[$i] . ' is now ' . $current->[$i];
 print ' (should be ' . $saved->[$i] . ")\n";
 }
 }
}

if ("@savedstats[1..12]" ne "@currentstats");

use Digest::SHA;
my $sha = Digest::SHA->new(256);
# 'p' means 'portable mode'; it converts line endings in
# data to Unix format so the same code yields the same
# digest on different operating systems. Feel free to
# leave that out if that is not a concern for you.
$sha->addfile( '/etc/passwd', 'p' );
print $sha->hexdigest . "\n";

use Digest::SHA;
print Digest::SHA->new(256)->addfile( '/etc/passwd', 'p' )->hexdigest, "\n";

use Getopt::Std;
use Digest::SHA;
# we use this for prettier output later in PrintChanged()
my @statnames = qw(dev ino mode nlink uid gid rdev
    size mtime ctime blksize blocks SHA-256);
getopt( 'p:c:', \my %opt );
die "Usage: $0 [-p <filename>|-c <filename>]\n"
    unless ( $opt{p} or $opt{c} );
if ( $opt{p} ) {
    die "Unable to stat file $opt{p}:$!\n"
        unless ( -e $opt{p} );
    my $digest = Digest::SHA->new(256)->addfile( $opt{p}, 'p' )->hexdigest;
    print $opt{p}, '|', join( '|', ( lstat( $opt{p} ) )[ 0 .. 7, 9 .. 12 ] ),
        "|$digest", "\n";
    exit;
}
if ( $opt{c} ) {
    open my $CFILE, '<', $opt{c}
        or die "Unable to open check file $opt{c}:$!\n";
    while (<$CFILE>) {
        chomp;
        my @savedstats = split('\|');
        die "Wrong number of fields in line beginning with $savedstats[0]\n"
            unless ( scalar @savedstats == 14 );
        my @currentstats = ( lstat( $savedstats[0] ) )[ 0 .. 7, 9 .. 12 ];
        push( @currentstats,
            Digest::SHA->new(256)->addfile( $savedstats[0] )->hexdigest );
        # print the changed fields only if something has changed
        PrintChanged( \@savedstats, \@currentstats )
            if ( "@savedstats[1..13]" ne "@currentstats" );
    }
    close $CFILE;
}


sub PrintChanged {
    my ( $saved, $current ) = @_;
    # prints the name of the file after popping it off of the array read
    # from the check file
    print shift @{$saved}, ":\n";
    for ( my $i = 0; $i <= $#{$saved}; $i++ ) {
        if ( $saved->[$i] ne $current->[$i] ) {
            print "\t" . $statnames[$i] . ' is now ' . $current->[$i];
            print " (should be " . $saved->[$i] . ")\n";
        }
    }
}

use Net::DNS;
# takes two command-line arguments: the first is the name server
# to query, the second is the domain to query from that name server
my $server = new Net::DNS::Resolver;
$server->nameservers( $ARGV[0] );
print STDERR 'Transfer in progress...';
my @zone = $server->axfr( $ARGV[1] );
die $server->errorstring unless @zone;
print STDERR "done.\n";
foreach my $record (@zone) {
    $record->print;
}


use Net::DNS;
use FreezeThaw qw(freeze);
use Digest::SHA;
my $server = new Net::DNS::Resolver;
$server->nameservers( $ARGV[0] );
print STDERR 'Transfer in progress...';
my @zone = $server->axfr( $ARGV[1] );
die $server->errorstring unless @zone;
print STDERR "done.\n";
my $zone = join( '', sort map { freeze($_) } @zone );
print "SHA-2 fingerprint for this zone transfer is: \n";
print Digest::SHA->new(256)->add($zone)->hexdigest, "\n";

my $zone = join( '', sort map { freeze($_) } @zone );
use File::Find;
find( \&wanted, '.' );
sub wanted {
    ( -d $_ ) and # is a directory
        $_ ne '.' and $_ ne '..' and # is not . or ..
        (
            /[^-.a-zA-Z0-9+,:;_~\$#()]/ or # contains a "bad" character
                /^\.{3,}/ or # or starts with at least 3 dots
                /^-/ # or begins with a dash
        ) and print "'" . nice($File::Find::name) . "'\n";
}

sub nice {
    my $name = shift;
    $name =~ s/([\001-\037\177])/'^'.pack('c',ord($1)^64)/eg;
    return $name;
}

use File::Find::Rule;
my @problems
    = File::Find::Rule->name( qr/[^-.a-zA-Z0-9+,:;_~\$#()]/,
    qr/^\.{3,}/,
    qr/^-/ )
    ->in('.');
foreach my $name (@problems) {
    print "'" . nice($name) . "'\n";
}
# Print a "nice" version of the directory name, i.e., with control chars
# explicated. This subroutine is barely modified from &unctrl() in Perl's
# stock dumpvar.pl. If we wanted to be less of a copycat we could
# use something like Devel::Dumpvar instead.
sub nice {
    my $name = shift;
    $name =~ s/([\001-\037\177])/'^'.pack('c',ord($1)^64)/eg;
    return $name;
}


sub usage {
    print <<"EOU";
lastcheck - check the output of the last command on a machine
 to determine if any user has logged in from > N domains
 (inspired by an idea from Daniel Rinehart)
 USAGE: lastcheck [args], where args can be any of:
 -i <class> for IP #'s, treat class <B|C> subnets as the same "domain"
 -f <domain> count only foreign domains, specify home domain
 -l <command> use <command> instead of default /usr/bin/last -a
 note: no output format checking is done!
 -m <#> max number of unique domains allowed, default 3
 -u <user> perform check for only this username
 -h this help message
EOU
    exit;
}

use Getopt::Std;
use Regexp::Common qw(net);
getopts( 'i:hf:l:m:u:', \my %opt ); # parse user input
usage() if ( defined $opt{h} );
# number of unique domains before we complain (default 3)
my $maxdomains = $opt{m} ||= 3;
# keep network block upcased, provide default of 'C'-sized
if ( exists $opt{i} ) {
    $opt{i} = uc $opt{i};
    $opt{i} ||= 'C';
}


my $lastex = $opt{l} ||= '/usr/bin/last -a';
open my $LAST, '-|', $lastex || die "Can't run the program $lastex:$!\n";

$userinfo { 'laf' } = { 'ccs.example.edu' => undef,
    'xerox.com' => undef,
    'tpu.edu' => undef }

my %userinfo;
while (<$LAST>) {
    # ignore special users
    next if /^reboot\s|^shutdown\s|^ftp\s/;
    # if we've used -u to specify a specific user, skip all entries
    # that don't pertain to this user (whose name is stored in $opt{u}
    # by getopts for us)
    next if ( defined $opt{u} && !/^$opt{u}\s/ );
    # ignore X console logins
    next if /:0\s+(:0)?/;
    chomp; # chomp if we think we still might be interested in the line
    # find the user's name, tty, and remote hostname
    my ( $user, $host ) = /^([a-z0-9-.]+)\s.*\s([a-zA-Z0-9-.]+)$/;
    # ignore if the log had a bad username after parsing
    next if ( length($user) < 2 );
    # ignore if no domain name or IP info in name
    next if $host !~ /\./;
    # find the domain name of this host (see explanation following code)
    my $dn = domain($host);
    # ignore if you get a bogus domain name
    next if ( length($dn) < 2 );
    # ignore this input line if it is in the home domain as specified
    # by the -f switch
    next if ( defined $opt{f} && ( $dn =~ /^$opt{f}/ ) );
    # store the info for this user
    $userinfo{$user}{$dn} = undef;
}
close $LAST;
# take an FQDN and attempt to return the FQD
sub domain {
    my $fdqn_or_ip = shift;
    if ( $fdqn_or_ip =~ /^$RE{net}{IPv4}{-keep}$/ ) {
        if ( exists $opt{i} ) {
            return ( $opt{i} eq 'B' ) ? "$2.$3" : "$2.$3.$4";
        }
        else { return $fdqn_or_ip; }
    }
    else {
        # Ideally we'd check against $RE{net}{domain}{-nospace}, but this
        # (as of this writing) enforces the RFC 1035 spec, which
        # has been updated by RFC 1101. This is a problem
        # for domains that begin with numbers (e.g., 3com.com).
        # downcase the info for consistency's sake
        $fdqn_or_ip = lc $fdqn_or_ip;
        # then return everything after first dot
        $fdqn_or_ip =~ /^[^.]+\.(.*)/;
        return $1;
    }
}


foreach my $user ( sort keys %userinfo ) {
    if ( scalar keys %{ $userinfo{$user} } > $maxdomains ) {
        print "\n\n$user has logged in from:\n";
        print join( "\n", sort keys %{ $userinfo{$user} } );
    }
}
print "\n";


use Readonly;
# location/switches of clog
Readonly my $clogex => '/tmp/clog';
# location/switches of fping
Readonly my $fpingex => '/arch/unix/bin/fping -r1';
Readonly my $localnet => '192.168.1'; # local network
my %cache;
open my $CLOG, '-|', "$clogex" or die "Unable to run clog:$!\n";
while (<$CLOG>) {
    my ( $date, $orighost, $origport, $desthost, $destport ) = split(/\|/);
    next if ( $orighost =~ /^$localnet\b/ );
    next if ( exists $cache{$orighost} );
    print `$fpingex $orighost`;
    $cache{$orighost} = 1;
}
# we'd never really get here because we were in an infinite loop,
# but this is just good practice should we change the code above
close $CLOG;


use Net::Ping;
my $p = Net::Ping->new('icmp');
if ( $p->ping($host) ) {
    print "ping succeeded.\n";
}
else {
    print "ping failed\n";
}


use Net::Pcap qw(:functions);
# could also use lookupdev and findalldevs to find the right device
my $dev = 'en1';
# prepare to capture 1500 bytes from each packet,
# promiscuously (i.e., all traffic, not just sent to us),
# with no packet timeout, placing any error messages
# for this call in $err
my $err;
my $pcap = open_live( $dev, 1500, 1, 1, \$err )
    or die "Unable to open_live device $dev: $err\n";


# capture packets until interrupted
my $ret = loop( $pcap, −1, \&printpacketlength, '' );
warn 'Unable to perform capture:' . geterr($pcap) . "\n"
    if ( $ret == −1 );
Net::Pcap::close($pcap);


sub printpacketlength {
    my ( $user_data, $header, $packet ) = @_;
    print length($packet), "\n";
}

my $filter_string = 'tcp[13] = 2';
# compile and set our "filter program"
Net::Pcap::compile( $pcap, \my $filter, $filter_string, 1, 0 )
    and die "unable to compile $filter_string\n";
Net::Pcap::setfilter( $pcap, $filter ) and die "unable to set filter\n";


my $pobj = NetPacket::TCP->decode(
    NetPacket::IP::strip(NetPacket::Ethernet::strip($packet)))

my $dport = NetPacket::TCP->decode(
    NetPacket::IP::strip(
        NetPacket::Ethernet::strip($packet)))->{dest_port};
use Net::PcapUtils;
use NetPacket::Ethernet;
use NetPacket::IP;
use Net::Ping;
use Readonly;
Readonly my $dev => 'en0';
Readonly my $localnet => '192.168.1';
# filter string that looks for SYN-only packets
# not originating from local network
Readonly my $filter_string => "tcp[13] = 2 and src net not $localnet";
my %cache;
$| = 1; # unbuffer STDIO
# construct the ping object we'll use later
my $p = Net::Ping->new('icmp');
# and away we go
my $ret = Net::PcapUtils::loop(
    \&grab_ip_and_ping,
    FILTER => $filter_string,
    DEV => $dev
);
die "Unable to perform capture: $ret\n" if $ret;
# find the source IP address of a packet, and ping it (once per run)
sub grab_ip_and_ping {
    my ( $arg, $hdr, $pkt ) = @_;
    # get the source IP adrress
    my $src_ip
        = NetPacket::IP->decode( NetPacket::Ethernet::strip($pkt) )->{src_ip};
    print "$src_ip is "
        . ( ( $p->ping($src_ip) ) ? 'alive' : 'unreachable' ) . "\n"
        unless $cache{$src_ip}++;
}

use Net::Pcap::Easy;
use Net::Ping;
use Readonly;
Readonly my $dev => 'en1';
Readonly my $localnet => "192.168.1";
# filter string that looks for SYN-only packets
# not originating from local network
Readonly my $filter_string => "tcp[13] = 2 and src net not $localnet";
my %cache;
$| = 1; # unbuffer STDIO
# construct the ping object we'll use later
my $p = Net::Ping->new('icmp');
# set up all of the Net::Pcap stuff and
# include a callback
my $npe = Net::Pcap::Easy->new(
    dev => $dev,
    filter => $filter_string,
    packets_per_loop => 10,
    bytes_to_capture => 1500,
    timeout_in_ms => 1,
    promiscuous => 1,
    tcp_callback => sub {
        my ( $npe, $ether, $ip, $tcp ) = @_;
        my $src_ip = $ip->{src_ip};
        print "$src_ip is "
            . ( ( $p->ping($src_ip) ) ? 'alive' : 'unreachable' ) . "\n"
            unless $cache{$src_ip}++;
    }
);
while (1) { $npe->loop(); }

use Data::SimplePassword;
my $dsp = Data::SimplePassword->new();
# 10-char-long random password; we could specify which
# characters to use if we cared via the chars() method
print $dsp->make_password(10),"\n";
use Crypt::GeneratePassword;
for (1..5) {
    print Crypt::GeneratePassword::word( 8, 8 ),"\n";
}


use Cracklib;
use Term::Prompt;
use Readonly;
Readonly my $dictpath => '/opt/local/share/cracklib/pw_dict';
my $pw = prompt( 'p', 'Please enter password:', '', '' );
print "\n";
my $result = Cracklib::FascistCheck( $pw, $dictpath );
if ( defined $result ) {
    print "That is not a valid password because $result.\n";
}
else {
    print "That password is peachy, thanks!\n";
}

use Test::More tests => 6;
BEGIN { use_ok 'Cracklib' };
# location of our cracklib dictionary files
#
# to make this test file portable we'd write out this test
# file with the pointer to the dictionary files supplied
# by the user at Makefile.PL runtime
my $dictpath = '/opt/local/share/cracklib/pw_dict';
# test strings and their known cracklib responses
my %tests =
    ('happy' => 'it is too short',
        'a' => 'it is WAY too short',
        'asdfasdf' => 'it does not contain enough DIFFERENT characters',
        'minicomputer' => 'it is based on a dictionary word',
        '1ftm2tgr3fts' => undef);
foreach my $pw (sort keys %tests){
    is(Cracklib::FascistCheck($pw,$dictpath), $tests{$pw}, "Passwd = $pw");
}