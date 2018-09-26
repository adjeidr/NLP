#!/usr/local/bin/perl -w
#Derrick Adjei
#CMSC416 NLP
#Programming Assignment 1: Eliza, 2/7/17
#Problem: Eliza, a program that will act as a psychotherapist. Is able to hold
#a conversation with the user.
#Usage directions are as follows: Program greets the user and prompts the user
#for their name. The user must type in their name in a phrase, not just the name
#by itslef (see example). Them the user can converse with the proper spelling
#of words.
#Example(s):
#           [Eliza] Hi, I'm a psychotherapist. What is your name?
#           [user] Hi, my name is Derrick
#           [Eliza] Hello Derrick, how may I help you?
#           [Derrick] I gotta say I feel pretty awful Eliza.
#           [Eliza] Why are you feeling this way?
#Algorithm: First, was to get unique information like the user's name. Phrase is
#used to spot key words to find name in sentence. Then it looks for key words
#in sentences to make responses by using loop and use of regular expressions,
#and if and else statments. If the program cannot find anything then it repsonds
#saying that it did not understand.
print "[Eliza] Hi, I'm a psychotherapist. What is your name?\n";
print "[user] ";
$first  = lc(<stdin>);
#the following block allows the user to back out of conversation
#before it begins
if($first =~ s/[.,!?"]//){} #check for periods in phrase
@esc  = ("bye", "goodbye", "nevermind");
foreach $s(@esc){
  if($first =~ /$s/){
	   print "[Eliza] Goodbye! Too bad we never got to talk. \n";
	    exit;
    }
}
#gets first for name od user through use of am, I'm or is, user can not just say their
#name must be in a phrase that uses these words
$user = ( $first =~ /is\s+(\S+)/)|( $first =~ /am\s+(\S+)/)
          |( $first =~ /i'm\s+(\S+)/);
$user_name = ucfirst("$$user");
print "[Eliza] Hello $user_name, how may I help you?\n";
print "[$user_name] ";
#get what user conversation point is about
while(<>){
    $input = lc($_); #move all input to lowercase no matter the case
    if($input =~ s/\.//){}#check for periods in phrase
    if($input=~/([Ii])/){ #phrases that begin or contain the word I
        if($input=~/feel/){ #to address any type of use of the word feel,feelings,feels
          print"[Eliza] ";
          print "Why are you feeling this way?\n";
          print"[$user_name] ";
    		}
        if($input=~/(want|going|need|think)/){ #words usually followed by the word to
          my $subject = $'; chomp $subject;
          my $key = $&;
          my $phrase;
          my $spot;
          #will modify phrases based on the matched word to make more sense when it prints
          if($key =~/going/){$phrase = "are you"}
          elsif($key =~/think/){
            $phrase = "don't you tell me more about why you";
          }
          else{$phrase = "do you"}
          #put together sentence given the information gathered
          if(($subject =~s/(my)/your/)|($subject =~s/(i)\s/you /)|($subject =~s/(am)/are/)|
             ($subject =~s/(is)\s/is /)){
              print"[Eliza] ";
              print "$user_name, why $phrase $key$subject?\n";
              print"[$user_name] ";
          }
          #if nothing needs to be replaced, from word spot
          else{
            print"[Eliza] ";
            print "$user_name, why $phrase $key$subject?\n";
            print"[$user_name] ";
        }
    	}
      #end of phrases that use the word I
      #sometimes the user will use an I am sentence, need to be able to differentiate
      #used an else if to catch that scenario
      if($input=~/(am)(\s)?(\.)?/){
          my $subject = $'; chomp $subject;
          my $key = $&;
          print"[Eliza] ";
          if($subject =~ /\./){print "Wow, ok.\n";}
          else{print "Why are you $subject?\n";}
          print"[$user_name] ";
        }
      }
    elsif($input=~/(yes)|(yea(h)?)|(no)|(maybe)/){
    #for yes or no and even maybe answer, in the program uncertainty is usually
    #questioned again to elicit a sure answer so that the conversation can move on.
    my $word = $&;
    print"[Eliza] ";
    if($word =~/yes|yea[h]?/){print "Okay.\n";}
    elsif($word =~/maybe/){print "C'mon you gotta be sure. Are you sure?\n";}
    else{print "Are you sure?\n";}
    print"[$user_name] ";
  }
  if($input=~/(my)(\s)(\w+)/){
#when user enters the word by the subject of dicussion usually follows
    my $rest = $+;
    print"[Eliza] ";
    print "So you are having problems with your $rest?\n";
    print"[$user_name] ";
  }
    if($input=~/(what)[.*]?|(should)/){
      #trying catch if the user asks for a suggestion
      print"[Eliza] ";
      print "I'm sorry, I can't tell anyone what to do. I can listen though.\n";
      print"[$user_name] ";
    }
    if($input=~/\b(me)\b/){
      #trying catch if the user asks for a suggestion
      print"[Eliza] ";
      print "I must say, that is an interesting thing that happened to you.\n";
      print"[$user_name] ";
    }
  elsif($input=~/(because)/){
    #response to any reason for doing something, program asks why a lot many people
    #may use because as a response
      print"[Eliza] ";
      print "hmmmmm.\n";
      print"[$user_name] ";
  }
  elsif($input=~/suicide|(kill myself)|(off myself)/){
    #danger words, emergency mechanism, still allows user to talk if they want though
    print"\n[Eliza] ";
    print "CALL THE SUICIDE HOTLINE: 1-800-273-8255 OR 9-1-1\n";
    print"[$user_name] ";
  }
  elsif($input=~/bye/){
    #if word or line cotains bye then the program says its farewell and terminates
    print"[Eliza] Thank you for coming to talk, $user_name. I really enjoyed it!\n";
    exit;
  }
  #need a response for when program cannot understand input
  elsif($input !~ /$&/){
    print"[Eliza] I didn't get that. Could you say that a different way.\n";
    print"[$user_name] ";
  }
}
