# load the Win32-only modules and set the Win32-only global variables
if ( $^O eq 'MSWin32' ) {

}

sub DisposeAddQueue {
    my $queue = shift;
    our ( $accountdir, $addqueue, $maindata );
    my $db = DBM::Deep->new( $accountdir . $addqueue );
    foreach my $login ( keys %{$queue} ) {
        if ( $queue->{$login}{status} eq 'created' ) {
            $queue->{$login}{login} = $login;
            $queue->{$login}{creation_date} = time;
            AppendAccount( $accountdir . $maindata, $queue->{$login} );
            delete $queue->{$login}; # delete from in-memory representation
            delete $db->{$login}; # delete from disk database file
        }
    }
    my $db = DBM::Deep->new( $accountdir . $addqueue );
    my $queue = $db->import($queue);
}

use Account;
# read in our low-level routines
&InitAccount;
# read the contents of the del account "queue"
my $queue = ReadDelQueue();
# attempt to delete all accounts in the queue
ProcessDelQueue($queue);
# write account record to main database, or back to queue
# if there is a problem
DisposeDelQueue($queue);
# read in the add account queue to the $queue data structure
sub ReadDelQueue {
    our ( $accountdir, $delqueue );
    my $db = DBM::Deep->new( $accountdir . $delqueue );
    my $queue = $db->export();
    return $queue;
}

sub ProcessDelQueue {
    my $queue = shift;
    our $accountdel;
    foreach my $login ( keys %{$queue} ) {
        my $result = $accountdel->( $login, $queue->{$login} );
        if ( !defined $result ) {
            $queue->{$login}{status} = 'deleted';
        }
        else {
            $queue->{$login}{status} = 'error';
        }
    }
}

sub DisposeDelQueue {
    my $queue = shift;
    our ( $accountdir, $delqueue, $maindata );
    my $maindata = DBM::Deep->new( $accountdir . $maindata );
    my $delqueue = DBM::Deep->new( $accountdir . $delqueue );
    foreach my $login ( keys %{$queue} ) {
        if ( $queue->{$login}{status} eq 'deleted' ) {
            $maintada->{$login}{deletion_date} = time;
            delete $queue->{$login}; # delete from in-memory representation
            delete $delqueue->{$login}; # delete from on disk del queue file
        }
    }
    # All we have left in $queue at this point are the accounts that
    # could not be deleted. We merge these status changes back
    # into the delete queue for future action of some sort.
    $delqueue->import($queue);
}

use Account; # just to get the file locations
&InitAccount;
my $database = ReadMainDatabase();
WriteFiles($database);
# read the main database into a hash of hashes
sub ReadMainDatabase {
    our ( $accountdir, $maindata );
    my $db = DBM::Deep->new( $accountdir . $maindata );
    my $database = $db->export();
    return $database;
}
# Iterate through the keys, compile the list of accounts of a certain
# type, and store them in a hash of lists. Then write out the contents of
# each key to a different file.
sub WriteFiles {
    my $database = shift;
    our ( $accountdir, $maillists );
    my %types;
    foreach my $account ( keys %{$database} ) {
        next if $database->{$account}{status} eq 'deleted';
        push( @{ $types{ $database->{$account}{type} } }, $account );
    }
    foreach my $type ( keys %types ) {
        open my $OUT, '>', $maillists . $type
            or die 'Unable to write to ' . $maillists . $type . ": $!\n";
        print $OUT join( "\n", sort @{ $types{$type} } ) . "\n";
        close $OUT;
    }
}
# Module Information for This Chapter
#     Name CPAN ID Version
#         User::pwent (ships with Perl) 1.00
# File::stat (ships with Perl) 1.01
# Passwd::Solaris EESTABROO 1.2
# Passwd::Linux EESTABROO 1.2
# Win32API::Net JDB 0.12
# Win32::Security(::NamedObject, ::ACL) TEVERETT 0.50
# Win32::OLE JDB 0.1709
# Term::Prompt PERSICOM 1.04
# Crypt::PasswdMD5 LUISMUNOZ 1.3
# DBM::Deep RKINYON 1.0014
# Readonly ROODE 1.03
# Expect RGIERSIG 1.21
# File::Path (ships with Perl) DLAND 2.07
# Win32::FileOp JENDA 0.14.1