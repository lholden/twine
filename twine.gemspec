# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'twine/version'

Gem::Specification.new do |s|
  s.name = "twine"
  s.version = Twine::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Lori Holden']
  s.email = ['email@loriholden.com']
  s.homepage = 'https://github.com/lholden/twine'
  s.summary = 'fork management made easy'
  s.description = 'Why thread when you have twine?'

  s.required_rubygems_version = ">= 1.3.6"
  #s.rubyforge_project = ""

  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 2.3.0"

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'
end

