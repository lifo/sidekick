ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /SHOW FIELDS/]

  def execute_with_query_record(sql, name = nil, &block)
    $queries_executed ||= []
    $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
    execute_without_query_record(sql, name, &block)
  end

  alias_method_chain :execute, :query_record
end

# Oracle specific ignored SQLs
ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SELECT_SQL = [/^select .*nextval/i, /^SAVEPOINT/, /^ROLLBACK TO/, /^\s*select .* from ((all|user)_tab_columns|(all|user)_triggers|(all|user)_constraints)/im]

  def select_with_query_record(sql, name = nil)
    $queries_executed ||= []
    $queries_executed << sql unless IGNORED_SELECT_SQL.any? { |r| sql =~ r }
    select_without_query_record(sql, name)
  end

  alias_method_chain :select, :query_record
end if ENV['ARCONN'] == 'oracle'

ActiveRecord::Base.connection.class.class_eval {
  attr_accessor :column_calls, :column_calls_by_table

  def columns_with_calls(*args)
    @column_calls ||= 0
    @column_calls_by_table ||= Hash.new {|h,table| h[table] = 0}

    @column_calls += 1
    @column_calls_by_table[args.first.to_s] += 1
    columns_without_calls(*args)
  end

  alias_method_chain :columns, :calls
}
