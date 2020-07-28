# Rental Dataset Investigation With PostgreSQL

## How to setup the project:

1. Install PostgreSQL database server on your system (i.e. "https://wiki.postgresql.org/wiki/Homebrew")
1. Download the used database called dvdrental ("https://sp.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip")
1. The database file is in zipformat and need to be extracted to dvdrental.tar - i.e. 
    1. `unzip dvdrental.zip`
    1. `tar cvf dvdrental.tar dvdrental`
1. Download pgAdmin ("https://www.pgadmin.org/download/") or preferred alternative
1. Start PostgreSQL server (i.e. `brew services start postgresql`)
1. Connect pgAdmin with the PostgreSQL server you have started (i.e. localhost, port: 5432)
1. Load the DB by choosing "Restore" on the DB in the pgAdmin browser panel and load .tar file
1. Verify that tables ('actor', 'address' etc) are within the public schema

