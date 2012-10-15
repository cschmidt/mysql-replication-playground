name "master"
description "master database role"
override_attributes :mysql => {
  :"bind_address" => "0.0.0.0",
  :tunable => {
    :log_bin => "db1-mysql-bin",
    :"binlog-format" => "STATEMENT",
    # Useful for multi-master setups (supposed to ignore duplicate key errors
    # amongst others).  See:
    # http://dev.mysql.com/doc/refman/5.1/en/replication-options-slave.html#sysvar_slave_exec_mode
    :slave_exec_mode => "IDEMPOTENT"
  }
}

