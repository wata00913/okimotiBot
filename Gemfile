# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

gem 'bootsnap', require: false
gem 'cssbundling-rails', '~> 1.2'
gem 'devise', '~> 4.9'
gem 'devise-i18n', '~> 1.11'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'kaminari'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.6'
gem 'slack-ruby-client'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rubocop-fjord', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
