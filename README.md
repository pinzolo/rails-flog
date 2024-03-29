# rails-flog

[![Build Status](https://secure.travis-ci.org/pinzolo/rails-flog.png)](http://travis-ci.org/pinzolo/rails-flog)
[![Coverage Status](https://coveralls.io/repos/pinzolo/rails-flog/badge.png)](https://coveralls.io/r/pinzolo/rails-flog)

rails-flog provides feature that formats parameters Hash and SQL in Rails log file.

## Before and after (Sample app: Redmine)

### Before (Default)

```
# Parameters
Processing by IssuesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"VYCWAsE+aAN+zSZq2H3ONNqaU8rlyfbnXLfbwDY1i10=", "issue"=>{"is_private"=>"0", "tracker_id"=>"1", "subject"=>"test ticket", "description"=>"test ticket description", "status_id"=>"1", "priority_id"=>"2", "assigned_to_id"=>"1", "parent_issue_id"=>"", "start_date"=>"2013-11-28", "due_date"=>"2013-11-29", "estimated_hours"=>"5", "done_ratio"=>"10"}, "commit"=>"Create", "project_id"=>"test"}

# SQL
  IssueCustomField Load (0.0ms)  SELECT "custom_fields".* FROM "custom_fields" WHERE "custom_fields"."type" IN ('IssueCustomField') AND (is_for_all = 't' OR id IN (SELECT DISTINCT cfp.custom_field_id FROM custom_fields_projects cfp WHERE cfp.project_id = 1)) ORDER BY custom_fields.position ASC
```

### After (Use rails-flog)

```
# Parameters
Processing by IssuesController#create as HTML
  Parameters:
{
                  "utf8" => "✓",
    "authenticity_token" => "VYCWAsE+aAN+zSZq2H3ONNqaU8rlyfbnXLfbwDY1i10=",
                 "issue" => {
             "is_private" => "0",
             "tracker_id" => "1",
                "subject" => "test ticket",
            "description" => "test ticket description",
              "status_id" => "1",
            "priority_id" => "2",
         "assigned_to_id" => "1",
        "parent_issue_id" => "",
             "start_date" => "2013-11-28",
               "due_date" => "2013-11-29",
        "estimated_hours" => "5",
             "done_ratio" => "10"
    },
                "commit" => "Create",
            "project_id" => "test"
}

# SQL
  IssueCustomField Load (0.0ms)
	SELECT
		"custom_fields" . *
	FROM
		"custom_fields"
	WHERE
		"custom_fields" . "type" IN ('IssueCustomField')
		AND (
			is_for_all = 't'
			OR id IN (
				SELECT
						DISTINCT cfp.custom_field_id
					FROM
						custom_fields_projects cfp
					WHERE
						cfp.project_id = 1
			)
		)
	ORDER BY
		custom_fields.position ASC
```

## Installation

Add this line to your application's Gemfile:
(Recommendation: use only `:development` and `:test` enviroment)

    gem 'rails-flog', :require => "flog"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-flog

## Usage

Just install.

## Configuration

Configure in your environment file (ex. `config/environments/development.rb`)

```ruby
Flog.configure do |config|
  # If this value is true, not format on cached query
  config.ignore_cached_query = false
  # If query duration is under this value, not format
  config.query_duration_threshold = 2.0
  # If key count of parameters is under this value, not format
  config.params_key_count_threshold = 2
  # If this value is true, nested Hash parameter is formatted coercively in any situation
  config.force_on_nested_params = false
  # If this value is true, not format query
  config.ignore_query = true
  # If this value is true, not format parameters
  config.ignore_params = true
end
```

### Default value

|Attribute                  |Data type |Default value |
|:--------------------------|:---------|:-------------|
|ignore_cached_query        |boolean   |true          |
|query_duration_threshold   |float     |0.0           |
|params_key_count_threshold |integer   |1             |
|force_on_nested_params     |boolean   |true          |
|ignore_query               |boolean   |false         |
|ignore_params              |boolean   |false         |

## Disable temporary

If you put a file to `<rails_app>/tmp` direcotry, `rails-flog` will disable format.
Priority of this feature is higher than configurations.

|File name          |Feature    |
|:------------------|:----------|
|no-flog-sql.txt    |SQL        |
|no-flog-params.txt |Parameters |
|no-flog.txt        |Both       |

## Supported versions

- Ruby: 2.3.x, 2.4.x, 2.5.x, 2.6.x, 3.0.x
- Rails: 5.1.x, 5.2.x, 6.0.x, 6.1.x, 7.0.x

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
