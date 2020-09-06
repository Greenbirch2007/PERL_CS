use strict;
use warnings;
use DBI;

# assumes we have sendmail installed in /usr/sbin
# sendmail install directory varies based on OS/distribution
open my $SENDMAIL, '|-', '|/usr/sbin/sendmail -oi -t -odq' or
    die "Can't fork for sendmail: $!\n";
print $SENDMAIL <<'EOF';
From: User Originating Mail <me@host>
To: Final Destination <you@otherhost>Subject: A relevant subject line
Body of the message goes here after the blank line
in as many lines as you like.
EOF
close(SENDMAIL) or warn "sendmail didn't close nicely";

$address = "fred@example.com"; # array interpolates

$address = "fred\@example.com";
$address = 'fred@example.com';
$address = q{ fred@example.com };
$address = join('@', 'fred', 'example.com');
use MacPerl;
my $to = 'user@example.com';
my $subject = 'Hi there';
my $body = 'message body';
MacPerl::DoAppleScript(<<EOAS);
tell application "Mail"
 set theNewMessage to make new outgoing message with properties
 {subject:"$subject", content:"$body", visible:true}
 tell theNewMessage
 make new to recipient at end of to recipients with properties
 {address:"$to"}
 send
 end tell
end tell
EOAS

use Win32::OLE;
use Win32::OLE::Const 'Microsoft Outlook';
my $outl = Win32::OLE->new('Outlook.Application');
my $ol = Win32::OLE::Const->Load($outl);
my $message = $outl->CreateItem(olMailItem);
$message->Recipients->Add('user@example.edu');
$message->{Subject} = 'Perl to Outlook Test';
$message->{Body} = "Hi there!\n\nLove,\nPerl\n";
$message->Send;

use Mail::Outlook;
my $outl = new Mail::Outlook();
my $message = $outl->create();
$message->To('user@example.edu');
$message->Subject('Perl to Outlook Test');
$message->Body("Hi there!\n\nLove,\nPerl\n");
$message->Attach(@files);
$message->send() or die "failed to send message";

my $message = <<'EOM';
From: motherofallthings@example.org
To: dnb@example.edu
Subject: advice
I am the mother-of-all-things and all things should wear a sweater.
 Love,
 Mom
EOM

use Email::Simple;
use Email::Simple::Creator;
use Email::Send;
my $message = Email::Simple->create(
    header => [
        From => 'motherofallthings@example.org',
        To => 'dnb@example.edu',
        Subject => 'Test Message from Email::Simple::Creator',
    ],
    body => "Hi there!\n\tLove,\n\tdNb",
);

my $sender = Email::Send->new({mailer => 'SMTP'});
$sender->mailer_args([Host => 'smtp.example.edu']);
$sender->send($message) or die "Unable to send message!\n";
my $sender = Email::Send->new({mailer => 'Sendmail'});
$Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';
$sender->send($message) or die "Unable to send message: $!\n";

use Email::Simple;
use Email::MIME::Creator;
use File::Slurp qw(slurp);
use Email::Send;
my @mimeparts = (
    Email::MIME->create(
        attributes => {
            content_type => 'text/plain',
            charset => 'US-ASCII',
        },
        body => "Hi there!\n\tLove,\n\tdNb\n",
    ),
    Email::MIME->create(
        attributes => {
            filename => 'picture.jpg',
            content_type => 'image/jpeg',
            encoding => 'base64',
            name => 'picture.jpg',
        },
        body => scalar slurp('picture.jpg'),
    ),
);
my $message = Email::MIME->create(
    header => [
        From => 'motherofallthings@example.org',
        To => 'dnb@example.edu',
        Subject => 'Test Message from Email::MIME::Creator',
    ],
    parts => [@mimeparts],
);
my $sender = Email::Send->new({mailer => 'Sendmail'});
$Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';
$sender->send($message) or die "Unable to send message!\n";

