#!/usr/bin/perl -w

# Use FindBin module to get script directory
use FindBin;

# Load the required Wx modules
use Wx::Perl::Packager;
use Wx qw[:everything];
use Wx::XRC;

# Use LWP::Simple module to get website content (crossplatform)
use LWP::Simple;

# Include the byte encryption so that the script will work on all localizations of windows
# Odd i know, but it is caused by the windows codepages (like chcp 1252 which is scandinavian)
use Encode::Byte;

# Load the runescape script inside this loader 
#(if this loader is packaged with PAR::Packer this 
#will let the perl script run inside the compressed perl)
require "$FindBin::RealBin/player_lookup";

# Exit the script when done
exit
