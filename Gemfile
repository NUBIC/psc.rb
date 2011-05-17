source "http://rubygems.org/"

gemspec

group :development do
  # For yard's markdown support
  platforms :jruby do
    gem 'maruku'
  end

  platforms :ruby_18, :ruby_19 do
    gem 'rdiscount'
  end

  # To prevent jruby problems in development
  platforms :jruby do
    gem 'jruby-openssl' # when using webmock
    gem 'ffi-ncurses'   # when loading highline
  end
end
