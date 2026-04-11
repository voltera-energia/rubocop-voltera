# RuboCop Voltera

Custom [RuboCop](https://rubocop.org) cops for Voltera projects.

## Installation

Add this to your `Gemfile`:

```ruby
gem 'rubocop-voltera', github: 'voltera-energia/rubocop-voltera', require: false
```

Then run `bundle install`.

## Usage

### RuboCop configuration file

Add the following to your `.rubocop.yml`:

```yaml
plugins:
  - rubocop-voltera
```

## The Cops

All cops are located under [`lib/rubocop/cop/voltera`](lib/rubocop/cop/voltera) and are enabled by default.

### Voltera/ScopePluralNaming

Ensures that `by_*` scopes whose arguments are plural-compatible (i.e., work with both single values and arrays) use plural names. Rails handles both single values and arrays transparently in `where` hash conditions, so these scopes should signal that with a plural name.

```ruby
# bad
scope :by_company_id, ->(company_id) { where(company_id: company_id) }

# good
scope :by_company_ids, ->(company_ids) { where(company_id: company_ids) }

# good - singular name is correct for ILIKE scopes
scope :by_name_segment, ->(segment) { where('name ilike ?', "%#{segment}%") }
```

You can disable it in your `.rubocop.yml` if needed:

```yaml
Voltera/ScopePluralNaming:
  Enabled: false
```

## Contributing

1. Create a branch
2. Add or modify cops under `lib/rubocop/cop/voltera/`
3. Add specs under `spec/rubocop/cop/voltera/`
4. Make sure `bundle exec rubocop` and `bundle exec rspec` pass
5. Open a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
