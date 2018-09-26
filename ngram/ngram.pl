#!/usr/local/bin/perl -w
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 2: ngram, 2/7/17
Problem: The program should randomly generate a number of sentences based on
a corpus provided through the arguments in command line and is based
on an n gram model.
Example(s):
    input: perl ngram.pl 2 10 file1.txt file2.txt...
    output: madam went come to yesterday.
Algorithm: Relies on method from lecture slides to create frequency table
but then randomness is used to generate sentences. Using the amount
specified before runtime.
=end comment
=cut

use Data::Dumper qw(Dumper);
my ($n,$sentences,$files) = @ARGV;
my %hash1 = ();
my %hash2 = ();
my $hybrid = 0.00;
my @sentencearr = ('This is the first sentence:');
my $create = "";

while(<>) {
  chomp;
  #Check for sentence punctuation in order to manipulate string before the split
  #Note: the input file are handled line by line
  lc($_); #to sure a more accruate amount of collisions
  #regex's to treat punctuation as words and remove quotation marks
  $_ =~ s/\./ . /g;
  $_ =~ s/,/ , /g;
  $_ =~ s/!/ ! /g;
  $_ =~ s/\?/ ? /g;
  $_ =~ s/://g;
  $_ =~ s/;//g;
  $_ =~ s/'//g;
  $_ =~ s/"//g;
  $_ =~ s/\(//g;
  $_ =~ s/\)//g;
  #print "sentence \|\| $_\n"; #used to see how sentences are tokenized
  my @array = split/\s+/;
  for my $i(0..$#array) {
    my $j = $i + $n - 1;
    my $q = $i + $n - 2;
    my $first = $array[$i];
    my $ngram = "";
    my $n2gram = "";
    if($j > $#array) {next;}
    for my $y ($i..$j) {
      $ngram .= "$array[$y] ";
    }
    for my $z ($i..$q) {
      $n2gram .= "$array[$z] ";
    }
    chomp $ngram;
    chomp $n2gram;
    $hash1{$first}{$ngram}++;
    $hash2{$first}{$n2gram}++; #get count for (n-1)ngram
    $hybrid = $hash1{$first}{$ngram} / $hash2{$first}{$n2gram}; #execute formula
    $hash1{$first}{$ngram} = sprintf("%.5f",$hybrid); #replaces the occurences
    #in ngram with the p(w|w)frequency formula
  }
}
for my $c(1..$sentences){
  $lastword = "";
  my $blackhat = rand(); #for randomly choosing some type of start for after first 
  my @keys = keys %hash1;
  my $random_value = $keys[rand keys %hash1];
  my @hold = keys %hash1->{$random_value};
  my $phrase = $hold[rand keys %hold];
  print "$phrase\n";
  if($phrase =~ /.+\s(\w+)/ | $phrase =~ /.+\s(\W+)/ ){
      $lastword = $1;
  }

}
#print Dumper \%hash1;