use Email::MIME::CreateHTML;
use Email::Send;
my $annoyinghtml=<<HTML;
<html>
<body>
Hi there!<br />
&nbsp;&nbsp;Love,<br />
&nbsp;&nbsp;<em>dNb</em>
<body>
<html>
HTML
my $message = Email::MIME->create_html(
    header => [
        From => 'motherofallthings@example.org',To => 'dnb@example.edu',
        Subject => 'Test Message from Email::MIME::CreateHTML',
    ],
    body => $annoyinghtml,
    text_body => "Hi there!\n\tLove,\n\tdNb",
);
my $sender = Email::Send->new( { mailer => 'Sendmail' } );
$Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';
$sender->send($message) or die "Unable to send message!\n";

my $last_sent = time;
use Email::Simple;
use Email::Simple::Creator;
use Email::Send;
use Text::Wrap;
use File::Spec;
# the list of machines reporting in
my $repolist = '/project/machinelist';
# the directory where they write files
my $repodir = '/project/reportddir';
# send mail "from" this address
my $reportfromaddr = 'project@example.com';
# send mail to this address
my $reporttoaddr = 'project@example.com';
my $statfile; # the name of the file where status reports are recorded
my $report; # the report line found in each statfile
my %success; # the succesful hosts
my %fail; # the hosts that failed
my %missing; # the list of hosts missing in action (no reports)
# Now we read the list of machines reporting in into a hash.
# Later, we'll depopulate this hash as each machine reports in,
# leaving behind only the machines that are missing in action.
open my $LIST, '<', $repolist or die "Unable to open list $repolist:$!\n";
while (<$LIST>) {
    chomp;
    $missing{$_} = 1;
}
close $LIST;
# total number of machines that should be reporting
my $machines = scalar keys %missing;
# Read all of the files in the central report directory.
# Note: this directory should be cleaned out automatically
# by another script.
opendir my $REPO, $repodir or die "Unable to open dir $repodir:$!\n";

while ( defined( $statfile = readdir($REPO) ) ) {
    next unless -f File::Spec->catfile( $repodir, $statfile );
    # open each status file and read in the one-line status report
    open my $STAT, File::Spec->catfile( $repodir, $statfile )
        or die "Unable to open $statfile:$!\n";
    chomp( $report = <$STAT> );
    my ( $hostname, $result, $details ) = split( ' ', $report, 3 );
    warn "$statfile said it was generated by $hostname!\n"
        if ( $hostname ne $statfile );
    # hostname is no longer considered missing
    delete $missing{$hostname};
    # populate these hashes based on success or failure reported
    if ( $result eq 'success' ) {
        $success{$hostname} = $details;
    }
    else {
        $fail{$hostname} = $details;
    }
    close $STAT;
    # we could remove the $statfile here to clean up for the
    # next night's run, but only if that works in your setup
}
closedir $REPO;
# construct a useful subject for our mail message
my $subject;
if ( scalar keys %success == $machines ) {
    $subject = "[report] Success: $machines";
}
elsif ( scalar keys %fail == $machines or
    scalar keys %missing >= $machines ) {
    $subject = "[report] Fail: $machines";
}
else {
    $subject
        = '[report] Partial: '
        . keys(%success)
        . ' ACK, ' .
        keys(%fail) . ' NACK'
        . ( (%missing) ? ', ' . keys(%missing) . ' MIA' : '' );
}
# create the body of the message
my $body = "Run report from $0 on " . scalar localtime(time) . "\n";
if ( keys %success ) {
    $body .= "\n==Succeeded==\n";
    foreach my $hostname ( sort keys %success ) {
        276 | Chapter 8: Email
            $body .= "$hostname: $success{$hostname}\n";
    }
}
if ( keys %fail ) {
    $body .= "\n==Failed==\n";
    foreach my $hostname ( sort keys %fail ) {
        $body .= "$hostname: $fail{$hostname}\n";
    }
}
if ( keys %missing ) {
    $body .= "\n==Missing==\n";
    $body .= wrap( '', '', join( ' ', sort keys %missing ) ), "\n";
}
my $message = Email::Simple->create(
    header => [
        From => $reportfromaddr,
        To => $reporttoaddr,
        Subject => $subject,
    ],
    body => $body,
);
my $sender = Email::Send->new( { mailer => 'Sendmail' } );
$Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';
$sender->send($message) or die "Unable to send message!\n";


