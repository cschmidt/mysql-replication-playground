# Simulating Replication Deadlocks
Sometimes it's useful to simulate a deadlock scenario in your
replication configuration.  This can be a little tricky, as the classic
deadlock scenario requires lock ordering that's difficult to achieve when
the replication slave is playing back the transaction all at once.  This
problem is addressed below by the use of
[MySQL's sleep()](http://dev.mysql.com/doc/refman/5.5/en/miscellaneous-functions.html#function_sleep)
function.

## Setup

on db1:

    create database if not exists repl_test;
    use repl_test;
    drop table if exists stuff;
    create table stuff
      (id int, description varchar(20), primary key(id))
      engine = InnoDB;
    insert into stuff values (1, 'inserted by db1');
    insert into stuff values (2, 'inserted by db1');

on db2:

    set global slave_transaction_retries = 0;


## Create the Deadlock Condition

on db2:

    use repl_test;

    set autocommit=off;
    start transaction;
    update stuff set description = 'updated by db2' where id = 1;


on db1 (note that this will sleep for 10 seconds, during which time you:

    use repl_test;
    set autocommit=off;

    start transaction;
    update stuff set description = 'updated by db1' + sleep(10) where id = 2;
    update stuff set description = 'updated by db1' where id = 1;
    commit;


on db2:

    update stuff set description = 'updated by db2' where id = 2;
    show slave status\G
