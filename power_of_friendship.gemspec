$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "power_of_friendship/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "power_of_friendship"
  s.version     = PowerOfFriendship::VERSION
  s.authors     = ["miseralis"]
  s.email       = ["miseralis@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of PowerOfFriendship."
  s.description = "TODO: Description of PowerOfFriendship."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.7"
  s.add_dependency "squeel"

  s.add_development_dependency "pg"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails', '4.2.0'
  s.add_dependency 'tzinfo-data'
end
