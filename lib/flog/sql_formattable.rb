# coding: utf-8
require "active_record/log_subscriber"
require "flog/payload_value_shuntable"

class ActiveRecord::LogSubscriber
  include PayloadValueShuntable

  alias :original_sql :sql

  def sql(event)
    formatted = format_sql(event.payload[:sql])

    shunt_payload_value(event.payload, :sql, "\n\t#{formatted}") do
      original_sql(event)
    end
  end

  private
  def format_sql(sql)
    return sql if sql.blank?

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
