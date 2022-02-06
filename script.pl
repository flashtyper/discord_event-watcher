#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use DateTime;
use REST::Client;
use JSON::XS;
use JSON::Parse 'parse_json';
use Cache::FileCache;
use utf8;

### constants ###
my $channel_id = '<CHANNEL ID>'; 
my $guild_id = '<GUILD ID>'; 
my $bot_secret = '<BOT API SECRET>';

### global vars ###
my %eventsOldHash;
my %eventsNewHash;


### objects ###
my $rest = REST::Client->new(timeout => 5);
$rest->addHeader('Content-Type', 'application/json');
$rest->addHeader('Authorization', 'Bot ' . $bot_secret);

my $cache = Cache::FileCache->new({
 namespace => "event-watcher_$guild_id",
 default_expires_in=> '30 minutes',
 auto_purge_interval=> '60 minutes'
}) or die($@);




&main();


sub main {
my $eventsOld = $cache->get("events_$guild_id");
my $eventsNew = parse_json(&api_get());
$cache->set("events_$guild_id", $eventsNew);


foreach my $elem (@$eventsOld) {
        $eventsOldHash{$elem->{id}} = $elem;
}
foreach my $elem (@$eventsNew) {
        $eventsNewHash{$elem->{id}} = $elem;
}


foreach my $id (keys %eventsNewHash) {
        if (exists $eventsOldHash{$id}) {
                if ($eventsOldHash{$id}->{name} ne $eventsNewHash{$id}->{name}) {
                        &send_api(&send_name_change($id));
                } elsif ($eventsOldHash{$id}->{"scheduled_start_time"} ne $eventsNewHash{$id}->{"scheduled_start_time"}) {
                        &send_api(&send_time_change($id));
                } else {
                        print "Nothing changed for ID $id \n";
                }
        } else  {
                &send_api(&send_new($id));
        }
}
=pod
foreach my $id (keys %eventsOldHash) {
        if (not exists $eventsNewHash{$id}) {
                &send_api(&send_del($id));
        }
}
=cut
}


### methods ###
sub api_get {
$rest->GET("https://discordapp.com/api/guilds/$guild_id/scheduled-events");
if ($rest->responseCode() eq 200) {
  return $rest->responseContent;
} else {
  print "failed: \n";
  print $rest->responseCode;
  print $rest->responseContent;
  exit 2;
}
}

sub send_new {
  my $id = shift;
  my $message =
  '<@' . $eventsNewHash{$id}->{creator_id} . '> '
  . "hat ein neues Event erstellt! \nhttps://discord.com/events/"
  . $guild_id
  . '/'
  . $id
  ;
  return $message;
}

sub send_del {
  my $id = shift;
  my $message =
  'Es wurde ein Event geloescht: **'
  . $eventsOldHash{$id}->{name}
  . " **\n"
  . 'Ersteller des Events: <@'
  . $eventsOldHash{$id}->{creator_id}
  . '>'
  ;
  return $message;
}


sub send_name_change {
  my $id = shift;;
  my $message =
  'Der Name eines Events wurde geaendert! **Alt:** '
  . $eventsOldHash{$id}->{"name"}
  . ' **Neu:** '
  . $eventsNewHash{$id}->{"name"}
  . "\nhttps://discord.com/events/"
  . $guild_id
  . '/'
  . $id
  ;
  return $message;
}
sub send_time_change {
  my $id = shift;
  my $oldTime = substr($eventsOldHash{$id}->{scheduled_start_time}, 0, -16);
  $oldTime =~ s/T/ /g;

  my $newTime = substr($eventsNewHash{$id}->{scheduled_start_time}, 0, -16);
  $newTime =~ s/T/ /g;

  my $message =
  'Der Startzeitpunkt des Events **'
  . $eventsNewHash{$id}->{name}
  . '** wurde geaendert! '
  . '**Alt:** '
  . $oldTime
  . ' Uhr, **Neu:** '
  . $newTime
  . ' Uhr '
  . "\nhttps://discord.com/events/"
  . $guild_id
  . '/'
  . $id
  ;
  return $message;
}


sub send_api {
  my $message = shift;
   my $payload = {
    channel_id => $channel_id,
    content => $message,
  };
  my $json = encode_json($payload);
  $rest->POST("https://discordapp.com/api/channels/$channel_id/messages", $json);
  #print Dumper($json);
  #print $rest->responseContent;
}
