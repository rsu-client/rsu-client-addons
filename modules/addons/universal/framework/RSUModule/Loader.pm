package RSUModule::Loader;

# Use FindBin module to locate the location the main process is running from
require FindBin;

# Use the Cwd module to get the cwd of the rsu-launcher
use Cwd;

sub clientdir
{
	# Make a variable to contain the clientdir and set it to the working directory
	my $clientdir = $FindBin::RealBin;
	
	# If this script have a working directory in a system path
	if ($clientdir =~ /^(\/usr\/s?bin|\/opt\/|\/usr\/local\/s?bin)/)
	{
		# Change the clientdir to $HOME/.config/runescape
		$clientdir = $ENV{"HOME"}."/.config/runescape";		
	}
	
	# return the $cwd
	return $clientdir;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub universal_addondir
{
	# get the foldername passed
	my ($foldername) = @_;
	
	# Return the universal addondir path
	return "modules/addons/universal/$foldername";
}

#
#---------------------------------------- *** ----------------------------------------
#

sub platform_addondir
{
	# Get the foldername passed
	my ($foldername) = @_;
	
	# Return the universal addondir path
	return "modules/addons/$^O/$foldername";
}

#
#---------------------------------------- *** ----------------------------------------
#

sub launch_addon
{
	# Get the passed data
	my ($command, $params) = @_;
	
	# If we are on windows
	if ($^O =~ /MSWin32/)
	{
		# Launch the addon
		system (1, "$command $params");
	}
	# Else on any other system
	else
	{
		# Launch the addon
		system "$command $params &";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub wxperl_addon
{
	# Get the passed data
	my ($script, $params) = @_;
	
	my $clientdir = clientdir();
	
	# If we are on windows
	if ($^O =~ /MSWin32/)
	{
		# Launch the wxperl addon using the rsu-launcher
		system (1, "$clientdir/rsu-launcher.exe --showcmd=true --script=\"$script\" $params");
	}
	# Else on other platforms
	else
	{
		# If this script have a working directory in a system path
		if ($FindBin::RealBin =~ /^(\/usr\/s?bin|\/opt\/runescape|\/usr\/local\/s?bin)/)
		{
			# Change the clientdir to $HOME/.config/runescape
			$clientdir = $ENV{"HOME"}."/.config/runescape";
		}
		
		# Launch the wxperl addon using the rsu-launcher
		system $FindBin::RealBin."/../../../rsu-launcher --script=\"$script\" $params";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#



1;
