
The OpenCalAccessData project is an attempt to publish information about the CalAccess data dump that is
released by the California Secretary of State's office, Political Reform Division and publish "fixes" to
data so that others might find this information more valuable.

* Requirements

- MySQL
- perl
- head, grep and other Unix-like utilities

If you have any suggestions or questions, please contact me at:

ray the round thing with a lower case A in it ganymede the bottom half of a colon org

If you mention "OpenCalAccessData" in the Subject, it will make it more likely that I will see your message.

* Scripts

* 00_fix_dload_files
* 01_import
* 02_create
* 03_fix_dates
* 04_mark_high_amends
* 05_check_filed_counts
* 06_drop_cds
* 09_move_database
* 0a_test_data
* check_filing_id
* check_states
* options.pl

* Details

These scripts rely on a file, ~/.opencalaccess, in which you can declare ivars for dependencies in your local
environment. My copy of this file is similar to this:

     # Defining executable paths here so that this can run on different platforms.
     #
     mysql /usr/bin/mysql
     head /usr/bin/head
     cat /bin/cat
     
     # Perhaps host-specific file system paths
     #
     tmpDir /tmp
     projectDir /home/ray/Projects
     dataDir /home/ray/Projects/OpenCalAccessData
     
     # user-specific information
     #
     dbName calaccess
     dbUser ray
     dbPwd zekretWrd

* 00_fix_dload_files

A newer script. Trying to correct problems in the data that break or bother the import. As I am developing
better ways to correct the errors in the files, the code gets more concise. The good thing is that once an
error appears in the files, it will probably stay there forever. The SoS cannot correct data as filed. There
are some files they produce and so they can fix them. It is not clear that they feel any need to do so.

* 01_import

This script uses the columns listed in the import file to create a table that has blob columns. It is (fairly)
safe to import into this table and most errors do not break the import. The ones that do, such as when extra
tabs are found and throw off the column count, need to be fixed.

A new pk value is added to the beginning of each line in the import file.

The raw tables have the suffix "_cd" on their names. After the data is transferred to the cleaned-up tables, the
"cd" tables can get dropped later.

This script will always drop and create the cd table or tables.

* 02_create

This script pulls the data from the "cd" table or tables and puts it into properly defined tables. See the
"tableCols.txt" file for the table column definitions. This file is used by many of the scripts.

This script will always drop and create the target table or tables.

These tables use the proper and intended data types, int, char(len), varchar(len) and so on. They do not
use date or (the one time it occurs) datetime columns, but use a "varchar(100)" for these columns. The
06_check_date_convs script will check that the values in these columns could be converted to a date or datetime,
but the column definition is not changed. If it was to be changed, the applications that use these tables would
have to sense whether the columns are text or date values. It is not clear this is a benefit to having the
database track these as dates, instead of as strings.

A fair amount of data validation, at least to the structure of the data, is done here. This script will not
show complaints if a phone number is "ABC-DEF-GHIJ", but it will complain if a 40 character string is handed
in as a phone nummber. This mostly happens not because someone actually handed in a phone number like that,
but because columns have been transposed, or extra tabs are found, or tabs are missing.

There is a lot of data validation still to do after this step, but most of that has to do with the meaning of
the data values and not the structure.

* 03_fix_dates

The SoS database stores dates as "12/29/2000 12:00:00 AM". This form is used even when the date is really
just a date and does not have a time associated with it. I turn these into MySQL-compatible strings, so that
the previous value becomes "2000-12-29". I do not turn these columns into date or datetime columns, but this
could be done if desired.

This script can be run at any time and it does not damage any of the data. It matches only on date or datetime
values in the old format and does not update any data that is in the correct format.

If this script has already been run, it does not damage corrected rows. It can be run multiple times without
worry.

* 04_mark_high_amends

* 05_check_filed_counts

Two extra tables are produced, the filings_counted table and the filers_counted table. This table tells us,
for a particular filing or filer, how many rows appear in other tables. For example, a Late Contribution form
will have a cvr_campaign_disclosure row, some number of s498 rows, and some other rows. Approximately
1 million of the 1.5 million filings in the system have no rows at all. They are filed as paper only, but
the SoS adds the information about them into the filer_filings table.

TODO: These filings_counted should include the form_id of the filing. It would be very helpful.

This script can be run at any time and it does not damage any of the data.

* 06_drop_cds

This script will drop the tables produced by the 01_import script. They can be re-created at will.

* 09_move_database

This script takes two database names as parameters. It creates the target database if necessary and
moves the tables from the source database, the 1st parameter, to the target database, the 2nd parameter.

* 0a_test_data

TBD: Tests things to see if they are correct, whatever that means.


