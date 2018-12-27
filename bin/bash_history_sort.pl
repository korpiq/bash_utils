#!/usr/bin/env perl -w

use strict;

if (@ARGV < 1)
{
    die "Usage: $0 bash_history_filename[-session.id] ...\n" .
        "Outputs bash history of commands with timestamps from input files in timestamp order\n"
}

my $timestamp = 0;
my $next_timestamp = 0;
my $sessionid = "";
my $filename = "";
my $command = "";
my %all_commands = (); # map from timestamps to sessionids each with a list of commands there then
my $row = "";

sub get_timestamp () {
    return $row =~ /^#(\d{10})$/ ? $1 : 0;
}

sub add_command () {
    return unless $command;

    my $moment = $all_commands{$timestamp} ||= {};
    my $session_commands = $moment->{$sessionid} ||= [];

    push @{$session_commands}, $command;

    $command = "";
}

### read commands from all input files with optional timestamps

while(<>)
{
    $row = $_;

    if ($ARGV ne $filename) # started reading next file
    {
        add_command();

        $filename = $ARGV;
        $sessionid = $filename =~ /-(\d+.*)/ ? $1 : "";
        $timestamp = get_timestamp();
    }
    
    if (not $timestamp) # pass through every line of non-timestamped input file
    {
        $command = $row;
        add_command();
    }
    elsif ($next_timestamp = get_timestamp()) # came across a timestamp row
    {
        add_command();
        $timestamp = $next_timestamp;
    }
    else # collect rows between timestamps together as the command
    {
        $command .= $row;
    }
}

add_command();

### output commands in order by timestamps with them and session ids from input filenames

for $timestamp (sort { $a <=> $b } keys %all_commands)
{
    my $moment = $all_commands{$timestamp};

    for $sessionid (sort keys %$moment)
    {
        my $session_commands = $moment->{$sessionid};
        my $comment = $sessionid ? " # $sessionid" : "";

        for $command (@$session_commands)
        {
            chomp($command);
            print "#$timestamp\n$command$comment\n";
        }
    }
}

