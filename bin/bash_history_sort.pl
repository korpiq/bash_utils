#!/usr/bin/env perl -w

# Outputs all unique history entries in timestamp order.

use strict;
use Getopt::Long;
use vars qw($comment $delete);

sub debug {
	warn "@_\n" if $ENV{DEBUG_BASH_HISTORY};
}

sub read_row ($) {
	my $file = shift;
	my $row = readline $file->{handle} || '';
	++$file->{$row ? 'rows_read' : 'finished'};
	return $row;
}

sub timestamped_entry_reader ($$) {
	my ($file, $row) = @_;
	return (
		($row =~ /^#(\d+)$/, $file->{rows_read})[0],
		read_row $file
	);
}

sub timestampless_entry_reader ($$) {
	my ($file, $row) = @_;
	return ($file->{rows_read}, $row);
}

sub first_entry_reader ($$) {
	my ($file, $row) = @_;
	if ($row =~ /^#(\d+)$/) {
		$file->{reader} = \&timestamped_entry_reader;
		return ($1, read_row $file);
	} else {
		$file->{reader} = \&timestampless_entry_reader;
		return (1, $row);
	}
}

sub read_entry ($) {
	my $file = shift;
	($file->{timestamp}, $file->{command}) = $file->{reader}->($file, read_row $file);
}

sub oldest_file {
	my $oldest = shift;
	for my $file (@_) {
		$oldest = $file if $file->{timestamp} < $oldest->{timestamp};
	}
	return $oldest;
}

sub bash_history_sort {
	my %files;
	for(@_) {
		debug "Open $_";
		my $file = {
			name => $_,
			finished => 0,
			reader => \&first_entry_reader
		};
		open $file->{handle}, $_;
		read_entry $file;
		$files{$_} = $file;
	};

	my $last_command = '';
	while(keys %files) {
		my $file = oldest_file(values %files);
		debug "Oldest: $file->{name}: $file->{timestamp}: $file->{command}";
		printf "#%d\n%s", $file->{timestamp}, $file->{command}
			unless $file->{command} eq $last_command;
		if ($file->{finished}) {
			debug "Finished $file->{name}";
			delete $files{$file->{name}};
		} else {
			read_entry $file;
		}
	}
}

### MAIN

GetOptions(
	'comment!' => \$comment,
	'delete!' => \$delete,
	'help' => sub { HelpMessage() }
);
bash_history_sort(@ARGV);

