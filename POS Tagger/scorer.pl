#!/usr/local/bin/perl -w
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 3: POS Tagging, 3/12/18
Problem: Score or determine the accuracy of the tagging done in tagger.pl
using the pos-test-with-tags.txt and pos-test-key.txt.
Example(s):
  perl scorer.pl pos-test-with-tags.txt pos-test-key.txt > pos-tagging-report.txt
Algorithm: Compares tagged test file to the key file provided and determines the
Accuracy of the comparison by comapring each word and its follwonig tag.
=end comment
=cut
($test, $key) = @ARGV; #gets 2 files provided, training file then test file
open ($wTags,$test) or die "Could not open $test: $!"; #open and read tagged test file
@tt = ();
@kk = ();
@all = ();
$matches = 0;
$totalWords = 0;
%matrix = ();
while(<$wTags>) {
	chomp;
	@input = split/\s+/, $_; #place every word character into local array
	push @tt, @input;        #push those words to a global array for the test
}
open ($Keyf,$key) or die "Could not open $key: $!"; #open and read key file
while(<$Keyf>) {
	chomp;
	@in = split/ +/, $_; #place every word character into local array
	push @kk, @in;       #push those words to a global array for the keys
}
for $i (0..$#kk){
  #count the words in the test corpus and compare against what is in the key file
  $txt = $kk[$i];
  if (not $txt =~ m/\[|\]/){ #trying to avoid the brackets
    $totalWords++;
    @tags = split/\//, $tt[$i];
    @keys = split/\//, $kk[$i];
    $tTag = $tags[$#tags]; #Tag at each word
    $kTag = $keys[$#keys]; #Tag at each word
  if ($tTag eq $kTag){ $matches++; } #count when the tags match between the files
		$matrix{$kTag}{$tTag}++;	#move key tags into matrix and test tags to matrix and count collisions
		$tagCorpus{$kTag}++;	#names of the tags
	}
}

$accuracy = ($matches/$totalWords)*100;	#score precentage into number greater than 0, Conversion
printf "Accuracy: %.2f", $accuracy;   #print accuracy
print "%";
print "\n----------------------\n";
print "\nConfusion Matrix:\n";        #print confusion matrix
print "----------------------\n";

while ($posTag = each(%tagCorpus)){
		push @all, $posTag;
		print "$posTag |"; #print all the possible tags
}

for $x (0 .. $#all){
    for $y (0 .. $#all){
      #print all the occurences at the tags
        if (exists $matrix{$all[$x]}{$all[$y]}){
            print  $matrix{$all[$x]}{$all[$y]};
        }
        else{
            print "0"; #if no occurences
        }
				#format the matrix outout
        print " | ";
    }
}
