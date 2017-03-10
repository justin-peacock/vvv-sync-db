#!/bin/bash
#
# Sync the sql files in the sync folder
#
# The files in the {vvv-dir}/database/sync/ directory should be created by
# mysqldump or some other export process that generates a full set of SQL commands
# to create the necessary tables and data required by a database.
#
# For a sync to work properly, the SQL file should be named `db_name.sql` in which
# `db_name` matches the name of a database already created in {vvv-dir}/database/init-custom.sql
# or {vvv-dir}/database/init.sql.
#
# If a filename does not match an existing database, a database will be created using the
# filename as the database name and the sql file imported into that database.
#
# If tables already exist for a database, the new sql file will overwrite the current tables
# in the database.

# Move into the sync directory (and create it if it doesn't exist)
printf "\nStart MySQL Database Import\n"
mkdir -p /srv/database/sync/
cd /srv/database/sync/

# Parse through each file in the directory and use the file name to
# import the SQL file into the database of the same name
sql_count=`ls -1 *.sql 2>/dev/null | wc -l`
if [ $sql_count != 0 ]
then
	for file in $( ls *.sql )
	do
	pre_dot=${file%%.sql}
	mysql_cmd='SHOW TABLES FROM `'$pre_dot'`' # Required to support hypens in database names
	db_exist=`mysql -u root -proot --skip-column-names -e "$mysql_cmd"`
	if [ "$?" != "0" ]
	then
			# Create and import database if it does not already exist
			printf "  * Creating Database $pre_dot\n"
			mysql -u root -proot -e "CREATE DATABASE $pre_dot"
			mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $pre_dot.* TO 'wp'@'localhost' IDENTIFIED BY 'wp'"
			mysql -u root -proot $pre_dot < $pre_dot.sql
			printf "  * Created Database $pre_dot!\n"
	else
		if [ "" == "$db_exist" ]
		then
			# Import the database if it does not already exist
			printf "mysql -u root -proot $pre_dot < $pre_dot.sql\n"
			mysql -u root -proot $pre_dot < $pre_dot.sql
			printf "  * Import of $pre_dot successful\n"
		else
			# Refresh database with new data from sync folder
			printf "  * Refreshing $pre_dot...\n"
			mysql -u root -proot -Nse 'show tables' $pre_dot | while read table; do mysql -u root -proot -e "SET FOREIGN_KEY_CHECKS = 0; drop table $table" $pre_dot; done
			mysql -u root -proot $pre_dot < $pre_dot.sql
			printf "  * Done Refreshing $pre_dot\n"
		fi
	fi
	done
	printf "Databases imported\n"
else
	printf "No custom databases to import\n"
fi
