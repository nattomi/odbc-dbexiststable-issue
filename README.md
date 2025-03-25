# odbc dbExistsTable issue with DB2 temporary tables in version 1.6.0
Docker environment to reproduce a scenario when dbExistsTable runs into an error

## TL;DR

```
dbExistsTable(conn, Id(schema = "SESSION", table = "MY_TEMP"))
```

throws

```
Error in `$<-.data.frame`(`*tmp*`, table_remarks, value = NA_character_) :
  replacement has 1 row, data has 0
Calls: print ... tryCatchList -> tryCatchOne -> doTryCatch -> $<- -> $<-.data.frame
```

## Details

### Create a custom Docker network
```
docker network create dbnet
```

### Starting a DB2 instance
```
mkdir database
bash run_db2.sh
```

Give a few minutes for the container to properly start up. Monitor the progress with

```
docker logs -f db2_container
```

When all databases are active, then
```
$ docker exec -it db2_container bash
[root@09918f46bbba /]# su - db2inst1
Last login: Tue Mar 25 09:30:15 UTC 2025
[db2inst1@09918f46bbba ~]$ db2sampl

  Creating database "SAMPLE"...
  Connecting to database "SAMPLE"...
  Creating tables and data in schema "DB2INST1"...
  Creating tables with XML columns and XML data in schema "DB2INST1"...

  'db2sampl' processing complete.

[db2inst1@9d114304c67f ~]$ mkdir usertmp
[db2inst1@9d114304c67f ~]$ db2 connect to SAMPLE

   Database Connection Information

 Database server        = DB2/LINUXX8664 11.5.8.0
 SQL authorization ID   = DB2INST1
 Local database alias   = SAMPLE

[db2inst1@9d114304c67f ~]$ db2 "CREATE USER TEMPORARY TABLESPACE USRTMPSPACE PAGESIZE 8K MANAGED BY SYSTEM USING('usertmp') EXTENTSIZE 32;"
DB20000I  The SQL command completed successfully.
[db2inst1@9d114304c67f ~]$ db2 disconnect SAMPLE
DB20000I  The SQL DISCONNECT command completed successfully.
```

### Creating Docker images with R, odbc and DB2 CLI driver
```
make ODBC_VERSION=1.5.0 build
make ODBC_VERSION=1.6.0 build
```
These will create the images odbcdb2:11.5.8-1.5.0 and odbcdb2:11.5.8-1.6.0, respectively.

### Executing example code

#### odbc 1.5.0
```
$ docker run -it --network dbnet -v $(pwd):/data --rm odbcdb2:11.5.8-1.5.0 Rscript /data/check_table.R
[1] -1
[1] 2
  ID  NAME
1  1 Alice
2  2   Bob
[1] TRUE
[1] FALSE
[1] FALSE
```

#### odbc 1.6.0
```
$ docker run -it --network dbnet -v $(pwd):/data --rm odbcdb2:11.5.8-1.6.0 Rscript /data/check_table.R
[1] -1
[1] 2
  ID  NAME
1  1 Alice
2  2   Bob
[1] TRUE
[1] TRUE
Error in `$<-.data.frame`(`*tmp*`, table_remarks, value = NA_character_) : 
  replacement has 1 row, data has 0
Calls: print ... tryCatchList -> tryCatchOne -> doTryCatch -> $<- -> $<-.data.frame
Execution halted
```
