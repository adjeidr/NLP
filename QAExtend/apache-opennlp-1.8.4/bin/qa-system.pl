#!/usr/local/bin/perl
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 6: QA System, 30 April 2018
Description : This programs is designed as a Question-Answering (Modified) system that uses
Wikipedia to find information on target topics provided by the user in the form
of a question. The system answers Who, What, Where, and When questions.
Example : All questions should be typed similar to this Who is/are/were/was TARGET?
    in => Who is Kanye West?
    **in between system prints some of the output from OpenNLP modules
    out => Kanye Omari West is an American rapper, songwriter, entrepreneur and fashion designer.

Algorithm : The algorithm reads in a question and determines the which of the main types
of questions it is. After a type is determined through regex certain words are spotted in order to better
search the Wikipedia results. After the results are converted into test the OpenNLP Modules are run on the depending on the
sitation. The SentenceDetector, Location Finder, and Date Finder were the modules used. The results are put into arrays then
each element is searched with a regex and a confidence score is associated with each result based on where it was found in
the file. Also when using modules some temporary files are created in order to pass certain data to the next module to use.
 If the system is unable to retrieve data or find the target on Wikipedia a reponse is printed indicating the inability. Lastly, the
question, raw information, and answers are printed to the mylogfile.txt.
In when questions program answer formulation holds tense of question in order
to give user back the same tense they asked for. Except for being born because that is always "was" because
because it already has been done. Also for who questions because is or are or were questions need to be answered accordingly.

=end comment
=cut
use WWW::Wikipedia;
use feature qw(switch);
use Data::Dumper;
use open ':std', ':encoding(UTF-8)';
($file) = @ARGV;
open(my $mylogfile, '>', $file) or die "Could not open file '$file' $!";
$read = "print.txt";

