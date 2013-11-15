#!/usr/bin/perl -w

# Be strict to avoid messy code
use strict;

# Make an array with all skillnames
my @skillnames = ("Overall","Attack","Defence","Strength","Constitution","Ranged","Prayer","Magic","Cooking","Woodcutting","Fletching","Fishing","Firemaking","Crafting","Smithing","Mining","Herblore","Agility","Thieving","Slayer","Farming","Runecrafting","Hunter","Construction","Summoning","Dungeoneering","Divination");

# Make an array that contains the order of the skills for the table
my @skillorder = ("Attack","Constitution","Mining","Strength","Agility","Smithing","Defence","Herblore","Fishing","Ranged","Thieving","Cooking","Prayer","Crafting","Firemaking","Magic","Fletching","Woodcutting","Runecrafting","Slayer","Farming","Construction","Hunter", "Summoning","Dungeoneering","Divination","Overall");

# The amount of skills in RuneScape
my $skillcount = 26;

# Use FindBin module to get script directory
use FindBin;

# Use the Cwd module to get the current working directory
use Cwd;

# Get the cwd
my $cwd = getcwd;

# Name of our xrc gui resource file
my $xrc_gui_file = "windowframe.xrc";

# Disable buffering
$|=1;

# Get script directory
my $scriptdir = $FindBin::RealBin;
# Get script filename
my $scriptname = $FindBin::Script;

# The below if, checks if the script is running in standalone mode or addon mode
# If the scriptname is player_lookup then
if ($scriptname =~ /^(player_lookup|script_loader)$/)
{
	# Add the universal addons directory to the include path
	unshift @INC, "$scriptdir/modules";
	
	# Use the scriptdir as cwd
	$cwd = $scriptdir;
}

# Detect the current OS
my $OS = "$^O";

# Make a variable for users homedir
my $HOME;
# If we are on windows
if ($OS =~ /MSWin32/)
{
	# Get the environment variable for USERPROFILE
	$HOME = $ENV{"USERPROFILE"};
	# Replace all / with \
	$HOME =~ s/\//\\/g;
}
# Else we are on UNIX
else
{
	$HOME = $ENV{"HOME"};
}

# If the parameters contains --scriptpath= then
if ("@ARGV" =~ /(-|--)scriptpath=/)
{
	# If this script have a working directory in a system path
	if ($cwd =~ /^(\/usr\/s?bin|\/opt\/|\/usr\/local\/s?bin)/)
	{
		# Change the $cwd to $HOME/.config/runescape/modules/addons/universal/player_lookup
		$cwd = $ENV{"HOME"}."/.config/runescape/modules/addons/universal/player_lookup";		
	}
	elsif ($OS =~ /MSWin32/)
	{
		# Set the $cwd to $cwd."/modules/addons/universal/player_lookup"
		$cwd = $cwd."/modules/addons/universal/player_lookup"
	}
	else
	{
		# Set the $cwd to $cwd."/modules/addons/universal/player_lookup"
		$cwd = $cwd."/../../../modules/addons/universal/player_lookup"
	}
}


#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;

# FileSystem module, not used but kept as it might be used in the future
#use Wx::FS;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON EVT_TEXT_ENTER);

use base qw(Wx::Frame Wx::ScrolledWindow);

# Use LWP::Simple module to get website content (crossplatform)
eval "use LWP::Simple";

# Use an xml/rss parser for the recent player activity
eval "use XML::RSSLite"; die "Cannot load XML::RSSLite\n" if $@;

sub new
{
	# Create a class
	my $class = shift;
	
	# Assign class object to $self
	my $self = $class->SUPER::new;
	
	# Initialize everything
	$self->initialize;
	
	return $self;
}

sub initialize
{
	# Get pointers
	my $self = shift;
	
	# Create mutators for widgets (enter the objectname for every object here)
	$self->create_mutator
	(
		qw
		(
			xrc_resource
		)
	);
	
	load_xrc_gui($self);
	
	set_events($self);
	
	set_tooltips($self);
	
}

