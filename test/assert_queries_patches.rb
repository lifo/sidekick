module ActiveRecord
  class SQLCounter
    cattr_accessor :ignored_sql
    self.ignored_sql = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/, /^BEGIN/, /^COMMIT/]

    # FIXME: this needs to be refactored so specific database can add their own
    # ignored SQL.  This ignored SQL is for Oracle.
    ignored_sql.concat [/^select .*nextval/i, /^SAVEPOINT/, /^ROLLBACK TO/, /^\s*select .* from all_triggers/im]

    def initialize
      $queries_executed = []
    end

    def call(name, start, finish, message_id, values)
      sql = values[:sql]

      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      unless 'CACHE' == values[:name]
        $queries_executed << sql unless self.class.ignored_sql.any? { |r| sql =~ r }
      end
    end
  end
  ActiveSupport::Notifications.subscribe('sql.active_record', SQLCounter.new)
end
