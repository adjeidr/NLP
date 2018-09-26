#!/usr/local/bin/perl -w
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 4: Word Sense Disambiguation, 3/26/18
Problem: Word Sense Disambiguation, find the context of the word "line" through log likelihood
Example(s): perl decision-list.pl line-train.txt line-test.txt my-decision-list.txt > my-line-answers.txt
Algorithm: The program takes the 3 text files given to it. Then it builds a training
corpus which it will then interate through. It runs through the training corpus,
collecting the senses either 'product' or 'phone' of the word 'line' through
regular expressions. The program is retrieving ngrams as follows:
"previous word 'line'", "previous word 'line' following word" , and also just "'line' following word".
Program keeps track of how many times sense was used. Then a decision list is built
based on the log likelihood.  If context occurs with just one sense then that
log-likelihood is set to 100 and be automatically chosen if it were to come up.
=end comment
=cut
no warnings qw(uninitialized);
use Data::Dumper qw(Dumper);
($file1, $file2, $file3) = @ARGV;
my @corpus = ();
my %bag = ();
my %senses = ();
my $word = "";
#open all the fiiles required for the rest of the program
open(my $train, $file1) or die "Could not open file '$file0' $!";
open(my $test, $file2) or die "Could not open file '$file1' $!";
open(my $decision, '>' ,$file3) or die "Could not open file '$file3' $!";

#open then read the training file
while($input = <$train>){ #handle training file
  chomp $input;
  @arr = split(/\s+/, $input);
  for  $i (0..$#arr){
    $line = $arr[$i];
    push @corpus, $line;

    if($arr[$i] =~ m/senseid=.*/){
      $sense = $&;
      $sense = (split(/"/,$sense))[1];
      $senses{$sense}++;
    }
    if($arr[$i] =~ /\<head\>[Ll]ine(s)?\<\/head\>/){
      $arr[$i] =~ s/<(\/)?head>//g;
      $before = $arr[$i-1];
      $word = $arr[$i];
      $after = $arr[$i+1];
      $trigram = "$before $word $after";
      $binc = "$arr[$i-1] $word";
      $ainc = "$word $arr[$i+1]";
      $bag{$binc}{$sense}++;
      $bag{$trigram}{$sense}++;
      $bag{$ainc}{$sense}++;
    }
  }
}
#build decision list
my @loglikely = ();
foreach $z (keys %bag){
	my $count = 0;
	my $current = "";
	my $currentVal = 0;

	while (($key, $value) = each %{$bag{$z}}){
		if ($value > $currentVal){
			$currentVal = $value;
			$current = $key;
		}
		$count++;
	}

	if ($count == 1){
		$str = "100|$current|$z";
		push @loglikely, $str;
	}
	#get log likelihood of each context and corresponding sense
	if ($count > 1){
		my @counts = ();
		while (($key, $value) = each %{$bag{$z}}){
			push @counts, $value;
		}
		$totalOcc = $counts[0] + $counts[1];
		$prb1 = $counts[0]/$totalOcc;
		$prb2 = $counts[1]/$totalOcc;
		$likelihood = abs(log($prb1/$prb2));
		if ($likelihood == 0){
			$likelihood = "0.000";
		}
		$str = "$likelihood|$current|$z";
		push @loglikely, $str;
	}
}
#sort so it is easy to spot the ones with loglikelihood in file
@loglikely = sort @loglikely;
#put results into decision list file
print $decision Dumper \@loglikely;

my $most = 0;
my $defaultSense = "";
while (($key, $value) = each %senses){
	if ($value > $most){
		$most = $value;
		$defaultSense = $key;
	}
}
while($in = <$test>){ #handle test file
  chomp $in;
  @txt = split/\s+/, $in;
  push @new, @txt;
}

my $id;
for $i (0..$#new+1){
	$word = $new[$i];
	if($word=~/line-n(.*)/){ #grab the instance id from input
		$id = $&;
	}
  if($word=~m/\<head\>[Ll]ine(s)?\<\/head\>/){
    $new[$i] =~ s/<(\/)?head>//g;
    $before = $new[$i-1];
    $match = $new[$i];
    $after = $new[$i+1];
    $trigram = "$before $match $after";
    $binc = "$new[$i-1] $match";
    $ainc = "$match $new[$i+1]";
    $current = $defaultSense;
    $flag = -7;
    #for loops in order to check if matches ngrams
    for $d (0..$loglikely){
      @str = split(/\|/, $loglikely[$d]);
      if ($str[2] eq $binc){
        if ($str[0] > $flag){
          $flag = $str[0];
          $current = $str[1];
        }
        last;
      }
    }
    for $d (0..$#loglikely){
      @str = split(/\|/, $loglikely[$d]);
      if ($str[2] eq $ainc){
        if ($str[0] > $flag){
          $flag = $str[0];
          $current = $str[1];
        }
        last;
      }
    }
    for $d (0..$#loglikely){
      @str = split(/\|/, $loglikely[$d]);
      if ($str[2] eq $trigram){
        if ($str[0] > $flag){
          $flag = $str[0];
          $current = $str[1];
        }
        last;
      }
    }
    print "<answer instance=\"$id senseid=\"$current\"/>\n";
  }
}
