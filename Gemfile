# Gemfile
source "https://rubygems.org"

ruby "3.1.4" # or your Ruby version

gem "rails", "~> 7.1.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "bootsnap", ">= 1.4.4", require: false
gem "rack-cors"

# GraphQL
gem "graphql", "~> 2.0"

# HTTP client for API calls
gem "httparty"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring"
  gem "graphiql-rails" # GraphQL IDE for development
end

group :test do
  gem "shoulda-matchers", "~> 5.0"
  gem "database_cleaner-active_record"
  gem "vcr"
  gem "webmock"
end