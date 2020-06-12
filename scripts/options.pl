
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
}

sub option {
    return $option{$_[0]};
}

# $my = option("mysql")." -u ".option("dbUser")." --password=".option("dbPwd")." ".&option("dbName");
# $myV = option("mysql")." -u ".option("dbUser")." --password=".option("dbPwd")." -vvv ".&option("dbName");
# $myVF = option("mysql")." -u ".option("dbUser")." --password=".option("dbPwd")." -vvv --force ".&option("dbName");
# $myQ = option("mysql")." -u ".option("dbUser")." --password=".option("dbPwd")." --skip-column-names ".&option("dbName");
# $myQF = option("mysql")." -u ".option("dbUser")." --password=".option("dbPwd")." --skip-column-names --force ".&option("dbName");
# $myNo = option("mysql")." -u ".option("dbUser")." --password=".option("dbPwd");

$my = option("mysql")." ".&option("dbName");
$myV = option("mysql")." -vvv ".&option("dbName");
$myVF = option("mysql")." -vvv --force ".&option("dbName");
$myQ = option("mysql")." --skip-column-names ".&option("dbName");
$myQF = option("mysql")." --skip-column-names --force ".&option("dbName");
$myNo = option("mysql");

sub db_exists {
    $dbName = $_[0];
    $cmd = "echo \"show databases;\" | ".&option("mysql");
    @dbs = `$cmd`;
    chomp(@dbs);
    foreach (@dbs) {
        if ($_ eq $dbName) { return 1; }
    }
    return 0;
}

1;
