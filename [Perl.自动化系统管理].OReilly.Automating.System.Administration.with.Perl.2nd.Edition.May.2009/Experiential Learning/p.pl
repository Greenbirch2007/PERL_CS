use strict;
use warnings;
use DBI;

my $event = Schedule::Cron::Events( $cronline, Seconds => {some time} );
use IO::File;
use XML::Writer;
# set up a place to put the output
my $output = new IO::File('>output.xml');
# create a new XML::Writer object with some pretty-printing turned on
my $writer
    = new XML::Writer( OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2 );
# create a <sometag> start tag with the given attributes
$writer->startTag('sometag', Attribute1 => 'value', Attribute2 => 'value' );
# just FYI: we could leave out the tag name here and it will try to
# figure out which one to close for us
$writer->endTag('sometag');
$writer->end();
$output->close();

use Schedule::Cron::Events;
use File::Slurp qw( slurp ); # we'll read the crontab file with this
use Time::Local; # needed for date format conversion
use POSIX qw(strftime); # needed for date formatting
use XML::Writer;
use IO::File;
my ( $currentmonth, $currentyear ) = ( localtime( time() ) )[4,5];
my $monthstart = timelocal( 0, 0, 0, 1, $currentmonth, $currentyear );

my @cronlines = slurp('crontab');
chomp(@cronlines);
my $output = new IO::File('>output.xml');
my $writer
    = new XML::Writer( OUTPUT => $output, DATA_MODE => 1,
    DATA_INDENT => 2 );
$writer->startTag('data');

foreach my $cronline (@cronlines) {
    next if $cronline =~ /^#/; # skip comments
    next if $cronline =~ /^\s*\w+\s*=/; # skip variable definitions
    my $event
        = new Schedule::Cron::Events( $cronline, Seconds => $monthstart );
    my @nextevent;
    while (1) {
        @nextevent = $event->nextEvent;
        # stop if we're no longer in the current month
        last if $nextevent[4] != $currentmonth;
        $writer->startTag('event',
            'start' => strftime('%b %d %Y %T %Z',@nextevent),
            'title' => $event->commandLine(),
        );
        $writer->endTag('event');
    }
}
$writer->endTag('data');
$writer->end();
$output->close();
use XMLRPC::Lite;
my $reply = XMLRPC::Lite
    -> proxy ( 'http://rpc.geocoder.us/service/xmlrpc' )
    -> geocode('1005 Gravenstein Highway North, Sebastopol, CA')
    -> result;
foreach my $answer (@{$reply}){
    print 'lat: ' . $answer->{'lat'}
        . ' long: ' . $answer->{'long'} . "\n";
}

print 'lat: ' . $reply->[0]->{'lat'} .
    'long: ' . $reply->[0]->{'long'} . "\n";

use LWP::Simple;
use URI::Escape;
use XML::Simple;
# usage: scriptname <location to geocode>
my $appid = '{your API key here}';
my $requrl = 'http://api.local.yahoo.com/MapsService/V1/geocode';
my $request
    = $requrl . "?appid=$appid&output=xml&location=" . uri_escape( $ARGV[0] );
my $response = XMLin( get($request), forcearray => ['Result'] );
foreach my $answer ( @{ $response->{'Result'} } ) {
    print "Lat: $answer->{Latitude} Long: $answer->{Longitude} \n";
}
use HTML::GoogleMaps;
# '1005 Gravenstein Highway North, Sebastopol, CA'
# though we could also specify the address and let the module call
# Geo::Coder::Google for us
my $coords = [ −122.841571, 38.411239 ];
my $map
    = HTML::GoogleMaps->new( key => '{your API KEY HERE}' );
$map->center($coords); # center it on the address
$map->v2_zoom(15); # zoom closer than the default
# add a marker at the address using the given html as a label
# (and don't change the size of that label)
$map->add_marker(
    point => $coords,
    noformat => 1,
    html => "<a href='http://www.oreilly.com'>O'Reilly</a> HQ"
);
# add some map controls (zoom, etc.)
$map->controls( 'large_map_control', 'map_type_control' );
# create the parts of the map
my ( $head, $map_div ) = $map->onload_render;
# output the HTML (plus CGI-required Content-Type header) for that map
print "Content-Type: text/html\n\n";
print <<"EOH";
<html>
 <head>
 <title>Otter Demo</title>
 $head
 </head>
EOH
print
    "<body onload=\"html_googlemaps_initialize()\" onunload=\"GUnload()\">
 $map_div </body> </html>\n";
use Net::DNS;
my $resolv = Net::DNS::Resolver->new;
my $query = $resolv->search( $ARGV[0] );
die 'No response for that query' if !defined $query;
# only print addresses found in A resource records
foreach my $resrec ( $query->answer ){
    print $resrec->address . "\n" if ($resrec->type eq 'A');
}

use LWP::Simple;
use Text::CSV_XS; # this is the faster version of Text::CSV
# usage: scriptname <IP address to geocode>
my $maxmkey = '{your API key here}';
my $requrl = "http://maxmind.com:8010/f?l=$maxmkey&i=$ARGV[0]";
my $csvp = Text::CSV_XS->new(); # (or Text::CSV->new())
$csvp->parse( get($requrl) );
my ($country, $region, $city, $postal,
    $lat, $lon, $metro_code, $area_code,

    $isp, $org, $err
) = $csvp->fields();

