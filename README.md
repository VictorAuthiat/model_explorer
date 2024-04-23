# ModelExplorer

Rails gem to explore models attributes and their associations.

![Example](docs/example.png)

Most of the time, the production database is not accessible, which makes debugging difficult. This gem gives you read access to the database by searching for a record and its associations.
You can also copy the result of a search and import it to test behavior from another test db.

It is highly recommended to use the basic auth feature to protect access to the search form.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add model_explorer

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install model_explorer

## Usage

Add the following line to the `config/routes.rb` file:

```ruby
mount ModelExplorer::Engine => "/model_explorer"
```

### Basic Auth

To protect access to the search form, you can use the basic auth feature.

Add an initializer file `config/initializers/model_explorer.rb` with the following content:

```ruby
ModelExplorer.configure do |config|
  config.basic_auth_enabled = true
  config.basic_auth_username = "admin"
  config.basic_auth_password = "password"
end
```

The basic auth feature is disabled by default.

### Custom Access Control

You can also define a custom access control to restrict access to the search form.

Add an initializer file `config/initializers/model_explorer.rb` with the following content:

```ruby
ModelExplorer.configure do |config|
  config.verify_access_proc = ->(_controller) do
    current_admin_user&.super_admin?
  end
end
```

The `verify_access_proc` is a lambda that receives the controller instance and returns a boolean value.

## Filter attributes

You can filter sensitive attributes as follows:

```ruby
ModelExplorer.configure do |config|
  config.filter_attributes_regexp = /api_key|api_secret/i
end
```

By default, the `filter_attributes_regexp` is set to `/password|secret/token/i`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/model_explorer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/model_explorer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ModelExplorer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/model_explorer/blob/master/CODE_OF_CONDUCT.md).
