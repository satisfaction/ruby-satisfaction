# -*- encoding: utf-8 -*-
require File.expand_path("../lib/satisfaction/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ruby-satisfaction"
  s.version     = GemSatisfaction::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.author     = 'Get Satisfaction'
  s.email       = ["nerds+rubygems@getsatisfaction.com"]
  s.homepage    = "https://github.com/satisfaction/ruby-satisfaction"
  s.summary     = "Get Satisfaction ruby client"
  s.description = "Ruby client for using Get Satisfaction's RESTful API. Get Satisfaction is a simple way to build online communities that enable productive conversations between companies and their customers. More than 46,000 companies use Get Satisfaction to provide a more social support experience, build better products, increase SEO and improve customer loyalty. Get Satisfaction communities are available at http://getsatisfaction.com."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "ruby-satisfaction"

  s.add_dependency 'nokogiri', '>= 1.4.2'
  s.add_dependency 'json', '>= 1.7.3'
  s.add_dependency 'activesupport'
  s.add_dependency 'memcache-client', '>= 1.5.0'
  s.add_dependency 'oauth', '>= 0.3.5'

  s.add_development_dependency "bundler", ">= 1.1.4"
  s.add_development_dependency "gemcutter", ">= 0.6.1"
  s.add_development_dependency "rspec", "~> 2.11"
  s.add_development_dependency "fakeweb", "~> 1.3"
  s.add_development_dependency "open_gem", ">= 1.4"
  s.add_development_dependency "rr", '1.0.4'

  s.extra_rdoc_files = [ "README.markdown" ]
  s.files        = `git ls-files`.split("\n") - ['.rvmrc', '.gitignore']
  s.test_files = `git ls-files`.split("\n").grep(/^spec/)
  s.require_path = 'lib'
end

