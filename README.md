# MySQL Replication Playground
Welcome to the MySQL Replication Playground, a Vagrant-powered mini-project
that lets you run multiple VMs in various MySQL replication configurations.

This is just getting started (plus I'm new to Vagrant and Chef), so the current
state of affairs just launches two VMs with stock MySQL installed.  You have
to configure replication manually at the moment.  The goal is to eventually
enable easy configuration of various MySQL replication scenarios such as your
classic Master-Slave and Multi-Master Round Robin.

## Firing things up
You should have the following already installed:

 - git
 - rvm (with a Ruby 1.9.3)
 - VirtualBox

If you have rvm all setup, then just:

    $ git clone 
    $ cd mysql-replication-playground

If you accept the .rvmrc, that'll do a ```bundle install```, after which you
can:

    $ vagrant up

This will download the necessary base boxes, launch two VMs (db1 and db2), and
install MySQL.  You can access each one with:

    $ vagrant ssh db1
    $ vagrant ssh db2

## Manually configuring replication (for now)
Until I get the replication recipes written, you'll have to configure 
replication manually.


### Configure db1 as master

1.  ```$ vagrant ssh db1```
2.  Edit /etc/mysql/my.cnf:

        [mysqld]
        bind-address = 0.0.0.0
        server-id = 1
        replicate-same-server-id = 0
        log-bin = db1-mysql-bin
        binlog-format = STATEMENT
        relay-log = db1-relay-bin
        relay-log-index = db1-relay-bin.index
        slave_exec_mode = IDEMPOTENT

3.  Create a replication user:

        vagrant@db1:~$ mysql -u root
        mysql> grant replication slave, replication client on *.*
        to 'repl'@'%'
        identified by 'repl_pw';

4.  Then restart MySQL:

        vagrant@db1:~$ sudo restart mysql


### Configure db2 as slave

1.  ```$ vagrant ssh db2```
2.  Edit /etc/mysql/my.cnf:

        [mysqld]
        server-id = 2

3.  Configure and start the slave:

        vagrant@db1:~$ mysql -u root
        mysql> change master to
        master_host = '192.168.2.11',
        master_user = 'repl',
        master_password = 'repl_pw',
        master_port=3306;
        mysql> start slave;


## Handy shell snippets

See if the slave is running:

    mysql -u root -e 'show slave status\G' |grep 'Slave_SQL_Running'


## To Do
There's lots left to do:
 - Chef recipes to configure replication
 - Chef recipes to setup a hosts file so you can use named hosts instead of
   IP addresses for inter-VM communication
 - customize the MySQL prompt with the hostname so you can more easily keep 
   track of where you are (via export MYSQL_PS1="#{host_name}> ")
