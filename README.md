# Carbonado

Carbonado is a gem that allows you to require installed gems, even if they are not specified in your Gemfile. This means that you can optionally include other gems if they are already installed, even if your gem just provides an executable. 

Carbonado is named after an impure form of diamond, as it is an impure way to load gems at runtime.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carbonado'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install runtime_gem_activator

## Usage

You can either include the `Carbonado` module, or alternatively call the methods directly on the module. There are two methods you can use, `activate_gem` and `stub_gem_method`. The `activate_gem` method is used to activate a locally installed gem. You can also provide a version requirement. This will raise a `Carbonado::Error` if it fails to activate the gem. Once the gem is activated, you can `require` it as normal.

    # Module method
    Carbonado.activate_gem("nokogiri", "~> 1.6.0")

    # Include the module
    class MyClass
      include Carbonado
      def activate_optional_component
        begin
          activate_gem("activerecord", "> 1.0.0")
          require("active_record")
          puts "ActiveRecord module initialized successfully"
        rescue Carbonado::Error, Gem::LoadError
          puts "Can't activate ActiveRecord module"
        end
      end
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/slicedpan/carbonado. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuntimeGemActivator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/slicedpan/carbonado/blob/master/CODE_OF_CONDUCT.md).
