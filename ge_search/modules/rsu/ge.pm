#!/usr/bin/perl -w
# Make a name for the module
package rsu::ge;
 
# Include stricts
use strict;

# Use the sysdload::get module so we can read urls
require updater::download::sysdload;

# Use the grep module
require rsu::files::grep;

# Search method for the grand exchange
sub search
{
	# Get the passed item name
	my ($item) = @_;
    
    # Replace all spaces with %20
    $item =~ s/\s{1,1}/%20/g;
	
	# Query an item search on the GE
	my $ge_search = updater::download::sysdload::readurl("http://services.runescape.com/m=itemdb_rs/results.ws?query=$item",10);
	
	# Locate all item results
	my @ge_query = rsu::files::grep::strgrep($ge_search, "(id=(\\d{1,9})\" alt=\"|<a href=\"(.+)obj=(.+)\">(.+)<\/a>|<td class=\"memberItem\">.+<\/td>|<td class=\"\"><\/td>|<td class=\"(neutral|positive|negative)\"><a href=\"(.+)obj=(.+)\">(.+)<\/a><\/td>)");
    
    # Make an array to contain the result data
    my @result_data;

    # Make a counter which we will use to find every item returned by the query
    my $counter = 0;
    
    # For each index in @ge_query
    foreach (@ge_query)
    {
        # If $counter is a modulo of 4
        if (($counter % 4) == 0)
        {
            # Make a variable to contain the parsed string
            my $ge_result;
            
            # Parse the html code ($item, $type, $price, $trend)
            $ge_result = rsu::ge::parse($ge_query[$counter],$ge_query[$counter+1],$ge_query[$counter+2],$ge_query[$counter+3]);
            
            # Push the data to the result_data array
            push(@result_data,$ge_result);
        }
        # Increase counter by 1
        $counter += 1;
    }
    
    # Return the result data
    return @result_data;
}

# Method for parsing the grand exchange search query
sub parse
{
    # Get the passed data
    my ($item,$type,$price,$trend) = @_;
    
    # Get the item id and name
    $item =~ s/<img src=\".+\?id=(\d{1,9})\" alt=\"(.+)\">/$1;$2/;
    
    # Get the type of item
    # If the item is a members item
    if ($type =~ /<td class=\"memberItem\">.+/)
	{
		# Set type to Members
		$type = "Members";
	}
	# Else
	else
	{
		# Set type to Free
		$type = "Free";
	}
    
    # Get the price of the item
    $price =~ s/<td><a href=\"(.+)obj=(.+)\">(.+)<\/a><\/td>/$3/;
    
    # Get the items current trend
    $trend =~ s/<td class=\"(neutral|positive|negative)\"><a href=\"(.+)obj=(.+)\">(.+)<\/a><\/td>/$4/;
    
    # Return the parsed info
    return "$item;$type;$price;$trend";
}

#
#---------------------------------------- *** ----------------------------------------
#
1;
