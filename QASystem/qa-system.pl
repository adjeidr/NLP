#!/usr/local/bin/perl
=begin comment
Derrick Adjei
CMSC416 NLP
Programming Assignment 6: QA System Modified, 30 April 2018
Description : This programs is designed as a Question-Answering system that uses
Wikipedia to find information on target topics provided by the user in the form
of a question. The system answers Who, What, Where, and When questions.
Example : All questions should be typed similar to this Who is/are/were/was TARGET?
    in => Who is Kanye West?
    out => Kanye Omari West is an American rapper, songwriter, entrepreneur and fashion designer.
Algorithm : The algorithm reads in a question and determines the which of the main types
of questions it is. After a type is determined through regex certain words are spotted in order to better
search the Wikipedia results. After a match is found it is then output for the user to
view either reformatted or as is. If the system is unable to retrieve data or find
the target on Wikipedia a reponse is printed indicating the inability. Lastly, the
question, raw information, and answers are
print to the mylogfile.txt.
=end comment
=cut
use WWW::Wikipedia;
use feature qw(switch);
use Data::Dumper;
use open ':std', ':encoding(UTF-8)';
($file) = @ARGV;
open(my $mylogfile, '>', $file) or die "Could not open file '$file' $!";


print "This is a Question Answering system by Derrick Adjei.
System will answer questions that start with Who, What, Where or When.
Enter 'exit' to terminate the program.\n";
print "=?> ";
my $wiki = WWW::Wikipedia->new(clean_html => 1);
while($input = <stdin>){
  chomp $input;
  #Who Questions
  if($input =~ /(W|w)(ho|hat)\s(is|are|was|were)\sa?\s?/){
    print $mylogfile "Question: $input\n";
    my $word = $';
    chomp $word;
    my $txt = "";
    $word =~ s/[?]//;
    my $results = $wiki->search( $word );
    if($results eq undef){
      print "=> I am sorry, I don't know the answer.\n";
      print $mylogfile "My System Answer: Could not retrieve answer.\n";
    }
    else{$txt = $results->text();
        chomp $txt;
        print $mylogfile "Raw Results: $txt\n\n";}
    my $info = $txt;
    $info =~ s/\n/ /g;
    $info =~ s/[']//g;
    $info =~ s/{{.*}}//;
    $info =~ s/^\s+//;
    $info =~ s/\(.*?\)//g;
    if($info =~ m/(.*?)\s(\bis|\bwas|\bwere|\bare)(.*?)\./){
      print "=> $&\n";
      print $mylogfile "My System Answer: $&\n\n";
    }
  }
  #When Questions
  if($input =~ /(W|w)hen\s(is|are|was|were)\s/){
    my $word = $';
    chomp $word;
    print $mylogfile "Question: $input\n";
    my $txt = "";
    $word =~ s/[?]//;
    if($word =~ /born/){
      $word =~ s/\sborn//;
      my $results = $wiki->search( $word );
      if($results eq undef){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n";
      }
      else{$txt = $results->text();
          print $mylogfile "Raw Results: $txt\n\n";}
      my $info = $txt;
      if($info =~ /(.*)born\s(.*)\)/ or $info =~ m/(.*)(?=\&)/){
        # $info =~ /(.*)(?=\&)/
        # $last_name\s(.*)\s(is|was)
        $birthdate = $&;
        $last_name = ($word =~ m/\w+/g)[1];
        $birthdate =~ s/$last_name/$last_name is born on/;
        $birthdate =~ s/[()';:{}]//g;
        print "=> $birthdate\n";
        print $mylogfile "My System Answer: $birthdate\n";
      }
    }
    else{
      $word =~ s/[?]//;
      my $results = $wiki->search( $word );
      if($results eq undef){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
      }
      else{$txt = $results->text();
          print $mylogfile "Raw Results: $txt\n\n";}
      my $info = $txt;
      $info =~ s/\n/ /g;
      $info =~ s/[']//g;
      $info =~ s/{{.*}}//;
      $info =~ s/^\s+//;
      $info =~ s/\(.*?\)//g;
      $info =~ s/&nbsp;//;
      if($info =~ m/(.*?)\s(\bis|\bwas|\bwere|\bare)(.*?)\./){
        print "=> $&\n";
        print $mylogfile "My System Answer: $&\n\n";
      }
    }
  }
  #Where Questions
  if($input =~ /(W|w)here\s(is|are|was|were)\s/){
    chomp $input;
    print $mylogfile "Question: $input\n";
    my $word = $';
    chomp $word;
    my $txt = "";
    if($word =~ /born[?]/){
      $word =~ s/born[?]//;
      my $results = $wiki->search( $word );
      if($results eq undef){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
      }
      else{$txt = $results->text();
          print $mylogfile "Raw Results: $txt\n\n";}
      my $info = $txt;
      if($info =~ m/birth_place\s?=?(.*)=/){
        $spot = $1;
        $str = ($spot =~ m/\w+/g)[$#spot];
        $spot =~ s/$str//;
        print "=> $word was born in $spot\n";
        print $mylogfile "My System Answer: $word was born in $spot\n\n";
      }
    }
    else{
      $word =~ s/[?]//;
      my $results = $wiki->search( $word );
      if($results eq undef){
        print "=> I am sorry, I don't know the answer.\n";
        print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
      }
      else{$txt = $results->text();
          print $mylogfile "Raw Results: $txt\n\n";}
      my $info = $txt;
      $info =~ s/\n/ /g;
      if($info =~ /(L|l)ocated\s(.*?)\./){
        $spot = $2;
        print "=> $word is located $spot\n";
        print $mylogfile "My System Answer: $word is located $spot\n\n";
      }
    }
  }
  #Reponses for unrecognizable questions
  if ($input =~ /(how|why)/) {
    print $mylogfile "Question: $input\n";
    print "=> Sorry,the System is unable to process that request.\n";
    print $mylogfile "Raw Results: No Results";
    print $mylogfile "My System Answer: Could not retrieve answer.\n\n";
  }
  if($input =~ /(exit)/){
    print "=> System Shut Down.\n";
    exit;
  }
  print "=?> ";
}
