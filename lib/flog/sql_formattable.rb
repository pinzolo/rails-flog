# coding: utf-8
require "active_record/log_subscriber"

class ActiveRecord::LogSubscriber
  alias :original_sql :sql

  def sql(event)
    raw_sql = event.payload[:sql]
    begin
      event.payload[:sql] = "\n\t#{format_sql(raw_sql)}" if raw_sql.present?
      original_sql(event)
    ensure
      # restore
      event.payload[:sql] = raw_sql
    end
  end

  private
  def format_sql(sql)
    require "anbt-sql-formatter/formatter"
    rule = AnbtSql::Rule.new
    rule.keyword = AnbtSql::Rule::KEYWORD_UPPER_CASE
    %w(count sum).each do |function_name|
      rule.function_names << function_name
    end
    rule.indent_string = "\t"
    AnbtSql::Formatter.new(rule).format(sql.squeeze(" "))
  end
end
