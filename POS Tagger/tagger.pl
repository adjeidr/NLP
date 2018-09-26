#!/usr/local/bin/perl -w
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 3: POS Tagging, 3/12/18
Problem: As input accept a training file containing part of speech tagged text,
and a file containing text to be part of speech tagged. The program should implement
the "most likely tag" baseline. Accuracy of tagging will be scored in scorer.pl.
The program does not modify the test file however a new file with the output is
created through command line as shown in the Example(s) below.
Example(s):
    perl tagger.pl pos-train.txt pos-test.txt > pos-test-with-tags.txt
    input: [ this/DT British/JJ industrial/JJ conglomerate/NN ]
    input: [ was n't Black Monday ]
    output: [ was/VBD n't/RB Black/NNP Monday/NNP ]
Algorithm: Relies on being able to store the contents of the files into array
then analyzing each String element in the array in order to split into either
words and tags to crsate hash table. Which is then used to tag another non-tagged
test file using the "most likely tag" baseline. Five rules are added to the bottomedto check for
proper nouns, adjectives, numbers, adverbs, and verbs in present tense.
=end comment
=cut
use Data::Dumper qw(Dumper);
($trainer, $noTags) = @ARGV; #gets 2 files provided, training file then test file
%hash = ();
@arr = ();
@arr2 = ();
@splitTag2 = ();
$txt = "";
$tag = "";

open ($first,$trainer) or die "Could not open $trainer: $!";

#open then read the training file
while(<$first>) { #handle training file
  chomp;
  $input = $_;
  #$input =~ s/[\]\[]//g;    #remove all the brackets to focus on words and to eliminate the redundancy of brackets
  @arr = split/\s+/, $input;
  for  $i (0..$#arr){
    $line = $arr[$i];
    @link = split/\//, $line; #split on tag
    $txt = $link[0];
    $tag  = $link[1];
    $hash{$txt}{$tag}++;    #add word and tag to hash and increment by occurences
  }
}
open ($needsTags,$noTags) or die "Could not open $noTags: $!";
#open then read the test file
while(<$needsTags>) { #handle test file
  chomp;
  $in = $_;
  @arr2 = split/\s+/, $in;
  for $x (0..$#arr2){
    $line = $arr2[$x];
    push @splitTag2, $line; #adds everything inside of file into an array
  }
}
#After reading in all the words in the file, do POS tagging.
for $i (0..$#splitTag2){
  $count = 0;
  $tag = "";
  $txt = $splitTag2[$i];
  while ( ($pos, $num) = each %{$hash{$txt}} ){
  #check the hash table given the key that is the word we are at in the test file
		if ($count < $num){ #implement most likely tagged baseline
			$count = $num;
			$tag = $pos;
		}
	}
  if($txt =~ /[0-9]/){ #if word contains numbers
    $tag = "CD" #Number
  }
  if($txt =~ /[A-Z]\w+/){ #word starts with a captial letter
    $tag = "NNP" #Proper Noun
  }
  if($txt =~ /\w+(ing)/){ #word that ends in -ing
    $tag = "VBG" #Verb Present tense
  }
  if($txt =~ /\w+(ly)/){ #word that ends with -ly
    $tag = "RB" #Adverb
  }
  if($txt =~ /\w+-\w+/){ #hypefenated words
    $tag = "JJ" #Adjective
  }
  if ($txt =~ /\[|\]/){ #Skip tagging the brackets
    $tag = "";
    print "$& "; #Print the bracket to keep og file format
  }

  else{
    print "$txt/$tag ";	#Print the word and it's corresponding tag from the training file
  }
}