use Geo::IP;
my $gi = Geo::IP->open( 'GeoIPCity.dat', GEOIP_STANDARD );
my $record = $gi->record_by_name( $ARGV[0] );
print join( "\n",
    $record->country_code, $record->country_code3, $record->country_name,
    $record->region, $record->region_name, $record->city,
    $record->postal_code, $record->latitude, $record->longitude,
    $record->time_zone, $record->area_code, $record->continent_code,
    $record->metro_code );
use LWP::Simple;
use Text::CSV_XS;
use XML::RSS;
my $maxmkey = '{your API key here}';
my $requrl = "http://maxmind.com:8010/f?l=$maxmkey&i=$ENV{'REMOTE_ADDR'}";
my $csvp = Text::CSV_XS->new();
$csvp->parse( get($requrl) );
my ($country, $region, $city, $postal,
    $lat, $lon, $metro_code, $area_code,
    $isp, $org, $err
Playing with Geocoding | 543
    ) = $csvp->fields();
print "Content-Type: text/html\n\n";
print << "EOH";
<html><head><title>Otterbook test</title></head>
<body>
EOH
print "<p>Hi there " . $ENV{'REMOTE_ADDR'} . "!</p>\n";
if ($postal) {
    my $rss = new XML::RSS;
    $rss->parse( get("http://xml.weather.yahoo.com/forecastrss?p=$postal") );
    print '<h1>' . $rss->{items}[0]->{'title'} . "</h1>\n";
    print $rss->{items}[0]->{'description'}, "\n";
}
print "</body></html>\n";
use MP3::Info;
my $mp3 = get_mp3info($file);
use File::Find::Rule::MP3Info;
# Which mp3s haven't I set the artist tag on yet?
my @mp3s = find( mp3info => { ARTIST => '' }, in => '/mp3' );
# What have I got that's 3 minutes or longer?
@mp3s = File::Find::Rule::MP3Info->file()
    ->mp3info( MM => '>=3' )
    ->in( '/mp3' );
# What have I got by either Kristin Hersh or Throwing Muses?
# I'm sometimes lazy about case in my tags.
@mp3s = find( mp3info =>
    { ARTIST => qr/(kristin hersh|throwing muses)/i },
    in => '/mp3' );
use WWW::Mechanize;
my $mech = WWW::Mechanize->new();
# get() can also take a ":content_file" parameter
# to save the returned information to a file
$mech->get($url);
my $pagecontents = $mech->content();
use WWW::Mechanize;
my $mech = WWW::Mechanize->new();
$mech->get( 'http://www.amazon.com' );
$mech->follow_link( text => 'Help' );
print $mech->uri . "\n";
# prints out something like:
# http://www.amazon.com/gp/help/customer/display.html?ie=UTF8&nodeId=508510
use WWW::Mechanize;
use Readonly;
Readonly my $loginurl => 'http://otterbook.example.org/otterbook/login';
Readonly my $revurl =>
    'http://otterbook.example.org/otterbook/wiki/ReviewerLocation';

Readonly my $user => 'username';
Readonly my $pass => 'password';
my $mech = WWW::Mechanize->new();
$mech->get($loginurl);
$mech->submit_form(
    form_number => 2,
    fields => { user => $user, password => $pass },
);

use HTML::TableExtract;
my $te = HTML::TableExtract->new( headers => [qw(City State/etc Country )] );

$te->parse( $mech->content() );

# rows() with no arguments works with the first table found by default.
# Since there's only one table on the page, this is a safe thing to do.
#
# $row is a reference to an anonymous array, and each element is a column
# from that row
my @reviewlocations;
foreach my $row ( $te->rows ) {
    # the trac wiki adds spurious newlines into its HTML table code
    chomp (@$row);
    push @reviewlocations, $row;
}
use Geo::Coder::Google;
use Geo::Google::StaticMaps;
...
sub locate {
    my $place = shift;
    # we could initialize this outside of this routine and pass the object
    # in to the routine with the query
    my $geocoder
        = Geo::Coder::Google->new( apikey => '{your API key here}' );
    my $response;
    until ( defined $response ) {
        $response = $geocoder->geocode( location => $place );
    }
    my ( $long, $lat ) = @{ $response->{Point}{coordinates} };
    return $lat, $long;
}

my @markers;
# create a list of hashes, each hash containing the info for
# that marker (lat/long, size, etc.)
foreach my $location (@reviewlocations) {
    push @markers, {
        point => [ locate( join( ',', @$location ) ) ],
        size => 'mid' };
}
my $url = Geo::Google::StaticMaps->url(
    key => '{your API key here}',
    size => [ 640, 640 ],
    markers => [@markers],
);

my $url = Geo::Google::StaticMaps->url(
    key => '{your API key here}',
    size => [ 640, 640 ],
    markers => [@markers],
    center => [ locate('Kansas, US') ],
    zoom => 3,
);

