# coding: utf-8
require "active_record/log_subscriber"
require "flog/payload_value_shuntable"

class ActiveRecord::LogSubscriber
  include Flog::PayloadValueShuntable

  def sql_with_flog(event)
    return sql_without_flog(event) unless Flog::Status.enabled?

    formatted = format_sql(event.payload[:sql])

    shunt_payload_value(event.payload, :sql, "\n\t#{formatted}") do
      sql_without_flog(event)
    end
  end
  alias_method_chain :sql, :flog

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
