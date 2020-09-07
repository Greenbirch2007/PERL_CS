use strict;
use warnings;
use DBI;

use Net::Ping;
use Net::Ping::External;
use Net::Ping;
use Net::Netmask;
my $ping = Net::Ping->new('icmp'); # must run this script w/root privileges
# hand this script a network/netmask specification
die $Net::Netmask::error
    unless my $netblock = new2 Net::Netmask( $ARGV[0] );
my $blocksize = $netblock->size() - 1;
# this loop may take a while since nonreachable addresses have to time out
my (@addrs);
for ( my $i = 1; $i <= $blocksize; $i++ ) {
    my $addr = $netblock->nth($i);
    push( @addrs, $addr ) if $ping->ping( $addr, 1 );
}
print "Found\n", join( "\n", @addrs ), "\n" if scalar @addrs;
for my $address ($netblock->enumerate) {...}
use Net::Arping;
my $arping = Net::Arping->new();
# arping() returns the MAC address from the ARP response if received
my $return = $arping->arping($ARGV[0]);
print "$ARGV[0] " .
    ($return) ? "($return) is up\n" : "is down\n";

use Net::PcapUtils;
use NetPacket::Ethernet;
use NetPacket::ARP;
my $filter = 'arp';
my $dev = 'en1'; # device for my wireless card
my %addresses = ();
die 'Unable to perform capture: ' . Net::Pcap::geterr($dev) . "\n"
    if ( Net::PcapUtils::loop(\&CollectPackets,
        FILTER => $filter,
        DEV => $dev,
        NUMPACKETS => 100,
    )
    );
print join( "\n", keys %addresses ),"\n";
sub CollectPackets {
    my ( $arg, $hdr, $pkt ) = @_;
    # convert the source protocol address (i.e., IP address)
    # in hex form to dotted quad format (i.e., X.X.X.X)
    my $ip_addr = join(
        '.',
        unpack(
            'C*',
            pack( 'H*',
                NetPacket::ARP->decode( NetPacket::Ethernet::strip($pkt) )
                    ->{'spa'} ))
    );
    $addresses{$ip_addr}++;
}

use Net::PcapUtils;
use NetPacket::Ethernet;
use NetPacket::IP;
my $filter = 'dst port 68'; # DHCP response port
my $dev = 'en1'; # device for my wireless card
my %addresses = ();
die 'Unable to perform capture: ' . Net::Pcap::geterr($dev) . "\n"
    if (
        Net::PcapUtils::loop(
            \&CollectPackets,
            FILTER => $filter,
            DEV => $dev, # device for my wireless card
            NUMPACKETS => 100,
        )
    );
print join( "\n", keys %addresses ), "\n";
sub CollectPackets {
    my ( $arg, $hdr, $pkt ) = @_;
    # convert the IP address in hex form to dotted quad
    my $ip_addr =
        NetPacket::IP->decode( NetPacket::Ethernet::strip($pkt) )->{'src_ip'};
    $addresses{$ip_addr}++;
}


use SNMP::Info::CDP;
my $cdp = new SNMP::Info (
    AutoSpecify => 1,
    Debug => 1,
    DestHost => 'router',
    Community => 'public',
    Version => 2
);
my $interfaces = $cdp->interfaces();
my $c_if = $cdp->c_if();
my $c_ip = $cdp->c_ip();
my $c_port = $cdp->c_port();
foreach my $cdp_key (keys %$c_ip){
    my $iid = $c_if->{$cdp_key};
    my $port = $interfaces->{$iid};
    my $neighbor = $c_ip->{$cdp_key};
    my $neighbor_port = $c_port->{$cdp_key};
    print "Port : $port connected to $neighbor / $neighbor_port\n";
}


use SNMP;
my $c = new SNMP::Session(DestHost => 'router',
    Version => '2c',
    Community => 'secret');
my $routetable = $c->gettable('ipRouteTable');
for my $dest (keys %$routetable){
    # 3 = "direct" route (see RFC 1213 for the other values)
    next unless $routetable->{$dest}->{ipRouteType} == 3;
    print "$routetable->{$dest}->{ipRouteNextHop}\n";
}

use Nmap::Scanner;
my $nscan = new Nmap::Scanner;
# Location of nmap binary. We're being explicit
# here as a matter of precaution, but if you leave
# this out it will be found in your $PATH.
$nscan->nmap_location('/usr/local/bin/nmap');
# scan the 192.168.0.x subnet for port 80 (http) open
my $nres = $nscan->scan('-p 80 192.168.0.0/24');
# retrieve the list of host objects found by the scan
my $nhosts = $nres->get_host_list();
# iterate over that list, printing out hostnames for
# the hosts with open ports
while( my $host = $nhosts->get_next() ){
    print $host->hostname()."\n" if
        $host->get_port("tcp",80)->state() eq 'open';
}


use Nmap::Scanner;
my $nscan = new Nmap::Scanner;
$nscan->nmap_location('/sw/bin/nmap');
# every time we find a port, run &PrintIfOpen
$nscan->register_port_found_event( \&PrintIfOpen );
my $nres = $nscan->scan('-p 80 129.10.116.0/24');
sub PrintIfOpen {
    # we receive a scanner object, a host object
    # and a port object each time this event
    # handler is called
    my ( $self, $host, $port ) = @_;
    print $host->hostname() . "\n"
        if $port->state() eq 'open';
}