sub load_xrc_gui
{
	# Get the pointers
	my $self = shift;
	
	# Get the xrc file
	my $xrc_file = "$cwd/$xrc_gui_file";
	
	# Initialize WX
	Wx::InitAllImageHandlers();
	
	# Support for using external images (kept incase it can be used in the future)
	#Wx::FileSystem::AddHandler(Wx::InternetFSHandler->new());
	
	# Create xrc/xml resource
	$self->xrc_resource = Wx::XmlResource->new;
	# Initialize handlers
	$self->xrc_resource->InitAllHandlers;
	# Load the xrc file
	$self->xrc_resource->Load($xrc_file);
	
	# Tell what window/frame to load
	$self->xrc_resource->LoadFrame($self,undef,"mainwindow");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_events
{
	# Get the pointers
	my $self = shift;
	
	# Setup the events
	# EVT_BUTTON($self, Wx::XmlResource::GetXRCID('objectname'), \&function);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('lookup'), \&lookup_player);
	EVT_TEXT_ENTER($self, Wx::XmlResource::GetXRCID('name'), \&lookup_player);
	
	
	# Do the layout
	set_layout($self);
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_layout
{
	# Get pointers
	my $self = shift;
	
	# Find the widgets
	# $self->objectname = $self->FindWindow('objectname');
	
	# Get the highscores panel
	$self->{tab_highscores} = $self->FindWindow('tab_highscores');
	# Make it scrollable
	setScrollBars($self->{tab_highscores});
	
	# Get the recentactivity panel
	#$self->{recentactivity_panel} = $self->FindWindow('recentactivity_panel');
	
	# Get the textbox for player name input
	$self->{name} = $self->FindWindow('name');
	# Set the focus to the textbox
	$self->{name}->SetFocus();
	
	# Make 3 objects for each skill and connect them to the widgets
	foreach my $skill(@skillnames)
	{
		$self->{$skill."stats"} = $self->FindWindow($skill.'stats');
		
		if ($skill !~ /(Summoning|Dungeoneering|Divination)/)
		{
			$self->{$skill."stats07"} = $self->FindWindow($skill.'stats07');
		}
	}
	
	# Playerinfo and claninfo disabled until a way to fetch info is found
	# Get the playerbio label
	#$self->{playerinfo} = $self->FindWindow('playerinfo');
	
	# Get the claninfo label
	#$self->{claninfo} = $self->FindWindow('claninfo');
	
	# Get the mainpanel
	$self->{mainpanel} = $self->FindWindow('mainpanel');
	
	# Get the label_player
	$self->{label_player} = $self->FindWindow('label_player');
	
	# Get the highscoretable
	$self->{highscoretable} = $self->FindWindow('highscoretable');
	
	# Get the highscoretable07
	$self->{highscoretable07} = $self->FindWindow('highscoretable07');
	
	# Get the mainpanel
	$self->{tabwindow} = $self->FindWindow('tabwindow');
	
	# Get the recentactivity tab
	$self->{tab_recentactivity} = $self->FindWindow('tab_recentactivity');
	
	# Get the highscores tab
	$self->{tab_highscores07} = $self->FindWindow('tab_highscores');
	
	# Get the highscores07 tab
	$self->{tab_highscores07} = $self->FindWindow('tab_highscores07');
	
	# Get the recentactivity list
	$self->{recentactivity} = $self->FindWindow('recentactivity');
	
	# Get the chathead bitmap widget
	$self->{chathead} = $self->FindWindow('chathead');
	
	# Get the fullavatar bitmap widget
	$self->{fullavatar} = $self->FindWindow('fullavatar');
	
	# Set the icon for the window
	$self->SetIcon(Wx::Icon->new("$cwd/bitmaps/default_chat.png", wxBITMAP_TYPE_PNG));
	
	# Set default size
	$self->SetSize(580,530);
	
	# Make sure the window cannot be resized smaller
	$self->SetMinSize($self->GetSize);
	#$self->SetMaxSize(Wx::Size->new(500,9999));
	
	# Set the colors
	set_colors($self);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_colors
{
	# Get the passed data
	my ($self) = @_;
	
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Change the color of the tabwindow and mainpanel too
		$self->{mainpanel}->SetBackgroundColour(Wx::Colour->new("#000000"));
		$self->{mainpanel}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
		$self->{label_player}->SetBackgroundColour(Wx::Colour->new("#000000"));
		$self->{label_player}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
		#$self->{tabwindow}->SetBackgroundColour(Wx::Colour->new("#222222"));
		#$self->{tabwindow}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	}
	
	$self->{tab_recentactivity}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{tab_recentactivity}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	$self->{tab_highscores}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{tab_highscores}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	$self->{tab_highscores07}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{tab_highscores07}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	$self->{recentactivity}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{recentactivity}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	$self->{highscoretable}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{highscoretable}->SetForegroundColour(Wx::Colour->new("#222222"));
	$self->{highscoretable07}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{highscoretable07}->SetForegroundColour(Wx::Colour->new("#222222"));
	
	$self->{highscoretable}->SetPage('<html>
	<body bgcolor=#222222>
		<table width=100% bgcolor=#222222>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/attack.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/constitution.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/mining.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/strength.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/agility.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/smithing.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/defence.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/herblore.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/fishing.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/ranged.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/thieving.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/cooking.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/prayer.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/crafting.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/firemaking.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/magic.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/fletching.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/woodcutting.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/runecrafting.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/slayer.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/farming.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/construction.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/hunter.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/summoning.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/dungeoneering.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/divination.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/overall.png"></div></td></table></td>
			</tr>
		</table>
	</body>
</html>');

$self->{highscoretable07}->SetPage('<html>
	<body bgcolor=#222222>
		<table width=100% bgcolor=#222222>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/attack.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/constitution.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/mining.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/strength.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/agility.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/smithing.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/defence.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/herblore.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/fishing.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/ranged.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/thieving.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/cooking.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/prayer.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/crafting.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/firemaking.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/magic.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/fletching.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/woodcutting.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/runecrafting.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/slayer.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/farming.png"></div></td></table></td>
			</tr>
			<tr><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/construction.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/hunter.png"></div></td></table></td><td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src="./bitmaps/overall.png"></div></td></table></td>
			</tr>
		</table>
	</body>
</html>');
}

#
#---------------------------------------- *** ----------------------------------------
#

sub lookup_player
{
	# Get the pointers
	my $self = shift;
	
	# Get the name of the player
	my $playername = $self->{name}->GetValue();
	
	# If playername is not empty
	if ($playername !~ /^$/)
	{
		# Fetch the players stats
		fetchstats($self, $playername);
		
		# Fetch the players stats
		fetchstats07($self, $playername);
		
		# Fetch the players data
		fetchplayerdata($self, $playername);
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

# Create mutator function from "Programming Perl"
sub create_mutator
{

	my $self = shift;

	# From "Programming Perl" 3rd Ed. p338.
	for my $attribute (@_)
	{

		no strict "refs"; # So symbolic ref to typeglob works.
		no warnings;      # Suppress "subroutine redefined" warning.

		*$attribute = sub : lvalue
		{

			my $self = shift;

			$self->{$attribute} = shift if @_;
			$self->{$attribute};

		};

	}

}


### Events

sub close_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Close window
	$self->Destroy();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub setScrollBars
{
	# Get the widgets to make scrollable
	my @scrolledWindows = @_;
	
	# Set scroll properties
	my $pixelsPerUnitX = 0;#15; 
	my $pixelsPerUnitY = 15; 
	my $noUnitsX = 0;#100; 
	my $noUnitsY = 100; 
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Add information about scrolling the X axis
		$pixelsPerUnitX = 15;
		$noUnitsX = 100; 
	}
	
	# For each widget to make scrollable
	foreach my $window (@scrolledWindows)
	{
		# Enable scrolling
		$window->SetScrollbars($pixelsPerUnitX, $pixelsPerUnitY, $noUnitsX, $noUnitsY);
	} 
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_tooltips
{
	my ($self) = @_;
		
	# Set tooltips with info about the settings
	# $self->objectname->SetToolTip("message");
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_avatar
{
	# Get the passed parameters
	my ($self, $player) = @_;
	
	# If player is not default_avatar
	if ($player !~ /^default_avatar$/)
	{
		# If we are running as a standalone application
		if ("@INC" =~ /par-/)
		{
			# Fetch the chathead and full avatar from runescape.com
			getstore("http://services.runescape.com/m=avatar-rs/$player/chat.png", "$cwd/bitmaps/chat_tmp.png");
			getstore("http://services.runescape.com/m=avatar-rs/$player/full.png", "$cwd/bitmaps/full_tmp.png");
		}
		# Else we will use api calls
		else
		{
			# Require the sysdload module
			require updater::download::sysdload;
			
			# Replace spaces in the players name with %20
			$player =~ s/\s{1,1}/%20/g;
			
			# Download the chathead and full avatar from runescape.com
			updater::download::sysdload::sysdownload("http://services.runescape.com/m=avatar-rs/$player/chat.png", "$cwd/bitmaps/chat_tmp.png");
			updater::download::sysdload::sysdownload("http://services.runescape.com/m=avatar-rs/$player/full.png", "$cwd/bitmaps/full_tmp.png");
		}
		
		# Load the downloaded chathead into the window
		$self->{chathead}->SetBitmap(Wx::Bitmap->new("$cwd/bitmaps/chat_tmp.png", wxBITMAP_TYPE_PNG));
		# Load the downloaded full avatar into the window
		$self->{fullavatar}->SetBitmap(Wx::Bitmap->new("$cwd/bitmaps/full_tmp.png", wxBITMAP_TYPE_PNG));
	}
	else
	{
		# Load the downloaded chathead into the window
		$self->{chathead}->SetBitmap(Wx::Bitmap->new("$cwd/bitmaps/default_chat.png", wxBITMAP_TYPE_PNG));
		# Load the downloaded full avatar into the window
		$self->{fullavatar}->SetBitmap(Wx::Bitmap->new("$cwd/bitmaps/default_full.png", wxBITMAP_TYPE_PNG));
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_playerinfo
{
	# Get the passed data
	my ($self, $playerinfo) = @_;
	
	# Replace member:true with member:Yes
	$playerinfo =~ s/member:true/member:Yes/;
	# Replace member:false with member:No
	$playerinfo =~ s/member:false/member:No/;
	
	# If the player is in a clan
	if ($playerinfo =~ /,clan:/)
	{
		# Fish out the player name, title and memberstatus
		$playerinfo =~ s/^member:(.+),title:(|.+),clan:.+,name:(.+),recruiting:.+,world.*/Name: $3\nTitle: $2\nMember: $1/g;
	}
	# Else player is not in a clan
	else
	{
		# Fish out the player name, title and memberstatus
		$playerinfo =~ s/^member:(.+),title:(|.+),name:(.+),world.*/Name: $3\nTitle: $2\nMember: $1/g;
	}
	
	# Add the info to the window
	$self->{playerinfo}->SetLabel($playerinfo);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_claninfo
{
	# Fetch the passed data
	my ($self, $claninfo) = @_;
	
	# If the player is in a clan
	if ($claninfo =~ /,clan:/)
	{
		# Fish out the clan name (if any) and prepare it for the label
		$claninfo =~ s/^.+,clan:(.+),n.+,recruiting:(true|false),w.+/Clan:  $1\nRecruiting: $2/g;
		
		# Replace true with Yes and false with No
		$claninfo =~ s/Recruiting: true/This clan is currently\nrecruiting people!/;
		$claninfo =~ s/Recruiting: false/This clan is currently\nNOT recruiting people./;
	}
	# Else
	else
	{
		# Set Clan and Recruiting to empty
		$claninfo = "Clan: ";
	}
	
	# Add the clanstatus into the window
	$self->{claninfo}->SetLabel($claninfo);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_recent_activity
{
	# Get the passed data
	my ($self, $player) = @_;
	
	# Fetch the recent activity rss feed
	my $rssfeed = readurl("http://services.runescape.com/m=adventurers-log/rssfeed?searchName=$player");
	
	# Make a hash reference for the RSSLite parser
	my %recent_activity;
	
	# Parse the RSSfeed
	parseRSS(\%recent_activity, \$rssfeed);
	
	# Make a variable to contain the players activity
	my $activity = "<html>
	<body bgcolor=\"#222222\">";
	
	# For each value in the array
	foreach my $item (@{$recent_activity{'item'}})
	{
		# Get the published date so we can remove the unused time
		my $pubDate = "$item->{'pubDate'}";
		
		# Remove the timestamp because it is always 00:00:00 GMT
		$pubDate =~ s/\s+\d{2,2}:\d{2,2}:\d{2,2}\s+GMT//g;
		
		# Append the recent activity to the string
		$activity = "$activity
		<table width=100%>
			<td>
				<b>
					<font color=#E8B13F size=3>$item->{'title'} - $pubDate</font>
				</b>
			</td>
		</table>
		<table width=100%>
			<td>
				<font color=#B8B8B8 size=2>$item->{'description'}</font>
			</td>
		</table>
		<hr>";
	}
	
	# Add the closing tags to the activity list
	$activity = "$activity
	</body>
</html>";
	
	# Fix some stuff in the finished activity list
	#$activity =~ s/(&#8217;|&APOS;)/'/gi;
	#$activity =~ s/(&#8211;)/-/gi;
	#$activity =~ s/(&#13;|&#10;|&#9;)//gi;
	
	# Add the recent activity to the window
	$self->{recentactivity}->SetPage($activity);
	
	# Make the label wrap
	#$self->{recentactivity}->Wrap(400);
	
	# Make it scrollable
	#setScrollBars($self->{recentactivity_panel});
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_playerbio
{
	# Get the passed data
	my ($self, $player) = @_;
	
	# Fetch the player details
	#my $jquerystring = readurl('http://services.runescape.com/m=website-data/g=runescape/playerDetails.ws?names=["'.$player.'"]&callback=jQuery000000000000000_0000000000');
	
	# Remove unneeded parts of the output
	#$jquerystring =~ s/(jQuery000000000000000_0000000000\(\[\{|"|\}\]\);)//g;
	
	# Disabled until a player bio solution is found
	# Parse and set the player claninfo
	#set_claninfo($self, $jquerystring);
	
	# Parse and set the playerbio info
	#set_playerinfo($self, $jquerystring);
	
	# Parse the players recent activity and display it on the window
	set_recent_activity($self,$player)
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetchplayerdata
{
	# Get the passed data
	my ($self, $player) = @_;
	
	## NOTE: set_avatar() call have been moved into fetchstats() as
	## we can quickly detect if user is member or not when checking highscores
	
	# Fetch the players recent activity and info
	set_playerbio($self, $player);
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetchstats
{
	# Get pointers
	my ($self, $player) = @_;

	# Make a variable to contain the highscores of a player
	my $highscore;
	
	# Get the highscores info of a player
	$highscore = readurl("http://hiscore.runescape.com/index_lite.ws?player=$player");
	
	# Suppress "uninitialized string" warning if lookup failed
	no warnings;
	
	# If $highscore is empty
	if ($highscore eq '')
	{
		# Tell in console that we found nothing
		print "Player do not exist or is F2P account\n\n";
		
		# Set highscore to null
		$highscore = '0';
		
		# Fetch the players display pictures and load them into the window
		set_avatar($self, "default_avatar");
	}
	else
	{
		# Fetch the players display pictures and load them into the window
		set_avatar($self, $player);
	}

	# Enable warnings again
	use warnings;
	
	# Make a hash table containing the skill stats
	my $highscoretable = {};

	# If fetching highscore data was successful
	if ($highscore !~ /^0$/)
	{
		# Split the data by whitespace
		my @playerdata = split /\s/, $highscore;
		
		# Make a for loop that goes through the highscores info
		my $counter;
		for ($counter = 0; $counter <= $skillcount; $counter++)
		{
			# Split the playerdata by ,
			my @skilldata  = split /,/, $playerdata[$counter];
			
			# If skill is ranked
			if ($skilldata[0] !~ /-1/)
			{
				# Make numbers more readable (by ivanpu)
				$skilldata[0] = commify($skilldata[0]);
				$skilldata[2] = commify($skilldata[2]);
				print "$skilldata[0]\n";
				
				# Set the info into the level and rank labels of the skill
				$highscoretable->{$skillnames[$counter]} = "<td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: $skilldata[1]<br>Rank: $skilldata[0]<br>XP: $skilldata[2]</font></td><td valign=top><div align=right><img src=\"./bitmaps/".lc($skillnames[$counter]).".png\"></div></td></table></td>";
			}
			# Else
			else
			{
				# Set the info as Not Available
				$highscoretable->{$skillnames[$counter]} = "<td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src=\"./bitmaps/".lc($skillnames[$counter]).".png\"></div></td></table></td>";
			}
		}
	}
	else
	{
		# Make a for loop that goes through the highscores info
		my $counter;
		for ($counter = 0; $counter <= $skillcount; $counter++)
		{	
			# Set the info as Not Available
			$highscoretable->{$skillnames[$counter]} = "<td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src=\"./bitmaps/".lc($skillnames[$counter]).".png\"></div></td></table></td>";
		}
	}
	
	# Set the highscores
	set_highscoretable($self,$highscoretable,$skillcount)
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetchstats07
{
	# Get pointers
	my ($self, $player) = @_;

	# Make a variable to contain the highscores of a player
	my $highscore;
	
	# Get the highscores info of a player
	$highscore = readurl("http://services.runescape.com/m=hiscore_oldschool/index_lite.ws?player=$player");
	
	# Suppress "uninitialized string" warning if lookup failed
	no warnings;
	
	# If $highscore is empty
	if ($highscore eq '')
	{
		# Tell in console that we found nothing
		print "Player do not exist or is F2P account\n\n";
		
		# Set highscore to null
		$highscore = '0';
	}

	# Enable warnings again
	use warnings;

	# Make a hash table containing the skill stats
	my $highscoretable = {};

	# If fetching highscore data was successful
	if ($highscore !~ /^0$/)
	{
		# Split the data by whitespace
		my @playerdata = split /\s/, $highscore;
		
		# Make a for loop that goes through the highscores info
		my $counter;
		for ($counter = 0; $counter <= 23; $counter++)
		{
			# Split the playerdata by ,
			my @skilldata  = split /,/, $playerdata[$counter];
			
			# If skill is ranked
			if ($skilldata[0] !~ /-1/)
			{
				# Make numbers more readable (by ivanpu)
				$skilldata[0] = commify($skilldata[0]);
				$skilldata[2] = commify($skilldata[2]);
				print "$skilldata[0]\n";
				
				# Set the info into the level and rank labels of the skill
				$highscoretable->{$skillnames[$counter]} = "<td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: $skilldata[1]<br>Rank: $skilldata[0]<br>XP: $skilldata[2]</font></td><td valign=top><div align=right><img src=\"./bitmaps/".lc($skillnames[$counter]).".png\"></div></td></table></td>";
			}
			# Else
			else
			{
				# Set the info as Not Available
				$highscoretable->{$skillnames[$counter]} = "<td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src=\"./bitmaps/".lc($skillnames[$counter]).".png\"></div></td></table></td>";
			}
		}
	}
	else
	{
		# Make a for loop that goes through the highscores info
		my $counter;
		for ($counter = 0; $counter <= 23; $counter++)
		{	
			# Set the info as Not Available
			$highscoretable->{$skillnames[$counter]} = "<td bgcolor=#000000><table width=100%><td width=90%><font size=1 color=#E8B13F>Level: N/A<br>Rank: N/A<br>XP: N/A</font></td><td valign=top><div align=right><img src=\"./bitmaps/".lc($skillnames[$counter]).".png\"></div></td></table></td>";
		}
	}
	
	# Set the highscores
	set_highscoretable($self,$highscoretable,23)
}

#
#---------------------------------------- *** ----------------------------------------
#

# Method by ivanpu to make the numbers more readable
sub commify {
	# Get the passed data
	local $_  = shift;
	
	# Make higher values easier to read by adding commas
	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	
	# Return the improved number
	return $_;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_highscoretable
{
	my ($self,$highscoretable,$skills) = @_;
	
	# Make a variable to contain the htmlcontent for the highscores
	my $htmlcontent = "<html>
	<body bgcolor=#222222>
		<table width=100% bgcolor=#222222>
			<tr>";
		
	# Make a counter
	my $tables = 1;
	
	# Make a for loop
	my $counter;
	for ($counter = 0; $counter < $skills; $counter++)
	{
		# Append the htmlcontent
		$htmlcontent = $htmlcontent.$highscoretable->{$skillorder[$counter]};
		
		# If we are on the 3rd table
		if ($tables =~ /^3$/)
		{
			# Begin a new table row
			$htmlcontent = "$htmlcontent
			</tr>
			<tr>";
			
			# Reset the table counter
			$tables = 1;
		}
		# Else
		else
		{
			# Increase the table counter by 1
			$tables += 1;
		}
	}

	# End the htmlcontent
	$htmlcontent = $htmlcontent.$highscoretable->{$skillorder[-1]}."
			</tr>
		</table>
	</body>
</html>";

	# If there are only 23 skills
	if ($skills =~ /^23$/)
	{
		# Add table to the highscores07
		$self->{highscoretable07}->SetPage($htmlcontent);
	}
	# Else
	else
	{
		# Add table to the highscores
		$self->{highscoretable}->SetPage($htmlcontent);
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

# Replica of updater::download::sysdload::get
sub readurl
{
	# Get the passed data
	my ($url, $timeout) = @_;
	
	# Get the current OS
	my $OS = "$^O";
	
	# Make a variable to contain the output
	my $output;
	
	# If we are on Windows
	if ($OS =~ /MSWin32/)
	{
		# Use LWP::Simple
		eval "use LWP::UserAgent";
		
		# Make a handle for LWP
		my $lwp = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
		
		# Set the timeout
		$lwp->timeout(10) if !defined $timeout;
		$lwp->timeout($timeout) if defined $timeout;
		
		# Get the content of $url
		my $response = $lwp->get("$url");
		
		# If we successfully got the content
		if ($response->is_success)
		{
			# Decode the content
			$output = $response->decoded_content;
		}
		# Else
		else
		{
			# Make output empty
			$output = "";
		}
	}
	# Else
	else
	{
		# Make a variable which will contain the download command we will use
		my $fetchcommand = "wget -q -O-";
		
		# If /usr/bin contains wget
		if(`ls /usr/bin | grep wget` =~  /wget/)
		{
			# Use wget command to fetch files
			$fetchcommand = "wget -q --connect-timeout=10 --timeout=10 -O-" if !defined $timeout;
			$fetchcommand = "wget -q --connect-timeout=$timeout --timeout=$timeout -O-" if defined $timeout;
		}
		# Else if /usr/bin contains curl
		elsif(`ls /usr/bin | grep curl` =~  /curl/)
		{
			# Curl command equalent to the wget command to fetch files
			$fetchcommand = "curl -L --connect-timeout 10 -m 10 -#" if !defined $timeout;
			$fetchcommand = "curl -L --connect-timeout $timeout -m $timeout -#" if defined $timeout;
		}

		# Read the contents of url
		$output = `$fetchcommand '$url'`;
		
		# Remove any newlines
		#$output =~ s/(\n|\r|\r\n)//g;
	}
	
	# Return the content of $url
	return $output;
}

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package application;
use base qw(Wx::App);

sub OnInit
{
	# Get pointers
	my $self = shift;
	
	# Create mainwindow(new window)
	my $mainwindow = wxTopLevelFrame->new(undef, -1);
	
	# Set mainwindo/topwindow
	$self->SetTopWindow($mainwindow);
	
	# Show the window
	$mainwindow->Show(1);
}

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------


package main;

my $app = application->new;
$app->MainLoop;

1;
