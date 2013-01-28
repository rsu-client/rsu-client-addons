#!/usr/bin/perl -w

# Required BEGIN block for the moduleloader
BEGIN
{	
	# Use Cwd so we can add the perl module paths
	use FindBin;
	
	# Use Wx so we can display messageboxes
	use Wx;

	# Use lib to add 2 library paths to @INC which is the 2 possible locations of the RSUModule::Loader
	use lib $ENV{"HOME"}."/.config/runescape/modules/addons/universal/framework/";
	use lib $FindBin::RealBin."/modules/addons/universal/framework/";
	use lib $FindBin::RealBin."/../../../modules/addons/universal/framework/";
	
	# Use the RSUModule::Loader which contain functions for launching addons and stuff like that
	use RSUModule::Loader;
}

###############
## Functions ##
###############
# RSUModule::Loader::clientdir()
# returns the path to the client this, this is $HOME/.config/runescape if 
# the client is installed in a systemwide location, otherwise it will
# return the output of Cwd::abs_path()
###################
# RSUModule::Loader::universal_addondir("$foldername")
# returns the relative path to the universal addons folder from the location of
# RSUModule::Loader::clientdir(), replace $foldername with the name of the folder
# this addon resides in.
###################
# RSUModule::Loader::platform_addondir("$foldername")
# works the same as RSUModule::Loader::universal_addondir("$foldername")
# with the exception that it returns the relative path to the current platforms addons folder
###################
# RSUModule::Loader::launch_addon("$command", "$parameters")
# This function will launch a command of your choice with the specified parameters (use "" for no parameters)
# Use this to launch your addon, an example launching a python addon is provided below
# RSUModule::Loader::launch_addon("python", RSUModule::Loader::platform_addondir("awesome_addon")."/main.py");
###################
# RSUModule::Loader::wxperl_addon("$script", "$parameters")
# A special addon launch function for wxperl specifically, it lets you launch perl scripts using wxwidgets
# In a minimalistic perl environment, but ensures that the wxwidgets gui will work across windows, mac an linux
# (unless you make ifs that tell the moduleloader to not use wxperl on specified platforms)
###################
# Wx::MessageBox("$text", "$title", wxOK)
# Display a messagebox to the user, for more info please consult the wxwidgets documentation on
# http://docs.wxwidgets.org
###################

RSUModule::Loader::wxperl_addon(RSUModule::Loader::universal_addondir("player_lookup")."/player_lookup", "");
