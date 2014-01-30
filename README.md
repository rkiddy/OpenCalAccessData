
This repository exists for two purposes. First, it is a place to record issues with the data and its structure.
Second, I can keep track of the scripts and tools that I used to fix the data.

The data itself is, right now, 3,741,089,054 bytes and I am not checking the data itself into the repository. I
think that github would not be happy about this. The first line of the import values is kept so that this can be
verified by the scripts.

The intention here is that a new copy of the data can be downloaded from the SoS web site (above) and that new
data can be integrated into the existing data. But one also should be able to re-create the database at any time
from the files.

Ray Kiddy - 2014-01-30

The scripts to do this are as follows:

* 00_fix_dload_files

A newer script. Trying to correct problems in the data that break or bother the import. There are two kinds of
files. With the first set of files, I can identify the lines that are new by some set of column values. With
those, I only need to scan for problems in new data. With some of the files, I need to replace the entire file
because I cannot tell which lines are updated or added. For these files, I need to re-fix all the problems I
see in the files.

* 01_import

This script uses the columns listed in the import file to create a table that has blob columns. It is (fairly)
safe to import into this table and most errors do not break the import. The ones that do, such as when extra
tabs are found and throw off the column count, need to be fixed.

A new pk value is added to the beginning of each line in the import file.

The raw tables have the suffix "_cd" on their names. After the data is transferred to the cleaned-up tables, the
"cd" tables could be deleted, but this is not being done now.

This script will always drop and create the cd table or tables.

* 02_create_final

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

* 03_set_empty_to_null

For some reason, you _cannot_ get the import process in MySQL to put in NULL values when the contents of
a TSV file are blank. It insists on putting them in as "". This script fixes that. It probably need not be run
3rd. The applications can deal with it if this is not run and it takes a long time to run, as most of the
columns it updates are not indexed.

This script can be run at any time and it does not damage any of the data.

* 04_fix_dates

The SoS database stores dates as "12/29/2000 12:00:00 AM". This form is used even when the date is really
just a date and does not have a time associated with it. I turn these into MySQL-compatible strings, so that
the previous value becomes "2000-12-29". I do not turn these columns into date or datetime columns, but this
could be done if desired.

This script can be run at any time and it does not damage any of the data. It matches only on date or datetime
values in the old format and does not update any data that is in the correct format.

* 05_mark_high_amends


* 06_check_date_convs

This scripts finds all of the date and datetime columns in the tables and adds a copy of the column using the
date or datetime type. If there is a problem with the data, then this update will give a warning or error.

This script can be run at any time and it does not damage any of the data.

* 07_check_filed_counts

This script creates two new tables, one to keep track of table counts for filing_id values and one to keep
track of filer_id values. There is a row for each filing_id or filer_id. In that row are the counts of the
rows in other tables associated with that filing_id or filer_id.

The new tables created are the "filers_counted" and "filings_counted" tables.

This script can be run at any time and it does not damage any of the data.

* EXTRA TABLES

Some tables are created by other processes using other tools. These may be experimental efforts and should
not be regarded as reliable in any way unless there is supporting documentation which states that the data
is reliable for some purpose.

- import_dates

This table is used to track how many records exist in what tables after each import from the SoS web site has
occurred.

- people, people_info and people_join

The "people" table has only a pk and a canonical name.

The "people_join" table links a person to the filings in which they appear. Foreign keys in the people join
table need to specify which table the person is in, the keys that uniquely identify a record, such as
filing_id-amend_id-line_item-form_type, and the role of that person, such as "enty" or "treas" or "cand".

The "people_info" table relates one of these people to a random bit of information, such as a link to a
news article about them, or some fact that was derived from some source outside of this system.

Efforts to actually identify people and connect them definitively to their records are underway, but it
will be a long row to hoe. This will not be possible to do reliably for some time.

