#!/usr/bin/perl -w
# Make a name for the module
package rsu::ge;
 
# Include stricts
use strict;

# Use the sysdload::get module so we can read urls
require updater::download::sysdload;

# Use the grep module
require rsu::files::grep;

sub search
{
	# Get the passed item name
	my ($item) = @_;
	
	# Query an item search on the GE
	my $ge_search = updater::download::sysdload::readurl("http://services.runescape.com/m=itemdb_rs/results.ws?query=$item",10);
	
	# Locate all item results
	$ge_search = rsu::files::grep::strgrep($ge_search, "id=\d{1,9}\" alt=\"(.+)\"");
	
	# Show the contents we found
	print "$ge_search\n";
}
