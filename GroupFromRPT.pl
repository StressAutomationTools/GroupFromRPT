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

my @files;

sub getrptFiles {
	#input: path (to concatenate with file name, not used to change directory)
	#output: array with rpt files
	my $path = $_[0];
	my @tempFiles = <*.rpt>;
	my @rptfiles;
	foreach my $file (@tempFiles){
		push(@rptfiles,$path."/".$file);
	}
	return @rptfiles;
}

#get rpt files from input
if(not @ARGV){
	print "No input was provided. Program will now terminate.\n";
	exit;
}
elsif($ARGV[0] eq "find"){
	#look for files in directories
	#push including path so they can be opened form a different directory
	#current directory
	push(@files,getrptFiles("."));
	#sub directory
	opendir(my $dh, $outputDir);
	my @dirs = grep {-d "$outputDir/$_" && ! /^\.{1,2}$/} readdir($dh);
	foreach my $path (@dirs){
		chdir($path);
		push(@files,getrptFiles("./".$path));
		chdir("..");
	}
}
else{
	foreach my $file (@ARGV){
		if($file =~ m/\.rpt$/){
			push(@files, $file);
		}
	}
}

open(LRF, ">", "ElementsInRPT.ses");

foreach my $file (@files){}
	#read rpt file
	my %Elms;
	my $LKCount = 0;
	my @rpt = split("/",$file);
	@rpt = split(".",@rpt[-1]);
	$rpt = @rpt[-2];

	open(RPT, "<", $file);
	while(<RPT>){
		if(m/\s+Load Case:\s+SC(\d+):\s(.*), A\d+:Static Subcase/){
			$LKCount++;
		}
		elsif($LKCount == 2){
			last;
		}
		elsif(m/^\s*(\d+)\s+(\S+)(\s*)$/){
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