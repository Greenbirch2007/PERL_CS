use strict;
use warnings;
use DBI;

use Net::SNMP;
# requires a hostname and a community string as its arguments
my ($session,$error) = Net::SNMP->session(Hostname => $ARGV[0],
    Community => $ARGV[1]);
die "session error: $error" unless ($session);
# iso.org.dod.internet.mgmt.mib-2.interfaces.ifNumber.0 =
# 1.3.6.1.2.1.2.1.0
my $result = $session->get_request('1.3.6.1.2.1.2.1.0');
die 'request error: '.$session->error unless (defined $result);
$session->close;
print 'Number of interfaces: '.$result->{'1.3.6.1.2.1.2.1.0'}."\n";


use SNMP;
# requires a hostname and a community string as its arguments
my $session = new SNMP::Session(DestHost => $ARGV[0],
    Community => $ARGV[1],
    Version => '1',
    UseSprintValue => 1);
die "session creation error: $SNMP::Session::ErrorStr" unless
    (defined $session);
# set up the data structure for the getnext() command
my $vars = new SNMP::VarList(['ipNetToMediaNetAddress'],
    ['ipNetToMediaPhysAddress']);
# get first row
my ($ip,$mac) = $session->getnext($vars);
die $session->{ErrorStr} if ($session->{ErrorStr});
# and all subsequent rows
while (!$session->{ErrorStr} and
    $vars->[0]->tag eq 'ipNetToMediaNetAddress'){
    print "$ip -> $mac\n";
    ( $ip, $mac ) = $session->getnext($vars);
};


use SNMP;
my $session = new SNMP::Session(DestHost => $ARGV[0],
    Community => $ARGV[1],
    Version => '1',
    UseSprintValue => 1);
my $vars = new SNMP::VarList (['ipNetToMediaNetAddress'],
    ['ipNetToMediaPhysAddress']);
my ($ip,$mac) = $session->getnext($vars);
die $session->{ErrorStr} if ($session->{ErrorStr});

while (!$session->{ErrorStr} and
    ($vars->[0]->tag eq 'ipNetToMediaNetAddress')){
    print "$ip -> $mac\n";
    ($ip,$mac) = $session->getnext($vars);
};

use SNMP;
my ($switchname, $community, $macaddr) = @ARGV;
# here are the MIBs we need and why
$ENV{'MIBS'}=join(':', ('CISCO-VLAN-MEMBERSHIP-MIB', # VLAN listing and status
    'BRIDGE-MIB', # MAC address to port table
    'CISCO-VTP-MIB', # port trunking status
));
# connect and get the list of VLANs on this switch
$session = new SNMP::Session(DestHost => $switchname,
    Community => $community,
    Version => 1);
die "session creation error: $SNMP::Session::ErrorStr" unless
    (defined $session);
# enterprises.cisco.ciscoMgmt.
# ciscoVlanMembershipMIB.ciscoVlanMembershipMIBObjects.vmMembership.
# vmMembershipTable.vmMembershipEntry
# in CISCO-VLAN-MEMBERSHIP-MIB
my $vars = new SNMP::VarList (['vmVlan'],['vmPortStatus']);
my ( $vlan, $vlanstatus ) = $session->getnext($vars);
die $session->{ErrorStr} if ($session->{ErrorStr});
my %vlans;
while (!$session->{ErrorStr} and $vars->[0]->tag eq 'vmVlan'){
    $vlans{$vlan}++ if $vlanstatus == 2; # make sure the vlan is active (2)
    ( $vlan, $vlanstatus ) = $session->getnext($vars);
};
undef $session,$vars;
# make sure the MAC address is in the right form
my $findaddr = massage_mac($macaddr);
# for each VLAN, see if there is a bridge port that has seen a particular
# macaddr; if so, find the interface number associated with that port, and
# then the interface name for that interface number
foreach my $vlan (sort keys %vlans) {
    # for caching query results
    # (we keep the cache around only for a single VLAN)
    my (%ifnum, %portname);
    # note our use of "community string indexing" as part
    # of the session setup
    my $session = new SNMP::Session(DestHost => $switchname,
        Community => $community.'@'.$vlan,
        UseSprintValue => 1,
        Version => 1);
    die "session creation error: $SNMP::Session::ErrorStr"
        unless (defined $session);
    # see if the MAC address is in our bridge forwarding table
    # note: the $macaddr has to be in XX.XX.XX.XX.XX.XX form
    #
    # from transparent forwarding port table at
    # dot1dBridge.dot1dTp.dot1dTpFdbTable.dot1dTpFdbEntry
    # in RFC 1493 BRIDGE-MIB
    my $portnum = $session->get(['dot1dTpFdbPort',$findaddr]);
    # nope, it's not there (at least in this VLAN), try the next VLAN
    next if $session->{ErrorStr} =~ /noSuchName/;
    # convert the forwarding table port number to interface number
    #
    # from dot1dBridge.dot1dBase.dot1dBasePortTable.dot1dBasePortEntry
    # in RFC 1493 BRIDGE-MIB
    my $ifnum =
        (exists $ifnum{$portnum}) ? $ifnum{$portnum} :
            ($ifnum{$portnum} =
                $session->get(['dot1dBasePortIfIndex',$portnum]));
    # skip it if this interface is a trunk port
    #
    # from ciscoVtpMIB.vtpMIBObjects.vlanTrunkPorts.vlanTrunkPortTable.
    # vlanTrunkPortEntry in CISCO-VTP-MIB
    next if
        $session->get(['vlanTrunkPortDynamicStatus',$ifnum]) eq 'trunking';
    # convert the interface number to port name (i.e., module/port)
    #
    # from ifMIB.ifMIBObjects.ifXTable.ifXEntry in RFC 1573 IF-MIB
    my $portname =
        (exists $portname{$ifnum}) ? $portname{$ifnum} :
            ($portname{$ifnum}=$session->get(['ifName',$ifnum]));
    print "$macaddr on VLAN $vlan at $portname\n";
}
# take in a MAC address in the form of XX:XX:XX:XX:XX:XX,
# XX-XX-XX-XX-XX-XX, or XXXXXXXXXXXXXX (X is hex) and return it in the
# decimal, period-delimited format we need for queries
sub massage_mac {
    my $macaddr = shift;
    # no punctuation at all (becomes colon-separated)
    $macaddr =~ s/(..)(?=.)/$1:/g if (length($macaddr) == 12);
    # colon- or dash-separated
    return join('.', map (hex,split(/[:-]/,uc $macaddr)))
}

