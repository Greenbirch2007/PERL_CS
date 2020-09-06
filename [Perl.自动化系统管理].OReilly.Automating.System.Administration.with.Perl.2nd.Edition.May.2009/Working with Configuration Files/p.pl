use strict;
use warnings;
use DBI;

open my $DATA_FILE_H, '<', '/var/adm/data'
    or die "unable to open datafile: $!\n";
open my $OUTPUT_FILE_H, '>', '/var/adm/output'
    or die "unable to write to outputfile: $!\n";
while ( my $dataline = <$DATA_FILE_H> ) {
    chomp($dataline);
    if ( $dataline =~ /^hostname: / ) {
        $dataline .= '.example.edu';
    }
    print $OUTPUT_FILE_H $dataline . "\n";
}
close $DATA_FILE_H;
close $OUTPUT_FILE_H;

my $datafile = '/var/adm/data'; # input data filename
my $outputfile = '/var/adm/output'; # output data filename
my $change_tag = 'hostname: '; # append data to these lines
my $fdqn = '.example.edu'; # domain we'll be appending
open my $DATA_FILE_H, '<', $datafile
    or die "unable to open $datafile: $!\n";
open my $OUTPUT_FILE_H, '>', $outputfile
    or die "unable to write to $outputfile: $!\n";
while ( my $dataline = <$DATA_FILE_H> ) {
    chomp($dataline);
    if ( $dataline =~ /^$change_tag/ ) {
        $dataline .= $fdqn;
    }
    print $OUTPUT_FILE_H $dataline . "\n";
}
close $DATA_FILE_H;
close $OUTPUT_FILE_H;
use Readonly;
# we've upcased the constants so they stick out
# note: this is the Perl 5.8.x syntax, see the Readonly docs for using
# Readonly with versions of Perl older than 5.8
Readonly my $DATAFILE => '/var/adm/data'; # input data filename
Readonly my $OUTPUTFILE => '/var/adm/output'; # output data filename
Readonly my $CHANGE_TAG => 'hostname: '; # append data to these lines
Readonly my $FDQN => '.example.edu'; # domain we'll be appending
open my $DATA_FILE_H, '<', $DATAFILE
    or die "unable to open $DATAFILE: $!\n";
open my $OUTPUT_FILE_H, '>', $OUTPUTFILE
    or die "unable to write to $OUTPUTFILE: $!\n";
while ( my $dataline = <$DATA_FILE_H> ) {
    chomp($dataline);

    if ( $dataline =~ /^$CHANGE_TAG/ ) {
        $dataline .= $FDQN;
    }
    print $OUTPUT_FILE $dataline . "\n";
}
close $DATA_FILE_H;
close $OUTPUT_FILE_H;
use Storable;
# write the config file data structure out to $CONFIG_FILE
store \%config, $CONFIG_FILE; # use nstore() for platform independent file
# later (perhaps in another program), read it back in for use
my $config = retrieve($CONFIG_FILE);
use DBM::Deep;
my $configdb = new DBM::Deep 'config.db';
# store some host config info to that db
$configdb->{hosts} = {
    'agatha' => '192.168.0.4',
    'gilgamesh' => '192.168.0.5',
    'tarsus' => '192.168.0.6',
};
# (later) retrieve the names of the hosts we've stored
print join( ' ', keys %{ $configdb->{hosts} } ) . "\n";
use Readonly;
Readonly my $DELIMITER => ':';
Readonly my $NUMFIELDS => 4 ;
# open your config file and read in a line here
# now parse the data
my ( $field1, $field2, $field3, $field4, $excess ) =
    split $DELIMITER, $line_of_config, $NUMFIELDS;
use Text::CSV::Simple;
my $csv_parser = Text::CSV::Simple->new;
# @data will then contain a list of lists, one entry per line of the file
my @data = $csv_parser->read_file($datafile);

use Config::Std;
read_config 'config.cfg' => my %config;
# now work with $config{Section}{key}...
...
# and write the config file back out again
write_config %config;


use Config::General;
my %config = ParseConfig( -ConfigFile => 'rcfile' );
# now work with the contents of %config...
...
# and then write the config file back out again
SaveConfig( 'configdb', \%config );

