# rails-flog

[![Build Status](https://secure.travis-ci.org/pinzolo/rails-flog.png)](http://travis-ci.org/pinzolo/rails-flog)
[![Coverage Status](https://coveralls.io/repos/pinzolo/rails-flog/badge.png)](https://coveralls.io/r/pinzolo/rails-flog)

rails-flog provides feature that formats parameters Hash and SQL in Rails log file.

## Before and after (Using Redmine)

### Before

```
# Parameters
Processing by IssuesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"VYCWAsE+aAN+zSZq2H3ONNqaU8rlyfbnXLfbwDY1i10=", "issue"=>{"is_private"=>"0", "tracker_id"=>"1", "subject"=>"test ticket", "description"=>"test ticket description", "status_id"=>"1", "priority_id"=>"2", "assigned_to_id"=>"1", "parent_issue_id"=>"", "start_date"=>"2013-11-28", "due_date"=>"2013-11-29", "estimated_hours"=>"5", "done_ratio"=>"10"}, "commit"=>"Create", "project_id"=>"test"}
  
# SQL
  IssueCustomField Load (0.0ms)  SELECT "custom_fields".* FROM "custom_fields" WHERE "custom_fields"."type" IN ('IssueCustomField') AND (is_for_all = 't' OR id IN (SELECT DISTINCT cfp.custom_field_id FROM custom_fields_projects cfp WHERE cfp.project_id = 1)) ORDER BY custom_fields.position ASC
```

### After

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

- [awesome_print](https://github.com/michaeldv/awesome_print) : Use format Hash
- [anbt-sql-formatter](https://github.com/sonota/anbt-sql-formatter) : Use format SQL
- [yuroyoro](http://yuroyoro.hatenablog.com/entry/2013/04/12/141648) : Inspired
