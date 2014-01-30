
#
# The values I have defined in my .opencalaccess file are:
#
# mysql - the executable path
# tmpDir /tmp
#
# for my MySQL database:
#
# dbName
# dbUser
# dbPwd
#
# projectDir - the directory above my OpenCalAccess directory
# dataDir
#
# Values are returned to the scripts via the "options" sub-routine.
#

my %option = ();

if ( -f $ENV{"HOME"}."/.opencalaccess" ) {
    open OPT, $ENV{"HOME"}."/.opencalaccess";

    while (<OPT>) {
        chomp;
        my $line = $_;

        if ($line !~ /^#/ && $line ne "") {
            ($first, $second) = split ' ', $line;
            $option{$first} = $second;
        }
    }
}

sub option {
    return $option{$_[0]};
}

1;
