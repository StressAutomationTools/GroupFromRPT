###############################################################################
#
# GroupFromRPT script
#
# created by Jens M Hebisch
#
# This script takes an rpt and extracts the element IDs from it.
# It then creates a group session file with these elements.
#
###############################################################################

use warnings;
use strict;

my @files;

@files = @ARGV;

if(not @ARGV){
	print "No input was provided. Program will now terminate.\n";
	exit;
}
elsif($files[0] eq "find"){
	@files = <*.rpt>;
}

open(LRF, ">", "ElementsInRPT.ses");

foreach my $file (@files){
	#read rpt file
	my %Elms;
	my $LKCount = 0;
	$file =~ m/(.*)\.rpt/;
	my $rpt = $1;

	open(RPT, "<", $file);
	while(<RPT>){
		if(m/\s+Load Case:\s+/){
			$LKCount++;
		}
		elsif($LKCount == 2){
			last;
		}
		elsif(m/^\s*(\d+)\s+.*$/){
			my $EID = $1;
			$Elms{$EID} = 1;
		}
	}
	close(RPT);

	#print low RF group

	print LRF "sys_poll_option( 2 )\n";
	my @EIDs = sort({$a <=> $b} keys(%Elms));
	print LRF "ga_group_create( \"".$rpt."\" )\n";
	print LRF "ga_group_entity_add( \"".$rpt."\",  \@\n";
	print LRF "\" Element ";
	foreach my $EID (@EIDs){
		print LRF "\" \/\/ \@\n\"$EID ";
	}
	print LRF "\" )\n";
	print LRF "sys_poll_option( 0 )\n";
}

