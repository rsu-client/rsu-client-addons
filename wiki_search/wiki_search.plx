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
# Detect the current OS
my $OS = "$^O";

# Add the universal addons directory to the include path
unshift @INC, "$cwd/modules";

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

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;

# Do a check to see if Wx::Html is supported
my $wxhtml = 1;
eval "use Wx::Html"; $wxhtml = 0 if $@;

# If Wx::Html cannot be loaded
if ($wxhtml =~ /^0$/)
{
    # Tell user that they need a newer version of the rsu-query
    Wx::MessageBox("Wx::Html is needed in order to support this addon!\nFollow the step for your platform below.\n\nLinux: Update your client to version 4.1.1 or newer\nMac: Reinstall the client or update the rsu-api\nWindows: Restart the client and choose yes to update the runtime.", "Wx::Html not available", wxOK);
    
    # Kill the addon
    die "Wx::Html is needed in order for this addon to work,\nplease update your client and rsu-query runtime!\n";
}

# Which events shall we include
use Wx::Event qw(EVT_BUTTON EVT_LISTBOX_DCLICK EVT_TEXT_ENTER);

# Require the rsu grand exchange module
require rsu::wiki;

use base qw(Wx::Frame);

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
    
    set_layout($self);
    
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

sub set_layout
{
    # Get the pointers
    my $self = shift;
    
    # Find the widgets
    # $self->objectname = $self->FindWindow('objectname');
    $self->{search} = $self->FindWindow('search');
    $self->{rswikipanel} = $self->FindWindow('rswikipanel');
    $self->{searchfor} = $self->FindWindow('searchfor');
    $self->{lb_results} = $self->FindWindow('lb_results');
    $self->{lb_hint} = $self->FindWindow('lb_hint');
    $self->{lb_search} = $self->FindWindow('lb_search');
    $self->{mainpanel} = $self->FindWindow('mainpanel');
    
    # Create a boxsizer to contain the itemlist
    $self->{sizer} = Wx::BoxSizer->new(wxVERTICAL);
    
    # Create the itemlist (simplehtmllistbox)
    my $choices = [  ];
    $self->{wikilist} = Wx::SimpleHtmlListBox->new($self->{rswikipanel}, -1, wxDefaultPosition, wxDefaultSize, $choices, wxHLB_DEFAULT_STYLE );
    
    # Add the itemlist to the sizer
    $self->{sizer}->Add($self->{wikilist}, 1, wxALL|wxEXPAND, 5);
    
    # Add sizer to searchpanel
    $self->{rswikipanel}->SetSizer($self->{sizer});
    
    # Give the itemname box focus
    $self->{searchfor}->SetFocus;
    
    # Set the icon for the window
	$self->SetIcon(Wx::Icon->new("$cwd/bitmaps/icon.png", wxBITMAP_TYPE_PNG));
	
	# Set the colors for the widgets
	set_colors($self);
    
    # Set default size
	$self->SetSize(420,440);
	
	# Make sure the window cannot be resized smaller
	$self->SetMinSize($self->GetSize);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_colors
{
	# Get the passed data
	my ($self) = @_;
	
	# Set the colors
    $self->{rswikipanel}->SetBackgroundColour(Wx::Colour->new("#000000"));
    $self->{rswikipanel}->SetForegroundColour(Wx::Colour->new("#000000"));
    $self->{lb_search}->SetBackgroundColour(Wx::Colour->new("#000000"));
    $self->{lb_search}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
    $self->{lb_hint}->SetBackgroundColour(Wx::Colour->new("#000000"));
    $self->{lb_hint}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
    $self->{lb_results}->SetBackgroundColour(Wx::Colour->new("#000000"));
    $self->{lb_results}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
    $self->{mainpanel}->SetBackgroundColour(Wx::Colour->new("#000000"));
    $self->{mainpanel}->SetForegroundColour(Wx::Colour->new("#000000"));
    $self->{wikilist}->SetBackgroundColour(Wx::Colour->new("#222222"));
    $self->{wikilist}->SetForegroundColour(Wx::Colour->new("#222222"));
    $self->{search}->SetForegroundColour(Wx::Colour->new("#000000"));
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
    
    # Find the widgets
    # $self->objectname = $self->FindWindow('objectname');
    
    # Setup the button event that triggers a GE search
    EVT_BUTTON($self, Wx::XmlResource::GetXRCID('search'), \&search_wiki);
    EVT_LISTBOX_DCLICK($self, $self->{wikilist}, \&view_wiki);
    EVT_TEXT_ENTER($self, Wx::XmlResource::GetXRCID('searchfor'), \&search_wiki);
    
}

#
#---------------------------------------- *** ----------------------------------------
#

sub view_wiki
{
    # Get the passed data
    my ($self) = @_;
    
    # Get the selected item info
    my $article = $self->{wikilist}->GetString($self->{wikilist}->GetSelection);
    
    # Remove everything but the id
    $article =~ s/<div id=\"(.+)\">.*/$1/;
    
    # Open the item on the grand exchange webpage
    Wx::LaunchDefaultBrowser("http://services.runescape.com$article");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub search_wiki
{
    # Get the passed data
    my ($self) = @_;
    
    # Get the amount of indexes in the itemlise
    my $indexes = $self->{wikilist}->GetCount;
    
    # Make a for loop to clear the itemlist
    my $counter;
    for ($counter = 0; $counter <= $indexes; $counter++)
    {
        # Delete an index in the itemlist
        $self->{wikilist}->Delete(0);
    }
    
    # If the searchbox is not empty
    if ($self->{searchfor}->GetValue !~ /^$/)
    {
        # Do an item search on the Grand Exchange
        my @result = rsu::wiki::searchwiki($self->{searchfor}->GetValue);
        
        # For item we found
        foreach my $article(@result)
        {
            # Make an array to keep the item data
            my @wikidata = split /;/,$article;
            
            # Add the item to the item list
            $self->{wikilist}->Append("<div id=\"$wikidata[0]\"><font color=#E8B13F>$wikidata[1]</font></div>");
        }
        
    }
    # Else
    else
    {
        # Tell user that they need to enter an item name
        Wx::MessageBox("Enter something to search for before searching!", "Enter something to search for!",wxOK,$self);
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
