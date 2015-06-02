source 'https://rubygems.org'

#ruby '2.2.0', engine: 'jruby', engine_version: '9.0.0.0.pre1'

gem 'rails', '~> 4.2'
gem 'rake'

# VIEW stuff
gem 'haml-rails' # replaces ERB with HAML for markup
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'bootstrap-sass' # brings in Twitter Bootstrap as SASS
gem 'bootstrap_form' # nice bootstrapy forms
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', platform: [:ruby, :mingw, :mswin, :x64_mingw] # Use CoffeeScript for .coffee assets and views
gem 'therubyracer', platforms: :ruby
gem 'therubyrhino', platforms: :jruby

# JS Gems
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'jquery-ui-rails' # brings in jquery UI JavaScript
gem 'turbolinks' # Turbolinks makes following links in your web application faster.
gem 'jquery-turbolinks'  # fixes some binding with jquery and turbolinks
gem 'jquery-datatables-rails' # provides jquery datatables JS
gem 'ajax-datatables-rails' # provides ajax server side interaction with jquery datatables
gem 'momentjs-rails' # provides local time formatted JS strings
gem 'html5shiv-js-rails' # provides HTML5 containers for <IE10
gem 'respond-js-rails' # provides CSS3 for <IE10
gem 'zeroclipboard-rails' # provides zeroclipboard SWF
gem 'bootstrap_tokenfield_rails' # provides bootstrap tokenfield

# MODEL/CONTROLLER stuff
gem 'devise'  # authentication/authorization
gem 'devise_ldap_authenticatable'  # LDAP integration with devise
gem 'bcrypt' # Use ActiveModel has_secure_password
gem 'kaminari' # provides pagination for DB fetches
gem 'jbuilder', '~> 2.0'  # Build JSON APIs with ease.
gem 'responders' # externalized in Rails 4.2 as an external Gem
gem 'activerecord-jdbc-adapter', platform: :jruby
gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby # XXX not needed in production
gem 'acts-as-taggable-on' # provides methods for tagging of models
gem 'sshkey' # reads/writes SSH keys in pure ruby

gem 'multi_json'
gem 'oj', platform: [:ruby, :mingw, :mswin, :x64_mingw] # fastest JSON serializer
gem 'oj_mimic_json', platform: [:ruby, :mingw, :mswin, :x64_mingw] # enables oj to mimic regular json methods
gem 'jrjackson', platform: :jruby
if defined? JRUBY_VERSION
  gem 'torquebox', '4.x.incremental.318', platform: :jruby, source: 'http://torquebox.org/4x/builds/gem-repo/' # J2EE compatible application server
end
#############################################################################################################

group :doc do
  gem 'sdoc', '~> 0.4.0'  # bundle exec rake doc:rails generates the API under doc/api.
end

gem 'mysql2' # Percona connection adatper
gem 'lograge' # cleans up rails logging and silences actions
# gem 'galera_cluster_migrations' # makes runnings db migrations against galera cluster atomic
gem 'dotenv-rails'

group :development, :test do
  gem 'sqlite3', platform: [:ruby, :mingw, :mswin, :x64_mingw]  # file base DB
  gem 'byebug', platform: [:ruby, :mingw, :mswin, :x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'guard'  # autorun tests after changes are made
  gem 'guard-minitest'  # integrates guard with minitest
  #gem 'guard-jruby-minitest', platform: :jruby
  gem 'better_errors', platforms: :ruby  # replaces standard rails error pages
  gem 'binding_of_caller', platforms: :ruby  # works with better_errors for deep call tracing
  gem 'railroady', platform: [:ruby, :mingw, :mswin, :x64_mingw] # generates UML for models/controllers
  gem 'web-console', '~> 2.0', platform: [:ruby, :mingw, :mswin, :x64_mingw] # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'wdm', platforms: [:mingw, :mswin, :x64_mingw] # reverts to windows FS polling for guard
  gem 'thin', platforms: [:mingw, :mswin, :x64_mingw]  # replacement for webrick
  gem 'puma', platform: :ruby # replacement for webrick on unix
  gem 'trinidad', platform: :jruby # replacement for webrick on jruby
  gem 'awesome_print' # provides 'ap' method for printing out deep structures in a clearer format
  gem 'factory_girl_rails' # provides replacement for fixtures
end

# deployment
group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', '= 0.0.2', require: false
  #gem 'torquebox-capistrano-support'
  #gem 'torquebox-rake-support'
end

group :test do
  # lint testing tools
  gem 'rubocop', require: false   # static code analyzer
  gem 'rubocop-checkstyle_formatter', '= 0.1.1', require: false # formats rubocop for Jenkins Violations report
  gem 'haml-lint', require: false # HAML analyzer
  # should also install brakeman separately from bundler because broken on win32
  gem 'brakeman', require: false, platform: [:ruby, :mingw, :mswin, :x64_mingw] # -> broken dependencies on win32
  gem 'simplecov' # coverage reporting
  gem 'simplecov-rcov' # coverage reportingin Rcov format
  gem "ci_reporter"  # for jenkins integration
  gem 'ci_reporter_minitest' # for jenkins integration with minitest
  gem 'ruby-prof', platform: [:ruby, :mingw, :mswin, :x64_mingw]  # adds performance testing for lazy loaded gems
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows has no Timezone info

gem 'fpm', platform: :ruby # used to create unix packages
gem 'cocaine' # gem for doing (command) lines
