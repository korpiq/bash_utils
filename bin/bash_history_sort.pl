#!/usr/bin/env perl -w

use strict;

if (@ARGV < 1)
{
    die "Usage: $0 bash_history_filename[-session.id] ...\n" .
        "Outputs bash history of commands with timestamps from input files in timestamp order\n"
}

my $timestamp = 0;
my $next_timestamp = 0;
my $filename = "";
my $command = "";
my %all_commands = (); # map from timestamps to a list of commands
my $row = "";

sub get_timestamp () {
    return $row =~ /^#(\d{10})$/ ? $1 : 0;
}

sub add_command () {
    return unless $command;

    my $moment = $all_commands{$timestamp} ||= [];
    push @{$moment}, $command;

    $command = "";
}

### read commands from all input files with optional timestamps

while(<>)
{
    $row = $_;

    if ($ARGV ne $filename) # started reading next file
    {
        add_command(); # flush last command collected from previous file

        $filename = $ARGV;
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

add_command(); # flush last command collected from last file

### output commands in order by timestamps with them

for $timestamp (sort { $a <=> $b } keys %all_commands)
{
    my $moment = $all_commands{$timestamp};

    for $command (@$moment)
    {
        print "#$timestamp\n$command";
    }
}