$ENV{'MIBS'}=join(':', ('CISCO-VLAN-MEMBERSHIP-MIB', # VLAN listing and status
    'BRIDGE-MIB', # MAC address to port table
    'CISCO-VTP-MIB', # port trunking status
));

#
# foreach my $vlan (sort keys %vlans) {
#     my $session = new SNMP::Session(DestHost => $switchname,
#         Community => $community.'@'.$vlan,
#         UseSprintValue => 1,
#         Version => 1);
my $portnum = $session->get(['dot1dTpFdbPort',$findaddr]);
# nope, it's not there (at least in this VLAN), try the next VLAN
next if $session->{ErrorStr} =~ /noSuchName/;

my $ifnum =
    (exists $ifnum{$portnum}) ? $ifnum{$portnum} :
        ($ifnum{$portnum} =
            $session->get(['dot1dBasePortIfIndex',$portnum]));
my $s = new SNMP::TrapSession(..., Version => 1);
$s->trap(enterprise => '.1.3.6.1.4.1.2021', # Net-SNMP MIB extension
    agent => '192.168.0.1',
    generic => 2, # link down
    specific => 0,
    uptime => 1097679379, # leave out to use current time
    [['ifIndex', 1, 1], # which interface
        ['sysLocation', 0, 'dieselcafe']]); # in which location
my $s = new SNMP::TrapSession(..., Version => '2c');
$s->trap(oid => 'linkDown',
    uptime => 1097679379, # leave out to use current time
    [['ifIndex', 1, 1], # which interface
        ['ifAdminStatus', 1, 1], # administratively up
        ['ifOperStatus', 1, 2]]); # operationally down
sub callback {...};
my $s = new SNMP::TrapSession(..., Version => '3');
$s->inform(oid => 'linkDown',
    uptime => 1097679379, # leave out to use current time
    [[ifIndex, 1, 1], # which interface
        [ifAdminStatus, 1, 1], # administratively up
        [ifOperStatus, 1, 2]], # operationally down
    [\&callback, $s]);
use SNMP_Session;
use BER;
my $trap_session = SNMPv1_Session->open_trap_session()
    or die 'cannot open trap session';
my ($trap, $sender_addr, $sender_port) = $trap_session->receive_trap()
    or die 'cannot receive trap';
my ($community, $enterprise, $agent,
    $generic, $specific, $sysUptime, $bindings) =
    $trap_session->decode_trap_request($trap)
    or die 'cannot decode trap received';
...
# this is how we would decode the bindings (e.g., if dealing
# with v2c notification)
my ($binding, $oid, $value);
while ($bindings ne '') {
    ($binding,$bindings) = decode_sequence($bindings);
    ($oid, $value) = decode_by_template($binding, "%O%@");
    print BER::pretty_oid($oid),' => ',pretty_print ($value),"\n";
}

use SNMP::Info;
my $c = SNMP::Info->new(AutoSpecify => 1,
    DestHost => $ARGV[0],
    Community => $ARGV[1],
    Version => '2c');
my $duplextable = $c->i_duplex();
print "Duplex setting for interface $ARGV[2]: " .
    $duplextable->{$ARGV[2]} . "\n";
