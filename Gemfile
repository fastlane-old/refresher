source 'https://rubygems.org'
ruby "2.3.0"

gem 'chart-js-rails' # nice HTML5 graphs
gem 'coffee-rails', '~> 4.1.0'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'rack-cors' # handling JSON AJAX requests
gem 'rails', '5.0.1'
gem 'sass-rails', '~> 5.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'
gem 'maxminddb', '~> 0.1.11'
gem 'react-rails', '~> 1.10'

group :development do
  gem 'puma'
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'sqlite3'
end

group :production do
  gem 'pg' # Heroku
  gem 'rails_12factor' # Heroku (http://stackoverflow.com/questions/18324063/rails-4-images-not-loading-on-heroku)
end