use Config::Scoped;
my $parser = Config::Scoped->new( file => 'config.cfg' );
my $config = $parser->parse;
# store the cached version on disk for later use
$parser->store_cache( cache => 'config.cfg.cache' );
# (later, in another program... we load the cached version)
my $cfg = Config::Scoped->new( file => 'config.cfg' )->retrieve_cache;
use XML::Writer;
use IO::File;

my %hosts = (
    'name' => 'agatha',
    'addr' => '192.168.0.4',
);
my $FH = new IO::File('>netconfig.xml')
    or die "Unable to write to file netconfig.xml: $!\n";
my $xmlw = new XML::Writer( OUTPUT => $FH );
$xmlw->startTag('network');
print $FH "\n ";
$xmlw->startTag('host');
# note that we're not guaranteed any specific ordering of the
# subelements using this code
foreach my $field ( keys %hosts ) {
    print $FH "\n ";
    $xmlw->startTag($field);
    $xmlw->characters( $hosts{$field} );
    $xmlw->endTag;
}
print $FH "\n ";
$xmlw->endTag;
print $FH "\n";
$xmlw->endTag;
$xmlw->end;
$FH->close();
use XML::Simple;
my $config = XMLin('config.xml');
# work with $config->{stuff}
XMLout($config, OutputFile => $configfile );
my $config = XMLin('config.xml', NormalizeSpace => 2, ForceArray => ['service']);
$config->{hostname}->{interface}->{interface_name};
$config->{hostname}->{interface}->{ip_addr};
my $config = XMLin(
    'config.xml',
    NormaliseSpace => 2,
    ForceArray => ['interface'], # uses square brackets
    KeyAttr => { 'interface' => 'addr' }, # uses curly braces
);

use XML::LibXML;
my $prsr = XML::LibXML->new();
my $doc = $prsr->parse_file('config.xml');
my $root = $doc->documentElement();
my @children = $root->childNodes;
foreach my $node (@children){
    print $node->nodeName(). "\n";
}


my $root = $doc->documentElement();
my @children = $root->childNodes;
my $current = $children[2]; # second <host></host> element
@children = $current->childNodes();
$current = $children[1]; # first <service></service> element
print $current->textContent(); # 'HTTP'
# or, chain the steps together in a punctuation-heavy fashion (yuck):
print STDOUT (($root->childNodes())[2]->childNodes())[1]->textContent();


my $root = $doc->documentElement();
my @children = $root->childNodes;
my $current = $children[2]; # second <host></host> element
$current = $current->nextSibling; # move to third <host></host> element



my $root = $doc->documentElement();
my @children = $root->childNodes;
my $current = $children[5]; # <host></host> element for krosp
my @interface_nodes = $current->getChildrenByTagName('interface');

my $root = $doc->documentElement();
my @interface_nodes = $root->getElementsByTagName('interface');

foreach my $node ( @interface_nodes ) {
    $node->textContent(); # returns the contents of all child text nodes
}
foreach my $attribute ($node->attributes()){
    print $attribute->nodeName . ":" . $attribute->getValue() . "\n";
}
# or to retrieve a specific attribute:
print $node->getAttribute('name') if $node->hasAttribute('name');

my $textnode = $node->firstChild
    if ($node->firstChild->nodeType == XML_TEXT_NODE);
$textnode->setData('new information');
my $parent = $node->parentNode;
$parent->removeChild($node);
use XML::LibXML;
my $prsr = XML::LibXML->new();
$prsr->keep_blanks(0);
my $doc = $prsr->parse_file('config.xml');


my @children = $doc->findnodes('/network/*');
foreach my $node (@children){
    print "$node->nodeName()\n";
}

# we ask for the single node we're going to get back using a
# list context (the parens around $node) because findnodes()
# returns a NodeList object in a scalar context
my ($tnode) = $doc->findnodes('/network/host[2]/service[1]/text()');
print $tnode->data . "\n";
# or, if you'd like to do this in a way that allows for
# a query that could return multiple text nodes:
foreach my $tnode ($doc->findnodes('/network/host[2]/service[1]/text()')){
    print $tnode->data . "\n";
}