print "This is a Question Answering system by Derrick Adjei.
System will answer questions that start with Who, What, Where or When.
Enter 'exit' to terminate the program.\n";
print "=?> ";
my $wiki = WWW::Wikipedia->new(clean_html => 1);
while($input = <stdin>){
  chomp $input;
  my $confidence = 0;
  #Who Questions
  if($input =~ /(W|w)(ho|hat)\s(is|are|was|were)\s(a|an|the)?\s?/){
    print $mylogfile "Question: $input\n";
    my $word = $';
    chomp $word;
    my $txt = "";
    $word =~ s/[?]//;
    my $results = $wiki->search( $word );
    if($results eq ""){
      print "=> I am sorry, I don't know the answer.\n";
      print $mylogfile "My System Answer: Could not retrieve answer.\n";
    }
    else{
        $txt = $results->text();
        $txt =~s/\n/ /g;
        open(my $hold, '>', $read) or die "Could not open file '$read' $!";
        print $hold "$txt";
        @module = `./opennlp SentenceDetector en-sent.bin < $read`;
        print $mylogfile "Raw Results: $txt\n\n";
      }
    for $i (0..$#module+1){
      if ($module[$i]=~m/\s((was|were|is|are)\s\w+.*)/){
        $confidence = (1-(($i+1)/($#module+1)));
        $ans = $1;
        last;
      }
    }
    if($results ne ""){
      $systemAns = "$word $ans";
      print "=> $systemAns\n";
      print $mylogfile "My System Answer: $systemAns\n";
      print $mylogfile "with confidence level of $confidence\n\n";
    }
  }
  #When Questions
  if($input =~ /(W|w)hen\s(is|are|was|were)\s/){
    my $word = $';
    $tense = $2;
    chomp $word;
    print $mylogfile "Question: $input\n";
    my $txt = "";
    $word =~ s/[?]//;
    if($word =~ /born/){
      $word =~ s/\sborn//;
      $tense = "was$&";
      my $results = $wiki->search( $word );
      if($results eq ""){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n";
      }
      else{
          $txt = $results->text();
          $txt =~s/\n/ /g;
          open(my $hold, '>', $read) or die "Could not open file '$read' $!";
          print $hold "$txt";
          @module = `./opennlp SentenceDetector en-sent.bin < $read`;
          print $mylogfile "Raw Results: $txt\n\n";
        }
        for $i (0..$#module+1){
          if ($module[$i] =~/born\s(.*)\)/){
            $confidence = (1-(($i+1)/($#module+1)));
            $ans = $1;
            last;
          }
        }
        if($results ne ""){
          $systemAns = "$word $tense $ans";
          print "=> $systemAns\n";
          print $mylogfile "My System Answer: $systemAns\n";
          print $mylogfile "with confidence level of $confidence\n\n";
      }
    }
    else{
      $word =~ s/[?]//;
      my $results = $wiki->search( $word );
      if($results eq ""){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
      }
      else{
        $txt = $results->text();
        $txt =~s/\n/ /g;
        open(my $hold, '>', $read) or die "Could not open file '$read' $!";
        print $hold "$txt";
        $out = "date.txt";
        $find = `./opennlp TokenNameFinder en-ner-date.bin  en-ner-person.bin < $read > $out`;
        @module = `./opennlp SentenceDetector en-sent.bin < $out`;
        print $mylogfile "Raw Results: $txt\n\n";
        for $i (0..$#module+1){
          if ($module[$i] =~m/\<START:date\>(.*?)\<END\>/){
            $confidence = (1-(($i+1)/($#module+1)));
            $ans = $&;
            $ans =~ s/\<START:date\>//;
            $ans =~ s/\<END\>//;
            $ans =~ s/[(){}*'']//;
            print $ans
            last;
          }
        }
        if($results ne ""){
          $systemAns = "$word $tense$ans";
          print "=> $systemAns\n";
          print $mylogfile "My System Answer: $systemAns\n";
          print $mylogfile "with confidence level of $confidence\n\n";
        }
      }
    }
  }
  #Where Questions
  if($input =~ /(W|w)here\s(is|are|was|were)\s/){
    chomp $input;
    $tense = $2;
    print $mylogfile "Question: $input\n";
    my $word = $';
    chomp $word;
    my $txt = "";
    if($word =~ /born[?]/){
      $word =~ s/(born)[?]//;
      $tense = "was $1 in";
      my $results = $wiki->search( $word );
      if($results eq ""){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
      }
      else{
          $txt = $results->text();
          $txt =~s/\n/ /g;
          open(my $hold, '>', $read) or die "Could not open file '$read' $!";
          print $hold "$txt";
          $out = "location.txt";
          $find = `./opennlp TokenNameFinder en-ner-location.bin < $read > $out`;
          @module = `./opennlp SentenceDetector en-sent.bin < $out`;
          print $mylogfile "Raw Results: $txt\n\n";
        }
        for $i (0..$#module+1){
          if ($module[$i] =~ m/birth_place\s?=?(.*)=/){
            $confidence = (1-(($i+1)/($#module+1)));
            $ans = $1;
            $ans =~ s/\|(.*)//;
            $ans =~ s/residence(.*)//;
            $ans =~ s/\<START:location\>(.*)//;
            last;
          }
        }
        if($results ne ""){
          $systemAns = "$word $tense $ans";
          print "=> $systemAns\n";
          print $mylogfile "My System Answer: $systemAns\n";
          print $mylogfile "with confidence level of $confidence\n\n";
      }
    }
    else{
      $word =~ s/[?]//;
      my $results = $wiki->search( $word );
      if($results eq ""){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
      }
      else{
          $txt = $results->text();
          $txt =~s/\n/ /g;
          open(my $hold, '>', $read) or die "Could not open file '$read' $!";
          print $hold "$txt";
          @module = `./opennlp SentenceDetector en-sent.bin < $read`;
          print $mylogfile "Raw Results: $txt\n\n";
        }
      for $i (0..$#module+1){
        if ($module[$i]=~m/(L|l)ocated\s(.*?)\./){
          $confidence = (1-(($i+1)/($#module+1)));
          $ans = $&;
          last;
          }
        }
        if($results ne ""){
          $systemAns = "$word $ans";
          print "=> $systemAns\n";
          print $mylogfile "My System Answer: $systemAns\n";
          print $mylogfile "with confidence level of $confidence\n\n";
        }
    }
  }
  #Reponses for unrecognizable questions
  if ($input =~ /\s(how|why)/) {
    print $mylogfile "Question: $input\n";
    print "=> Sorry,the System is unable to process that request.\n";
    print $mylogfile "Raw Results: No Results";
    print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
  }
  if($input =~ /((E|)xit|EXIT)/){
    print "=> System Shut Down.\n";
    exit;
  }
  print "=?> ";
}
