# MySQL Replication Playground
Welcome to the MySQL Replication Playground, a Vagrant-powered mini-project
that lets you run multiple VMs in various MySQL replication configurations.

This is just getting started (plus I'm new to Vagrant and Chef), so things are
not yet complete.  Currently only a simple master-slave is supported, and you
still have to configure the slave manually (details below).  The goal is to
eventually fully automate the  configuration of various MySQL replication
scenarios, such as multi-master round robin in addition to the classic
master-slave setup.

## Firing things up
You should have the following already installed:

 - git
 - rvm (with a Ruby 1.9.3)
 - VirtualBox

If you have rvm all set up, then just:

    $ git clone git@github.com:cschmidt/mysql-replication-playground.git
    $ cd mysql-replication-playground

If you accept the .rvmrc, that'll do a ```bundle install```, after which you
can:

    $ vagrant up

This will download the necessary base boxes, launch two VMs (db1 and db2), and
install MySQL.  You can access each one with:

    $ vagrant ssh db1
    $ vagrant ssh db2

## Configuring the slave (for now)
Until I get replication configuration fully automated, you'll have to manually
configure the slave:

1.  ```$ vagrant ssh db2```

2.  Configure and start the slave:

        vagrant@db2:~$ mysql -u root
        db2 mysql> change master to
        master_host = '192.168.2.11',
        master_user = 'repl',
        master_password = 'repl_pw',
        master_port=3306;
        db2 mysql> start slave;

That wasn't so hard, now, was it?

## Handy shell snippets

See if the slave is running:

    mysql -u root -e 'show slave status\G' |grep 'Slave_SQL_Running'
