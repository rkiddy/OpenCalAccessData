
The OpenCalAccessData project is an attempt to publish information about the CalAccess data dump that is
released by the California Secretary of State's office, Political Reform Division and publish "fixes" to
data so that others might find this information more valuable.

* Requirements

- MySQL
- perl
- head, grep and other Unix-like utilities

If you have any suggestions or questions, please contact me at:

ray the round thing with a lower case A in it ganymede the bottom half of a colon org

If you mention "open_calaccess_data_perl" in the Subject, it will make it more likely that I will see your message.

* Scripts

* 00_dload
* 00_fix_files_OLD
* 01_fix_files
* 02_import_cds
* 03_create_noncds
* 04_drop_cds
* 05_find_high_amends
* 06_check_filed_counts
* 07_create_named
* 08_create_named_uniq
* 08a_remove_name_part
* 09_fill_counts
* 10_problems_count
* 10_split_years

* Details

These scripts rely on a file, ~/.opencalaccess, in which you can declare ivars for dependencies in your local
environment. My copy of this file is similar to this:

     projectDir /Users/ray/Projects/OpenCalAccessData
     tmpDir /tmp
     
     curl /usr/bin/curl
     unzip /usr/bin/unzip
     gzip /usr/bin/gzip
     find /usr/bin/find
     diff /usr/bin/diff
     tr /usr/bin/tr
     grep /usr/bin/grep
     perl /usr/bin/perl
     head /usr/bin/head
     
     dbUser ray
     dbPwd much_zekret_word
     dbName ca_sos
     
     mysql /usr/local/mysql/bin/mysql

* 00_dload

Just downloads filedbexport.zip file and breaks it apart into the pdf and TSV files in a directory named
With the date.

* 01_fix_files

A newer script. Trying to correct problems in the data that break or bother the import. As I am developing
better ways to correct the errors in the files, the code gets more concise. The good thing is that once an
error appears in the files, it will probably stay there forever. The SoS cannot correct data as filed. There
are some files they produce and so they can fix them. It is not clear that they feel any need to do so.

* 02_import_cds

This script uses the columns listed in the import file to create a table that has blob columns. It is (fairly)
safe to import into this table and most errors do not break the import. The ones that do, such as when extra
tabs are found and throw off the column count, need to be fixed.

A new pk value is added to the beginning of each line in the import file.

The raw tables have the suffix "_cd" on their names. After the data is transferred to the cleaned-up tables, the
"cd" tables can get dropped later.

This script will always drop and create the cd table or tables.

* 03_create_noncds

This script pulls the data from the "cd" table or tables and puts it into properly defined tables. See the
"tableCols.txt" file in the scripts directory for the table column definitions. This file is used by many of the scripts.

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

* 04_drop_cds

Does the obvious.

* 05_mark_high_amends

This adds a "high_amend_id" column to the filer_filings table and adds the correct value. This should make it easier for
scripts to ignore the previous versions of the reports. TODO: It may be better to just delete the earlier versions, but there
is risk and the space may not get released on disk.

* 06_check_filed_counts

Two extra tables are produced, the filings_counted table and the filers_counted table. This table tells us,
for a particular filing or filer, how many rows appear in other tables. For example, a Late Contribution form
will have a cvr_campaign_disclosure row, some number of s498 rows, and some other rows. Approximately
1 million of the 1.5 million filings in the system have no rows at all. They are filed as paper only, but
the SoS adds the information about them into the filer_filings table.

TODO: These filings_counted should include the form_id of the filing. It would be very helpful.

This script can be run at any time and it does not damage any of the data.

* 07_create_named

Many tabls have one or more names in a row, stored in columns: xxx_naml, xxx_namf, xxx_namt, xxx_nams. This
stores each one of these as its own row, with a link to the original table and the original table and the
original prefix. Prefixes are: agent, treas, ctrib, recip, cand, and several other, more obscure, values.

* 08_create_named_uniq

Create a table of unique strings from the named table. This is the naml, namf, nams and namt column values.
Then create a named_smooth table by normalizing the (naml, namf, nams, namt) into a single string, putting
them to lower case, getting rid of extraneous characters, and generally "smoothing" the names. The
named_smooth strings are linkedback to the named_uniq rows and the named_uniq rows are linked back to the
named table.

* 08a_remove_name_part

Used by the 08_create_named_uniq script. If there are strings in the named_smooth table like 'john smith' and
'john smith mr', then this script looks for these via the ' mr' suffix, removes the longer version, and
points the named and named_uniq rows to the new, shorter string. This will also remove prefixes (usually
found to be garbage) and will also completely replace one value for another.

* 09_fill_counts

The named_smooth table has columns to store the number of linked named_uniq rows and nsmed rows. This script
creates or updates those values.

* 10_problems_count

This script will run integrity checks on the tables and put the results in special tables.

* 10_split_years

(Not ready for use) This script will break a table up into year-specific versions so that searching or listing
filings from a specific time period will be quicker. This works from matching the filing_id with the value
of the filing_date column in the filer_filings table. So, for example, if a LPAY_2019 table is being set up
and there is a row in the LPAY table whose filing_id matches up to a row in the filer_filings table that has
a filing_date value of '2019-03-15', then that row from the LPAY table will end up in the LPAY_2019 table.
Tables are created for all years between 1974 and 2020 and there is also a table for filings marked as
before or after those years, which would presumably be errors.

* 99_test_data

TBD: Tests things to see if they are correct, whatever that means.

