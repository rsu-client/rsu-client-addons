#!/usr/bin/perl -w
# Make a name for the module
package rsu::wiki;
 
# Include stricts
use strict;

# Use the sysdload::get module so we can read urls
require updater::download::sysdload;

# Use the grep module
require rsu::files::grep;

# Use the URI::Encode module to encode strings
use URI::Encode;

# Search method for the official runescape wiki
sub searchwiki
{
	# Get the passed item name
	my ($searchfor) = @_;
	
    # Prepare url encoding
    my $uri = URI::Encode->new({encode_reserved => 1});
    
	# Encode the search term
	$searchfor = $uri->encode("$searchfor");
    
	# Do a wiki search on the official rs wiki
	my $wiki_search = updater::download::sysdload::readurl("http://services.runescape.com/m=rswiki/en/Special:Search?text=$searchfor",10);
	
	# Get the wiki results
	my @wiki_result = rsu::wiki::parserswiki($wiki_search);
	
	# Return the results
	return @wiki_result
}

#
#---------------------------------------- *** ----------------------------------------
#

# Method to parse the official runescape wiki
sub parserswiki
{
	# Get the passed html
	my ($html) = @_;
	
	# Split the html by lines
	my @lines = split /\n/, $html;
	
	# Make a variable to contain the results
	my @results;
	
	# For each line
	foreach my $line (@lines)
	{
		# If the line is a search result
		if ($line =~ /<div class=\"searchresult\">/)
		{
			# Fetch the info we need
			my $info = $line;
			$info =~ s/\t+<div class=\"searchresult\"><a href=\"(.+)\" title=\"(.+)\">.+<\/a><\/div>/$1;$2/;
			
			# Push the result into the result array
			push(@results, $info);
		}
	}
	
	# Returns the results
	return @results;
}

#
#---------------------------------------- *** ----------------------------------------
#

# Search method for the runescape wikia (never got this to properly work, suggestions are welcome!)
sub searchwikia
{
	# Get the passed item name
	my ($searchfor) = @_;
	
	# Replace all spaces with %20
	$searchfor =~ s/\s{1,1}/+/g;
	
	# Do a wiki search on the official rs wiki
	my $wiki_search = updater::download::sysdload::readurl("http://runescape.wikia.com/wiki/Special:Search?ns0=1&ns14=1&ns116=1&ns120=1&search=$searchfor&fulltext=Search&ns0=1&ns14=1&ns116=1&ns120=1&advanced=",10);
	
	# Get the wiki results
	my @wiki_result = rsu::wiki::parsewikia($wiki_search);
	
	foreach my $i(@wiki_result)
	{
		print "$i\n";
	}
	
	# Return the results
	return @wiki_result
}

#
#---------------------------------------- *** ----------------------------------------
#

# Parse the wikia results (never got this to properly work, suggestions are welcome!)
sub parsewikia
{
	# Get the passed html
	my ($html) = @_;
	
	# Split the html by lines
	my @lines = split /\n/, $html;
	
	# Make a variable to contain the results
	my @results;
	
	# For each line
	foreach my $line (@lines)
	{
		print "$line\n" if $line =~ /ahrim/i;
		# If the line is a search result
		if ($line =~ /\t+<a href=\"(.+)\" class=\"result-link\" .+>/)
		{
			print "$line\n";
			# Fetch the info we need
			my $info = $line;
			$info =~ s/<a href=\"(.+)\" class=\"result-link\" .+>(.+)<\/a>/$1;$2/;
			
			# Push the result into the result array
			push(@results, $info);
		}
	}
	
	# Returns the results
	return @results;
}

#
#---------------------------------------- *** ----------------------------------------
#
1;
