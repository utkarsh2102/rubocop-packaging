# RuboCop::Packaging

`RuboCop::Packaging` is an extension of [RuboCop](https://rubocop.org/),
which is a Ruby static code analyzer (a.k.a. linter) and code formatter.

It helps enforcing some of the guidelines that are expected of upstream
maintainers so that the downstream can build their packages in a clean
environment without any problems.  
Some of the other basic guidelines can be found
[here](https://wiki.debian.org/Teams/Ruby/RubyExtras/UpstreamDevelopers).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-packaging'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rubocop-packaging
```

## Usage

You need to tell RuboCop to load the Packaging extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml` file:

```yaml
require: rubocop-packaging
```

Alternatively, use the following array notation when specifying multiple
extensions:

```yaml
require:
  - rubocop-other-extension
  - rubocop-packaging
```

Now you can run `rubocop` and it will automatically load the RuboCop Packaging
cops together with the standard cops.

### Command line

```bash
rubocop --require rubocop-packaging
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-packaging'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

As always, bug reports and pull requests are heartily welcomed! 💖  
This project is intended to be a safe and welcoming space for collaboration.

## License
`rubocop-packaging` is available as open-source under the
[MIT License](https://github.com/utkarsh2102/rubocop-packaging/blob/master/LICENSE).
