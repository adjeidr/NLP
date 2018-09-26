#!/usr/local/bin/perl -w
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 4: Word Sense Disambiguation, 3/26/18
Scorer file
Copares my-line-answers to key file
=end comment
=cut

($file1, $file2) = @ARGV;
open(my $answer, $file1) or die "Could not open file '$file1' $!";
open(my $key, $file2) or die "Could not open file '$file2' $!";

my @keys = ();
while ($line = <$key>){ #read key file
	chomp $line;
	@arr = split/\>\</, $line;
	push @keys, @arr;
}

while ($row = <$answer>){ #read my answers file
	chomp $row;
	@arr = split/\>\</,$row;
	push @answers, @arr;
}
#grab senses
for my $i(0..$#keys+1){
	my $str = $keys[$i];
	$str =~ /senseid="(.*)"/;
	$keys[$i] = $1;
}
# compare senses from both files
for my $i(0..$#answers+1){
	my $str = $answers[$i];
	$str =~ /senseid="(.*)"/;
  $match = $1;
	if ($match eq $keys[$i]){
		$ccc++;
	}
	$matrix{$keys[$i]}{$match}++;
}
#print matrix and score
$score = $ccc/($#keys+1);
$percentage = $score*100;
print "$percentage\% \n";
my @senses;
print "       ";
while ($key = each(%matrix)){
	if ($key =~ m/.+/){
		push(@senses, $key);
		print "|$key| ";
	}
}
print "\n";
for $i (0 .. $#senses){
	print "|$senses[$i]|   ";
    for $y (0 .. $#senses){
        if (exists $matrix{$senses[$i]}{$senses[$y]}){ #grab numbers of each sense
            print  $matrix{$senses[$i]}{$senses[$y]};
        }
        else{
            print "0";
        }
        print "   | ";	#spacing lines for easy reading
    }
    print "\n";
}