use IO::Socket;
use Text::Wrap; # used to make the output prettier
# the list of machines reporting in
my $repolist = '/project/machinelist';
# the port number clients should connect to
my $serverport = '9967';
my %success; # the succesful hosts
my %fail; # the hosts that failed
my %missing; # the list of hosts missing in action (no reports)
# load the machine list using a hash slice (end result is a hash
# of the form %missing = { key1 => undef, key2 => undef, ...})
@missing{ loadmachines() } = ();
my $machines = keys %missing;
# set up our side of the socket
my $reserver = IO::Socket::INET->new(
    LocalPort => $serverport,
    Proto => "tcp",
    Type => SOCK_STREAM,
    Listen => 5,
    Reuse => 1
) or die "Unable to build our socket half: $!\n";
# start listening on it for connects
while ( my ( $connectsock, $connectaddr ) = $reserver->accept() ) {
    # the name of the client that has connected to us
    my $connectname
        = gethostbyaddr( ( sockaddr_in($connectaddr) )[1], AF_INET );
    chomp( my $report = $connectsock->getline );
    my ( $hostname, $result, $details ) = split( ' ', $report, 3 );
    # if we've been told to dump our info, print out a ready-to-go mail
    # message and reinitialize all of our hashes/counters
    if ( $hostname eq 'DUMPNOW' ) {
        printmail($connectsock);
        close $connectsock;
        undef %success;
        undef %fail;
        undef %missing;@missing{ loadmachines() } = (); # reload the machine list
        my $machines = keys %missing;
        next;
    }
    warn "$connectname said it was generated by $hostname!\n"
        if ( $hostname ne $connectname );
    delete $missing{$hostname};
    if ( $result eq 'success' ) {
        $success{$hostname} = $details;
    }
    else {
        $fail{$hostname} = $details;
    }
    close $connectsock;
}
close $reserver;
sub printmail {
    my $socket = shift;
    my $subject;
    if ( keys %success == $machines ) {
        $subject = "[report] Success: $machines";
    }
    elsif ( keys %fail == $machines or keys %missing >= $machines ) {
        $subject = "[report] Fail: $machines";
    }
    else {
        $subject
            = '[report] Partial: '
            . keys(%success)
            . ' ACK, ' .
            keys(%fail) . " NACK"
            . ( (%missing) ? ', ' . keys(%missing) . ' MIA' : '' );
    }
    print $socket "$subject\n";
    print $socket "Run report from $0 on " . scalar localtime(time) . "\n";
    if ( keys %success ) {
        print $socket "\n==Succeeded==\n";
        foreach my $hostname ( sort keys %success ) {
            print $socket "$hostname: $success{$hostname}\n";
        }
    }
    if ( keys %fail ) {
        print $socket "\n==Failed==\n";
        foreach my $hostname ( sort keys %fail ) {
            Common Mistakes in Sending Email | 279
            print $socket "$hostname: $fail{$hostname}\n";
        }
    }
    if ( keys %missing ) {
        print $socket "\n==Missing==\n";
        print $socket wrap( '', '', join( ' ', sort keys %missing ) ), "\n";
    }
}
# loads the list of machines from the given file
sub loadmachines {
    my @missing;
    open my $LIST, '<', $repolist or die "Unable to open list $repolist:$!\n";
    while (<$LIST>) {
        chomp;
        push( @missing, $_ );
    }
    close $LIST;
    return @missing;
}
use IO::Socket;
# the port number clients should connect to
my $serverport = '9967';
# the name of the server
my $servername = 'reportserver';
# name-to-IP address mapping
my $serveraddr = inet_ntoa( scalar gethostbyname($servername) );
my $reportfromaddr = 'project@example.com';
my $reporttoaddr = 'project@example.com';
my $reserver = IO::Socket::INET->new(
    PeerAddr => $serveraddr,
    PeerPort => $serverport,
    Proto => 'tcp',
    Type => SOCK_STREAM
) or die "Unable to build our socket half: $!\n";
if ( $ARGV[0] ne '-m' ) {
    print $reserver $ARGV[0];
}
else {
    # These 'use' statements will load their respective modules when the
    # script starts even if we don't get to this code block. We could use
    # require/import instead (like we did in Chapter 3), but the goal here
    # is to just make it clear that these modules come into play when we
    # use the -m switch.
    use Email::Simple;
    use Email::Simple::Creator;
    use Email::Send;
    print $reserver "DUMPNOW\n";
    chomp( my $subject = <$reserver> );
    my $body = join( '', <$reserver> );
    my $message = Email::Simple->create(
        header => [
            From => $reportfromaddr,
            To => $reporttoaddr,
            Subject => $subject,
        ],
        body => $body,
    );
    my $sender = Email::Send->new( { mailer => 'Sendmail' } );
    $Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';
    $sender->send($message) or die "Unable to send message!\n";
}
close $reserver;

