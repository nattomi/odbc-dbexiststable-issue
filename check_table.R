library(DBI)
library(odbc)

conn <- dbConnect(odbc::odbc(), dsn = "SAMPLE")
dbExecute(conn, "DECLARE GLOBAL TEMPORARY TABLE SESSION.my_temp (id INT, name VARCHAR(100)) ON COMMIT PRESERVE ROWS")
dbExecute(conn, "INSERT INTO SESSION.MY_TEMP (id, name) VALUES (1, 'Alice'), (2, 'Bob')")
my_temp <- dbGetQuery(conn, "SELECT * FROM SESSION.MY_TEMP")

#   ID  NAME
# 1  1 Alice
# 2  2   Bob
print(my_temp)

# TRUE
dbExistsTable(conn, Id(schema = "DB2INST1", table = "EMPLOYEE")) |> print()

# FALSE (throws from 1.6.0)
dbExistsTable(conn, Id(schema = "SESSION", table = "MY_TEMP")) |> print()

# FALSE (throws from 1.6.0)
dbExistsTable(conn, "SESSION.MY_TEMP") |> print()

dbDisconnect(conn)