# find all of the hosts that currently provide more than one service
my @multiservers = $doc->findnodes('//host[count(service) > 1]');
# find their names (name attribute values) instead and print them
foreach my $anode ($doc->findnodes('//host[count(service) > 1]/@name')){
    print $anode->value . "\n";
}

use XML::LibXML;
use Readonly;
Readonly my $domain => '.example.edu';
# from the programs we wrote in Chapter 5
print GenerateHeader();
my $prsr = XML::LibXML->new();
$prsr->keep_blanks(0);
my $doc = $prsr->parse_file('config.xml');
# find all of the interface nodes of machines connected over Ethernet
foreach
my $interface ( $doc->findnodes('//host/interface[@type ="Ethernet"]') )
{
    # print a pretty comment for each machine with info retrieved via
    # DOM methods
    my $p = $interface->parentNode;
    print "\n; "
        . $p->getAttribute('name')
        . ' is a '
        . $p->getAttribute('type')
        . ' running '
        . $p->getAttribute('os') . "\n";
    # print the A record for the host
    #
    # yes, we could strip off the domain and whitespace using
    # a Perl regexp (and that might make more sense), but this is just
    # an example so you can see how XPath functions can be used
    my $arrname = $interface->find(
        " substring-before( normalize-space( arec / text() ), '$domain' ) ");
    print "$arrname \tIN A \t \t "
        . $interface->find('normalize-space(addr/text())') . " \n ";
    # find all of the CNAME RR and print them as well
    #
    # an example of using DOM and XPath methods in the same for loop
    # note: XPath calls can be computationally expensive, so you would
    # (in production) not want to place them in a loop in a loop
    foreach my $cnamenode ( $interface->getChildrenByTagName('cname') ) {
        print $cnamenode->find(
            " substring-before(normalize-space(./text()),'$domain')")
            . "\tIN CNAME\t$arrname\n";
    }



    # we could do more here, e.g., output SRV records ...
}

use strict;
use XML::Parser;
use YAML; # needed for display, not part of the parsing
my $parser = new XML::Parser(
    ErrorContext => 3,
    Style => 'Stream',
    Pkg => 'Config::Parse'
);
$parser->parsefile('config.xml');
print Dump( \%Config::Parse::hosts );
package Config::Parse;
our %hosts;
our $current_host;
our $current_interface;
sub StartTag {
    my $parser = shift;
    my $element = shift;
    my %attr = %_; # not @_, see the XML::Parser doc
    if ( $element eq 'host' ) {
        $current_host = $attr{name};
        $hosts{$current_host}{type} = $attr{type};
        $hosts{$current_host}{os} = $attr{os};
    }if ( $element eq 'interface' ) {
        $current_interface = $attr{name};
        $hosts{$current_host}{interfaces}{$current_interface}{type}
            = $attr{type};
    }
}
sub Text {
    my $parser = shift;
    my $text = $_;
    my $current_element = $parser->current_element();
    $text =~ s/^\s+|\s+$//g;
    if ( $current_element eq 'arec' or $current_element eq 'addr' ) {
        $hosts{$current_host}{interfaces}{$current_interface}
            {$current_element} = $text;
    }
    if ( $current_element eq 'cname' ) {
        push(
            @{ $hosts{$current_host}{interfaces}{$current_interface}{cnames}
                },
            $text
        );
    }
    if ( $current_element eq 'service' ) {
        push( @{ $hosts{$current_host}{services} }, $text );
    }
}
sub StartDocument { }
sub EndTag { }
sub PI { }
sub EndDocument { }
use XML::SAX;
use YAML; # needed for display, not part of the parsing
use HostHandler; # we'll define this in a moment
my $parser = XML::SAX::ParserFactory->parser( Handler => HostHandler->new );


open my $XML_DOC, '<', 'config.xml' or die "Could not open config.xml:$!";
# parse_file takes a filehandle, not a filename
$parser->parse_file($XML_DOC);
close $XML_DOC;
print Dump( \%HostHandler::hosts );