use Text::Wrap;
use Carp qw(longmess);
sub problemreport {
    # $shortcontext should be a one-line description of the problem
    # $usercontext should be a detailed description of the problem
    # $nextstep should be the best suggestion for how to remedy the problem
    my ( $shortcontext, $usercontext, $nextstep ) = @_;
    my ( $filename, $line, $subroutine ) = ( caller(1) )[ 1, 2, 3 ];
    my $report = '';
    $report .= "Problem with $filename: $shortcontext\n";
    $report .= "*** Problem report for $filename ***\n\n";
    $report .= fill( '', ' ', "- Problem: $usercontext" ) . "\n\n";
    $report
        .= "- Location: line $line of file $filename in " . "$subroutine\n\n";
    $report .= longmess('Stack trace ') . "\n";
    $report .= '- Occurred: ' . scalar localtime(time) . "\n\n";
    $report .= "- Next step: $nextstep\n";
    return $report;
}
sub fireperson {
    my $report = problemreport( 'the computer is on fire', <<EOR, <<EON);
While running the accounting report, smoke started pouring out of the
back of the machine. This occurred right after we processed the
pension plan.
EOR
Please put fire out before continuing.
EON
    print $report;
}
fireperson();

use Mail::POP3Client;
my $pop3 = new Mail::POP3Client(
    USER => 'user',
    PASSWORD => 'secretsquirrel',
    HOST => 'pop3.example.edu',
    USESSL => 'true',
);
die 'Connection failed: ' . $pop3->Message() . "\n"
    if $pop3->Count() == −1;
print 'Number of messages in this mailbox: ' . $pop3->Count() . "\n\n";
print "The first message looks like this: \n" . $pop3->Retrieve(1) . "\n";
$pop3->Close();

use IO::Socket::SSL;
use Mail::IMAPClient;
my $s = IO::Socket::SSL->new(PeerAddr =>'imap.example.com',
    PeerPort => '993',
    Proto => 'tcp');
die $@ unless defined $s;
my $m = Mail::IMAPClient->new(User => 'user', Socket=>$s,
    Password => 'topsecret');
my $greeting = <$s>;
my ( $id, $answer ) = split /\s+/, $greeting;
die "connect problem: $greeting" if $answer ne 'OK';

$m->State( Mail::IMAPClient::Connected() );
$m->login() or die 'login(): ' . $m->LastError();

$m->select('INBOX');
my @spammsgs = $m->search(qw(HEADER X-Spam-Flag YES));
die $@ if $@;
foreach my $msg (@spammsgs){
    $m->move('SPAM', $msg) or die 'move failed: '.$m->LastError;
}
$m->close(); # expunges currently selected folder
$m->logout;

my @digests = $m->search(qw(SUBJECT digest));
foreach my $msg (@digests) {
    my $struct = $m->get_bodystructure($msg);
    next unless defined $struct;
    # Messages in a mailbox get assigned both a sequence number and
    # a unique identifier. By default Mail::IMAPClient works with UIDs.
    print "Message with UID $msg (Content-type: ",$struct->bodytype,'/',
        $struct->bodysubtype,
        ") has this structure:\n\t",
        join("\n\t",$struct->parts) ,"\n\n";
}
$m->logout;

