#!/usr/bin/perl

# Be strict to avoid messy code
use strict;

# Use LWP::Simple module to get website content (crossplatform)
use LWP::Simple;

# If no playername is passed to the script
if ("@ARGV" =~ /^$/ && "@ARGV" !~ /--interactive/)
{
	# Exit the script
	exit
}
# Else if STATEMENT
elsif("@ARGV" =~ /--interactive/)
{
	$ARGV[0] = askforname();
	$ARGV[1] = "--interactive";
}


# Get the highscores info of a player
my $highscore = fetchstats();

# The amount of skills in runescape
my $skillcount = 25;

# Make an array that contains the names of all the skills in runescape
my @skillnames = ("Overall","Attack","Defence","Strength","Constitution","Ranged","Prayer","Magic","Cooking","Woodcutting","Fletching","Fishing","Firemaking","Crafting","Smithing","Mining","Herblore","Agility","Thieving","Slayer","Farming","Runecrafting","Hunter","Construction","Summoning","Dungeoneering");

# Use FindBin module to get script directory
use FindBin;

# Get script directory
my $cwd = $FindBin::RealBin;
# Get script filename
my $scriptname = $FindBin::Script;
# Detect the current OS
my $OS = "$^O";

# If we are inside an interactive shell then
if (-t STDOUT)
{	
	# run the script
	main($highscore);
}
# else
else
{
	# run script in xterm so we can get input from user
	system ("xterm -e \"perl $cwd/$scriptname --interactive\"");
}

sub main
{
	if ($highscore !~ /^0$/)
	{
		# Split the data by whitespace
		my @playerdata = split /\s/, $highscore;
		
		# Print the name of the player
		print "$ARGV[0]'s Stats\n";
		
		# Make a for loop that goes through the highscores info
		my $counter;
		for ($counter = 0; $counter <= $skillcount; $counter++)
		{
			my @skilldata  = split /,/, $playerdata[$counter];
			print "$skillnames[$counter]=Level: $skilldata[1],Rank: $skilldata[0],XP: $skilldata[2]\n";
		}
	}
	
	# If we are in interactive mode
	if ("@ARGV" =~ /--interactive/)
	{
		# Rerun the processes
		rerun();
	}
	
	# Exit the script
	exit;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub askforname
{
	# Tell that we are asking for a name
	print "Type in the name of the player to lookup:\n";
	
	# Get the name from input
	my $name = <STDIN>;
	
	# Remove newlines
	$name =~ s/(\n|\r)//g;
	
	# If no name is specified
	if ($name eq '')
	{
		# Exit the sctript
		exit;
	}
	# Else if a name is specified
	else
	{
		# Make a newline
		print "\n";
	}
	
	
	# Return the name
	return $name;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetchstats
{
	# Get the highscores info of a player
	my $highscore = get("http://hiscore.runescape.com/index_lite.ws?player=$ARGV[0]");
	
	# Suppress "uninitialized string" warning if lookup failed
	no warnings;
	
	# If $highscore is empty
	if ($highscore eq '')
	{
		print "Player do not exist or is F2P account\n\n";
		$highscore = '0';
	}

	use warnings;

	# Return the stats
	return $highscore;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub rerun
{
	# Ask for a new player name
	$ARGV[0] = askforname();
	
	# Make sure we are still interactive
	$ARGV[1] = "--interactive";
	
	# Fetch stats
	$highscore = fetchstats();
	
	# Process info again
	main($highscore);
}

#
#---------------------------------------- *** ----------------------------------------
#
