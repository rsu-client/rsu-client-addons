#!/usr/bin/perl -w

# Use FindBin module to get script directory
use FindBin;

# Load the required Wx modules
use Wx::Perl::Packager;
use Wx qw[:everything];
use Wx::XRC;

# Use LWP::Simple module to get website content (crossplatform)
use LWP::Simple;

# Make sure the script works on almost any localization
use Encode::Byte;

# Load the runescape script inside this loader 
#(if this loader is packaged with PAR::Packer this 
#will let the perl script run inside the compressed perl)
require "$FindBin::RealBin/highscore_viewer";

# Exit the script when done
exit