# %hosts is used to collect all of the parsed data
# (yes, we could keep this in the object itself)
my %hosts;
sub start_element {
    my ( $self, $element ) = @_;
    $self->_contents('');
    # these weird '{}something' hash keys are using James Clark notation;
    # we'll address this convention in a moment when we talk about
    # XML namespaces
    if ( $element->{LocalName} eq 'host' ) {
        $self->{current_host} = $element->{Attributes}{'{}name'}{Value};
        $hosts{ $self->{current_host} }{type}
            = $element->{Attributes}{'{}type'}{Value};
        $hosts{ $self->{current_host} }{os}
            = $element->{Attributes}{'{}os'}{Value};
    }
    if ( $element->{LocalName} eq 'interface' ) {
        $self->{current_interface} = $element->{Attributes}{'{}name'}{Value};
        $hosts{ $self->{current_host} }{interfaces}
            { $self->{current_interface} }{type}
            = $element->{Attributes}{'{}type'}{Value};
    }
    $self->{current_element} = $element->{LocalName};
    $self->SUPER::start_element($element);
}


sub characters {
    my ( $self, $data ) = @_;
    $self->_contents( $self->_contents() . $data->{Data} );
    $self->SUPER::characters($data);
}
sub _contents {
    my ( $self, $text ) = @_;
    $self->{'_contents'} = $text if defined $text;
    return $self->{'_contents'};
}


sub end_element {
    my ( $self, $element ) = @_;
    my $text = $self->_contents();
    $text =~ s/^\s+|\s+$//g; # remove leading/following whitespace
    if ( $self->{current_element} eq 'arec'
        or $self->{current_element} eq 'addr' )
    {
        $hosts{ $self->{current_host} }{interfaces}
            { $self->{current_interface} }{ $self->{current_element} }
            = $text;
    }
    if ( $self->{current_element} eq 'cname' ) {
        push(
            @{ $hosts{ $self->{current_host} }{interfaces}
                { $self->{current_interface} }{cnames}
                },
            $text
        );
    }
    if ( $self->{current_element} eq 'service' ) {
        push( @{ $hosts{ $self->{current_host} }{services} }, $text );
    }
    $self->SUPER::end_element($element);
}

use XML::Twig;
my $twig = XML::Twig->new(
    twig_roots => {
        # $_ gets set to the element here
        'host/interface' => sub { $_->print },
    },
    pretty_print => 'indented',
);
$twig->parsefile('config.xml');

use XML::Twig;
use LWP::Simple;
my %port_fix = ( 'DNS' => 'domain',
    'IMAP4' => 'imap',
    'firewall' => 'all' );
my $port_list_url = 'http://www.iana.org/assignments/port-numbers';
my %port_list = &grab_iana_list;
my $twig = XML::Twig->new(
    twig_roots => { 'host/service' => \&transform_service_tags },
    twig_print_outside_roots => 1,
);
$twig->parsefile('config.xml');
# change <service> -> <port> and add that service's port number
# as an attribute
sub transform_service_tags {
    my ( $twig, $service_tag ) = @_;
    my $port_number = (
        $port_list{ lc $service_tag->trimmed_text }
            or $port_list{ lc $port_fix{ $service_tag->trimmed_text } }
            or $port_fix{ lc $service_tag->trimmed_text }
    );
    $service_tag->set_tag('port');
    $service_tag->set_att( number => $port_number );
    $twig->flush;
}
# retrieve the IANA allocated port list from its URL and return
# a hash that maps names to numbers
sub grab_iana_list {
    my $port_page = get($port_list_url);
    # each line is of the form:
    # service port/protocol explanation
    # e.g.:
    # http 80/tcp World Wide Web HTTP
    my %ports = $port_page =~ /([\w-]+)\s+(\d+)\/(?:tcp|udp)/mg;
    return %ports;
}

use YAML qw(DumpFile); # finds and loads an appropriate YAML parser
my $config = YAML::LoadFile('config.yml');
# (later...) dump the config back out to a file
YAML::DumpFile( 'config.yml' , $config );

