use strict;
use warnings;

open(GRADES,"grades") or die "Can't open grades:$!\n";
while(my $line=<GRADES>){
    my ($student,$grade) = split("",$line);
    $grades{$student} .= $grade."";

}

foreach $student (sort keys %grades){
    my $scores = 0;
    my $total = 0;
    @grades  = split("",$grades{$student});
    foreach $grade(@grades){
        $scores++;
    }

    $average = $total /$scores;
    print
}