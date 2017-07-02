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
use POSIX;

my ($rpt) = @ARGV;

#read rpt file
my %Elms;
my $LKCount = 0;

open(RPT, "<", $rpt);
while(<RPT>){
	if(m/\s+Load Case:\s+SC(\d+):\s(.*), A\d+:Static Subcase/){
		$LKCount++;
	}
	elsif($LKCount == 2){
		last;
	}
	}
	elsif(m/^\s*(\d+)\s+(\S+)(\s*)$/){
		my $EID = $1;
		$Elms{$EID} = 1;
	}
}
close(RPT);

#print low RF group
open(LRF, ">", "ElementsInRPT.ses");
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