print $m->bodypart_string(29691,'4');
use Email::Simple;
my $message = <<'EOM';From user@example.edu Mon Aug 6 05:43:22 2007
Received: from localhost (localhost [127.0.0.1])
 by zimbra.example.edu (Postfix) with ESMTP id 6A39577490A
 for <dnb@example.edu>; Mon, 6 Aug 2007 05:43:22 −0400 (EDT)
Received: from zimbra.example.edu ([127.0.0.1])
 by localhost (zimbra.example.edu [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id OIIgygSczEdt for <dnb@zimbra.example.edu>;
 Mon, 6 Aug 2007 05:43:22 −0400 (EDT)
Received: from amber.example.edu (amber.example.edu [192.168.16.51])
 by zimbra.example.edu (Postfix) with ESMTP id 2828A774909
 for <dnb@zimbra.example.edu>; Mon, 6 Aug 2007 05:43:22 −0400 (EDT)
Received: from chinese.example.edu ([192.168.16.212])
 by amber.example.edu with esmtps (TLSv1:DHE-RSA-AES256-SHA:256)
 (Exim 4.50)
 id 1IHzA6-0002GV-7g
 for dnb@example.edu; Mon, 06 Aug 2007 05:46:06 −0400
Date: Mon, 6 Aug 2007 05:46:06 −0400 (EDT)
From: My User <user@example.edu>
To: "David N. Blank-Edelman" <dnb@example.edu>
Subject: About mail server
Message-ID: <Pine.GSO.4.58.0708060544550.2793@chinese.example.edu>
Hi David,
Boy, that's a spiffy mail server you have there!
Best,
Your User
EOM
my $esimple = Email::Simple->new($message);

my @received = $esimple->header('Received');
my $first_received = $esimple->header('Received');
print scalar $esimple->header('Date');

use Email::MIME;
use File::Slurp qw(slurp write_file);
my $message = slurp('mime.txt');
my $parsed = Email::MIME->new($message);
foreach my $part ($parsed->parts) {
    if ($part->content_type =~ /^application\/pdf;/i){
        write_file ($part->filename, $part->body);
    }
}

my @dirty_words = qw ( sod ground soil earth filth mud shmutz );
foreach my $word (@dirty_words){
    return 'dirty' if ($body =~ /$word/is);
}

my $wordalt = join('|',@dirty_words);
my $regex = qr/$wordalt/is;
return 'dirty' if ($message =~ $regex);

use Text::Match::FastAlternatives;
use Email::Simple;
use File::Slurp qw(slurp);
my $message = slurp('message.txt');
my $esimple = Email::Simple->new($message);
my @dirty_words = qw ( sod ground soil earth filth mud shmutz );
# this gets much more impressive when the size of the list is huge
my $matcher = Text::Match::FastAlternatives->new( @dirty_words );
print 'dirty' if $matcher->match( $esimple->body() );

my $matcher = Text::Match::FastAlternatives->new( map { lc } @dirty_words );
print 'dirty' if $matcher->match( lc $esimple->body() );

use File::Slurp qw(slurp);
use Email::Simple;
use Regexp::Common qw /URI/;
my $esimple = Email::Simple->new( scalar slurp $ARGV[0] );
my $body = $esimple->body;
while ( $body =~ /$RE{URI}{HTTP}{-keep}/g ) {
    print "$1\n";
}

use Email::Folder;
my $folder = Email::Folder->('FilenameOrDirectory');

my @messages = $folder->messages;
foreach my $message ($folder->next_message){
    ... # do something with that message object
}
$subject = $message->header('Subject');
$subject = $folder->next_message->header('Subject');
use Mail::SpamAssassin;
use File::Slurp qw(slurp);
my $spama = Mail::SpamAssassin->new();
my $message = $spama->parse(scalar slurp 'message.txt');
my $status = $spama->check($message);
print (($status->is_spam()) ? 'spammy!' : "hammy!" . "\n");
$status->finish();
$message->finish();

use Mail::SpamAssassin;
use File::Slurp qw(slurp);
my $spama = Mail::SpamAssassin->new();
my $message = $spama->parse(scalar slurp 'message.txt');
my @received = $message->header('Received');
# or, to retrieve only the last one (as opposed to the first one,
# which most packages give you when called in a scalar context):
# my $received = $message->header('Received');
$message->finish();
use Mail::SpamAssassin;
use File::Slurp qw(slurp);
my $sa = Mail::SpamAssassin->new();
my $message = $sa->parse( scalar slurp 'mime.txt' );
my @html_parts = $message->find_parts( qr(text/html), 1 );
foreach my $part (@html_parts) {
    print @{ $part->raw() };
}
$message->finish();

$message->find_parts(qr/./,1);

use Mail::SpamAssassin;
use File::Slurp qw(slurp);
use List::MoreUtils qw(uniq);
my $sa = Mail::SpamAssassin->new();
my $status = $sa->check_message_text( scalar slurp 'spam.txt' );
my $uris = $status->get_uri_detail_list();
my @domains;
foreach my $uri ( keys %{$uris} ) {
    next if $uri =~ /^mailto:/;
    push( @domains, keys %{ $uris->{$uri}->{domains} } );
}
print join( "\n", uniq @domains );

use Email::ARF::Report;
use File::Slurp qw(slurp);
my $message = slurp('arfsample1.txt');
my $report = Email::ARF::Report->new($message);
foreach my $header (qw(to date subject message-id)) {
    print ucfirst $header . ': '
        . $report->original_email->header($header) . "\n";
}

use Email::Simple;
use List::MoreUtils qw(uniq);
use File::Slurp qw(slurp);
my $localdomain = ".example.edu";
# read in our host file
open my $HOSTS, '<', '/ccs/etc/hosts' or die "Can't open hosts file\n";
my $machine;
my %machines;
while ( defined( $_ = <$HOSTS> ) ) {
    next if /^#/; # skip comments
    next if /^$/; # skip blank lines
    next if /monitor/i; # an example of a misleading host
    $machine = lc( (split)[1] ); # extract the first host name & downcase
    $machine =~ s/\Q$localdomain\E//oi; # remove our domain name
    $machines{$machine}++ unless $machines{$machine};
}
close $HOSTS;
# parse the message
my $message = new Email::Simple( scalar slurp( $ARGV[0] ) );
my @found;
# check in the subject line
if ( @found = check_part( $message->header('Subject'), \%machines ) ) {
    print 'subject: ' . join( ' ', @found ) . "\n";
    exit;
}
# check in the body of the message
if ( @found = check_part( $message->body, \%machines ) ) {
    print 'body: ' . join( ' ', @found ) . "\n";
    exit;
}
# last resort: check the last Received line
my $received = ( reverse $message->header('Received') )[0];
$received =~ s/\Q$localdomain\E//g;
if ( @found = check_part( $received, \%machines ) ) {
    print 'received: ' . join( ' ', @found ) . "\n";
}
# find all unique matches from host lookup table in given part of message
sub check_part {
    my $part = shift; # the text from that message part
    my $machines = shift; # a reference to the machine lookup table
    $part =~ s/[^\w\s]//g;
    $part =~ s/\n/ /g;
    return uniq grep { exists $machines->{$_} } split( ' ', lc $part );
}

use Email::Simple;
use File::Slurp qw(slurp);
use DB_File;
my $localdomain = '.example.com';
my $printdb = 'printdb';
# parse the message
my $message = new Email::Simple( scalar slurp $ARGV[0] );
# check in the subject line
my $subject = $message->header('Subject');
if ( $subject =~ /print(er)?/i ) {# find sending machine
    my $received = ( reverse $message->header('Received') )[0];
    my ($host) = $received =~ /\((\S+)\Q$localdomain\E \[/;
    tie my %printdb, 'DB_File', $printdb
        or die "Can't tie $printdb database:$!\n";
    print "Problem on $host may be with printer " . $printdb{$host} . ".\n";
    untie %printdb;
}

