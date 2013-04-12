#!/usr/bin/perl -w

# Be strict to avoid messy code
use strict;

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
	unshift @INC, "$scriptdir/lib";
	
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
		# Change the $cwd to $HOME/.config/runescape/modules/addons/linux/fullscreen_emu
		$cwd = $ENV{"HOME"}."/.config/runescape/modules/addons/linux/fullscreen_emu";		
	}
	elsif ($OS =~ /MSWin32/)
	{
		# Set the $cwd to $cwd."/modules/addons/linux/fullscreen_emu"
		$cwd = $cwd."/modules/addons/linux/fullscreen_emu"
	}
	else
	{
		# Set the $cwd to $cwd."/modules/addons/linux/fullscreen_emu"
		$cwd = $cwd."/../../../modules/addons/linux/fullscreen_emu"
	}
}


#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON EVT_TEXT_ENTER);

use base qw(Wx::Frame Wx::ScrolledWindow);

# Require our custom module lib::nobars
require lib::nobars;

# Require the files::IO module
require rsu::files::IO;

# Require the files::clientdir module
require rsu::files::clientdir;

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
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('btn_save'), \&saveconf);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('btn_defaults'), \&restore_defaults);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('btn_resize'), \&doresize);
	
	
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
	$self->{txt_x} = $self->FindWindow('txt_x');
	$self->{txt_y} = $self->FindWindow('txt_y');
	$self->{txt_height} = $self->FindWindow('txt_height');
	$self->{txt_width} = $self->FindWindow('txt_width');
	
	# Set the icon for the window
	#$self->SetIcon(Wx::Icon->new("$cwd/icon.png", wxBITMAP_TYPE_PNG));
	
	# Load the saved config
	loadconfig($self);
	
	# Set default size
	$self->SetSize(455,355);
	
	# Make sure the window cannot be resized smaller
	$self->SetMinSize($self->GetSize);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
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

sub loadconfig
{
	# Get the passed data
	my ($self) = @_;
	
	# Restore the default values
	$self->{txt_x}->SetValue(rsu::files::IO::readconf("X_offset","-4","fullscreen_emu.conf"));
	$self->{txt_y}->SetValue(rsu::files::IO::readconf("Y_offset","-45","fullscreen_emu.conf"));
	$self->{txt_width}->SetValue(rsu::files::IO::readconf("W_offset","0","fullscreen_emu.conf"));
	$self->{txt_height}->SetValue(rsu::files::IO::readconf("H_offset","36","fullscreen_emu.conf"));
}

#
#---------------------------------------- *** ----------------------------------------
#

sub saveconf
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# Write the config
	rsu::files::IO::WriteFile("X_offset=".$self->{txt_x}->GetValue(), ">>", rsu::files::clientdir::getclientdir()."/share/configs/fullscreen_emu.conf");
	rsu::files::IO::WriteFile("Y_offset=".$self->{txt_y}->GetValue(), ">>", rsu::files::clientdir::getclientdir()."/share/configs/fullscreen_emu.conf");
	rsu::files::IO::WriteFile("W_offset=".$self->{txt_width}->GetValue(), ">>", rsu::files::clientdir::getclientdir()."/share/configs/fullscreen_emu.conf");
	rsu::files::IO::WriteFile("H_offset=".$self->{txt_height}->GetValue(), ">>", rsu::files::clientdir::getclientdir()."/share/configs/fullscreen_emu.conf");
	
	# Tell that everything is saved
	Wx::MessageBox("Configuration saved to:\n".rsu::files::clientdir::getclientdir()."/share/configs/fullscreen_emu.conf", "Configuration Saved!", wxOK);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub restore_defaults
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# Restore the default values
	$self->{txt_x}->SetValue("-4");
	$self->{txt_y}->SetValue("-45");
	$self->{txt_width}->SetValue("0");
	$self->{txt_height}->SetValue("36");
	
	# Tell that all values are restored
	Wx::MessageBox("All values are now restored to default!\nClick the Save Config button to overwrite your config file.", "Configurations Restored!", wxOK);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub doresize
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# Run our external function
	my $run = lib::nobars::remove_bars($self->{txt_x}->GetValue(),$self->{txt_y}->GetValue(),$self->{txt_width}->GetValue(),$self->{txt_height}->GetValue());
	
	# If wmctrl did not run (not installed) then
	if ($run eq '0')
	{
		Wx::MessageBox("Can't find wmctrl in /usr/bin\nWhich is needed to do the resizing.\nPlease install wmctrl from your Linux distributions Software Repository,\nthen click the button again. :)", "Command wmctrl not found!", wxOK);
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
