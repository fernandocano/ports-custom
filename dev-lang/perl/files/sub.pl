
open(INF, "<./config.orig") or die "cant open file";
@contents = (<INF>);
close(INF);
open(OUF, ">./config.sh") or die "cant write";

foreach $line (@contents) {
	$x = $line;
	if ($line =~ /glibpth/ ||
		$line =~ /libpth/ ||
		$line =~ /locincpth/ ||
		$line =~ /loclibpth/ ||
		$line =~ /libsdirs/ ||
		$line =~ /libsfound/ ||
		$line =~ /libspath/ ||
		$line =~ /xlibpth/ ) {
		$x =~ s/='.+'/=''/;
	}
	
	if ($line =~ /install/ ) {
		$x =~ s/(\/usr)\/local/\1\/x86_64-pc-linux-uclibc\1/g;
	}

	print OUF $x;
}

close(OUF);


