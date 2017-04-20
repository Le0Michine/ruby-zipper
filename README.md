# Zipper

Utility intended to simplify zip packages creating.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zipbundler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zipbundler

## Usage

It is possible to run utility form console:

    zipbundler zip config.json

Configuration file `config.json` should has the following structure:

    {
        "name": "out.zip",
        "entries": [
            "path_to_file",
            "path_to_directory",            // real path in file system to file or directory
            {
                "type": "file",             // type of entry, if absent will be treated as 'file'
                "name": "test.json",        // real path in file system to file or directory
                "path": "new_path_in_zip"   // optional
            },
            {
                "type": "zip",              // nested zip archive
                "name": "test.zip",         // name of nested zip archive, can include directories. 'path' property is being ignored for this kind of entries
                "entries": [                // array of entries for nested zip file, same format as above
                    "file",
                    "dir"
                ],
                "ignoreEntries": [ ... ]    // local array of entries to ignore
            }
        ],
        "ignoreEntries": [
            ".DS_Store"
        ]
    }

Please refer [this link](https://github.com/Le0Michine/ruby-zipper/blob/master/config_schema.json) to find full json schema of the configuration.

Or you can do it from code `ZipFileGenerator`:

    require 'zipper'

    ...

    ZipFileGenerator.new(json_config).write

`json_config` is a hash variable which should have the same structure as json config file above.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Le0Michine/ruby-zipper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

