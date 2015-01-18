$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "power_of_friendship/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "power_of_friendship"
  s.version     = PowerOfFriendship::VERSION
  s.authors     = ["miseralis"]
  s.email       = ["me@miseralis.com"]
  s.homepage    = "https://github.com/Miseralis/power_of_friendship"
  s.summary     = "Empower your models with the awesome power of friendship"
  s.description = "Power of Friendship is a friendship library for Rails' Active Records. It allows you to add Facebook style friendships and/or Twitter style followers to any model."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.7"
  s.add_dependency "squeel"

  s.add_development_dependency "pg"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails', '4.2.0'
  s.add_dependency 'tzinfo-data'
  spec.required_ruby_version = '>= 1.9.3'
end
