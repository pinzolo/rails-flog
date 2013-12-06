# rails-flog

[![Build Status](https://secure.travis-ci.org/pinzolo/rails-flog.png)](http://travis-ci.org/pinzolo/rails-flog)
[![Coverage Status](https://coveralls.io/repos/pinzolo/rails-flog/badge.png)](https://coveralls.io/r/pinzolo/rails-flog)

rails-flog provides feature that formats parameters Hash and SQL in Rails log file.

## Before and after (Sampla app: Redmine)

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

## Disable temporary

If you put a file named `no-flog.txt` to `<rails_app>/tmp` direcotry, `rails-flog` will disable format.

## Supported versions

- Ruby: 1.9.3, 2.0.0
- Rails: 3.2.x, 4.0.x

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Changelog

- v1.0.0  (2013-11-28 JST):  First release
- v1.1.0  (2013-12-02 JST):  Add feature that disables format by no-flog.txt
- v1.1.1  (2013-12-06 JST):  Change to alias_method_change from alias for method aliasing
