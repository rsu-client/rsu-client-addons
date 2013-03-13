# The package line is the identifier for the addon
# the package name should ALWAYS be foldername::moduleloader
package player_lookup::moduleloader;

# Use Cwd so we can find stuff in our own directory
use Cwd;

# Get the cwd which is this addons directory
my $cwd = getcwd;

# Use the addons framework which will provide access to some useful functions
use addon::framework;

# Make a variable to contain the info if Wx is loaded or not
my $Wx_Loaded = 1;
	
# Try to use Wx, if it fails then die with the message that Wx is not installed
eval "use Wx"; $Wx_Loaded = 0 if $@;

###############
## Functions ##
###############
# rsu::files::clientdir();
# returns the path to the client this, this is $HOME/.config/runescape if 
# the client is installed in a systemwide location, otherwise it will
# return the output of Cwd::abs_path()
###################
# addon::framework::execr("$command", "$parameters")
# This function will launch a command of your choice with the specified parameters (passing $parameters is optional)
# and return the output once the command is finished.
# Use this to launch your addon, an example launching a python script is provided below (uses system python)
# addon::framework::execr("python", rsu::files::clientdir()."/main.py");
###################
# addon::framework::run("$command", "$parameters")
# Runs a command and does not wait for the process to finish (returns instantly and returns nothing)
###################
# addon::framework::runwait("$command", "$parameters")
# Runs a command waits for the process to finish (returns nothing)
###################
# addon::framework::java("$parameters")
# Runs a command executes java with the passed parameters and returns the output once the command is finished
###################
# Wx::MessageBox("$text", "$title")
# Display a messagebox to the user, for more info please consult the wxwidgets documentation on
# http://docs.wxwidgets.org
# Remarks: Will crash the script if $Wx_Loaded is not 1
###################
# You can use "$^O" to detect the current operating system
# Output = Platform
# MSWin32 = Windows
# linux = Linux
# darwin = darwin or MacOSX
###################
# LAST NOTE:
# While the notice above covers the basics...
# the moduleloader (and any perl scripts/modules it uses require on)
# will have access to the whole rsu api.
# run "rsu-query help" or "rsu-query.exe help" for more information
###################

# Require the actual addon
require "$cwd/player_lookup";

# Every package must return true (1)
1;
