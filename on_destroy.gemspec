# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "on_destroy/version" 

Gem::Specification.new do |s|
  s.name        = 'on_destroy'
  s.version     = OnDestroy::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/garysweaver/on_destroy'
  s.summary     = %q{Change destroy's behavior.}
  s.description = %q{Change ActiveModel's destroy behavior.}
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
  s.add_dependency 'activerecord'
end
