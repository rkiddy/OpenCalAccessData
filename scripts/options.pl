
my %option = ();

if ( -f $ENV{"HOME"}."/.opencalaccess" ) {

    open OPT, $ENV{"HOME"}."/.opencalaccess";

    while (<OPT>) {
        chomp;
        my $line = $_;

        if ($line !~ /^#/ && $line ne "") {
            ($first, $second) = split ' ', $line;
            $option{$first} = $second;
            # print "option(".$first.") = \"".$second."\"\n";
        }
    }
} else {

    print "\n\nERROR: Please put in a .opencalaccess file in your HOME directory.\n\n";

    exit(0);
}

sub option {
    return $option{$_[0]};
}

sub set_up_options {

    $date = $_[0];

    if (&option("host") eq "mac") {

        $my = option("mysql")." --local-infile ".&option("dbName")."_".$date;
        $myV = option("mysql")." -vvv --local-infile ".&option("dbName")."_".$date;
        $myVF = option("mysql")." -vvv --local-infile --force ".&option("dbName")."_".$date;
        $myQ = option("mysql")." --skip-column-names --local-infile ".&option("dbName")."_".$date;
        $myQF = option("mysql")." --skip-column-names --local-infile --force ".&option("dbName")."_".$date;
        $myNo = option("mysql");
    }

    if (&option("host") eq "aws") {

        $u = " -u ".option("dbUser")." --password=".option("dbPwd");

        $my = option("mysql").$u." --local-infile ".&option("dbName")."_".$date;
        $myV = option("mysql").$u." -vvv --local-infile ".&option("dbName")."_".$date;
        $myVF = option("mysql").$u." -vvv --local-infile --force ".&option("dbName")."_".$date;
        $myQ = option("mysql").$u." --skip-column-names --local-infile ".&option("dbName")."_".$date;
        $myQF = option("mysql").$u." --skip-column-names --local-infile --force ".&option("dbName")."_".$date;
        $myNo = option("mysql").$u;
    }
}

$no2 = "2>/dev/null";

#sub db_exists {
#    $dbName = $_[0];
#    $cmd = "echo \"show databases;\" | ".$my;
#    @dbs = `$cmd`;
#    chomp(@dbs);
#    foreach (@dbs) {
#        if ($_ eq $dbName) { return 1; }
#    }
#    return 0;
#}

1;