use Array::PrintCols;
my @a = ('Martin Balsam','John Fiedler','Lee J. Cobb','E.G. Marshall',
    'Jack Klugman','Ed Binns','Jack Warden','Henry Fonda',
    'Joseph Sweeney','Ed Begley','George Voskovec','Robert Webber');
$Array::PrintCols::PreSorted = 0; # the data is not presorted, so sort
print_cols \@a;
use Text::FormatTable;
# imagine we generated this data structure through some
# complicated network probe process
my %results = (
    'drummond' => {
        status => 'passed',
        owner => 'stracy' },
    'brady' => {
        status => 'passed',
        owner => 'fmarch'
    },
    'hornbeck' => {
        status => 'passed',
        owner => 'gkelly'
    }
);
my $table = Text::FormatTable->new('| l | l | l |');
$table->rule('-');
$table->head(qw(Host Status Owner));
$table->rule('-');
for ( sort keys %results ) {
    $table->row( $_, $results{$_}{status}, $results{$_}{owner} );
}
$table->rule('-');
print $table->render();


use Text::BarGraph;
# imagine these are important statistics collected for each machine
my %hoststats = ( 'click' => 100,
    'clack' => 37,
    'moo' => 75,
    'giggle' => 10,
    'duck' => 150);
my $g = Text::BarGraph->new();
$g->{columns} = 70; # set column size
$g->{num} = 1; # show values next to bars
print $g->graph(\%hoststats);
use GD::Graph::hbars;
my @data=([qw(click clack moo giggle duck)],[100,37,75,10,150]);
my $g = new GD::Graph::hbars;
$g->plot(\@data);
open my $T, '>', 't.png' or die "Can't open t.png:$!\n";
binmode $T;
print $T $g->gd->png;
close $T;
$g->set(
    x_label => 'Machine Name',
    y_label => 'Bogomips',
    title => 'Machine Computation Comparison',
    x_label_position => 0.5,
    bar_spacing => 10,
    values_space => 15,
    shadow_depth => 4,
    shadowclr => 'dred',
    transparent => 0,
    show_values => $g
);
use GraphViz;
my $g = GraphViz->new();
$g->add_node('Client');
$g->add_node('Server', shape=>'box');
$g->add_edge('Client' => 'Server');

$g->as_jpeg('simple.jpg');
use NetPacket::Ethernet qw(:strip);
use NetPacket::IP qw(:strip);
use NetPacket::TCP;
use Net::PcapUtils;
use GraphViz;
my $filt = 'port 80 and tcp[13] = 2';
my $dev = 'en1';
my %traffic; # for recording the src/dst pairs
die 'Unable to perform capture: '
    . Net::Pcap::geterr($dev) . "\n"
    if ( Net::PcapUtils::loop(
        \&grabipandlog,
        DEV => $dev,
        FILTER => $filt,
        NUMPACKETS => 50 )
    );
my $g = new GraphViz;
for ( keys %traffic ) {
    my ( $src, $dest ) = split(/:/);
    $g->add_node($src);
    $g->add_node($dest);
    $g->add_edge( $src => $dest );
}
$g->as_jpeg('syn80.jpg');
sub grabipandlog {
    my ( $arg, $hdr, $pkt ) = @_;
    my $src = NetPacket::IP->decode( NetPacket::Ethernet::strip($pkt) )
        ->{'src_ip'};
    my $dst = NetPacket::IP->decode( NetPacket::Ethernet::strip($pkt) )
        ->{'dest_ip'};
    $traffic{"$src:$dst"}++;
}
my $g = new GraphViz;
use RRDs;
my $database = "router.rrd";
RRDs::create ($database, '-start', time-1, '-step', '120',
    'DS:bandin:COUNTER:240:0:10000000',
    'DS:bandout:COUNTER:240:0:10000000',
    'DS:temp_in:GAUGE:240:0:100',
    'RRA:AVERAGE:0.5:30:24');
my $ERR=RRDs::error;
die "Can't create $database: $ERR\n" if $ERR;
while (1) {
    ($in,$out,$temp)= snmpquery(); # query the router with SNMP
    RRDs::update($database, "N:$in:$out:$temp");
    my $ERR=RRDs::error;
    die "Can't update $database: $ERR\n" if $ERR;
    sleep (120 - time % 120); # sleep until next step time
}

use RRDs;
RRDs::graph('dayband.png',
    '-start', '1234893600','-end', '1234908000',
    '--lower-limit 0',
    'DEF:bandwin=router.rrd:bandin:AVERAGE',
    'DEF:bandwout=router.rrd:bandout:AVERAGE',
    'LINE2:bandwin#FF0000',
    'LINE2:bandwout#000000');
use RRDs;
RRDs::graph('temp.png',
    'DEF:temp=router.rrd:temp_in:AVERAGE',
    'LINE2:temp#000000');
use RRDs;
RRDs::graph('tempf.png',
    'DEF:temp=router.rrd:temp_in:AVERAGE',
    'CDEF:tempf=temp,9,*,5,/,32,+',
    'LINE2:tempf#000000:Inflow Temp',
    "LINE:85#FF0000:Danger Line\r");
use Test::More tests => 5;

is(check_dns('my_server'),$known_ip,
    'DNS query returns right address for server');
is(sha2_page('http://www.example.com'),
    '6df23dc03f9b54cc38a0fc1483df6e21',
    'Home page has correct data');


