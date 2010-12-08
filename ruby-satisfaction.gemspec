# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-satisfaction}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Fleckenstein", "Josh Nichols", "Pius Uzamere", "Josh King", "Jen-Mei Wu"]
  s.date = %q{2010-12-07}
  s.description = %q{Ruby interface to Get Satisfaction}
  s.email = %q{nerds+rubygems@getsatisfaction.com}
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    ".gitignore",
    "CONTRIBUTORS.txt",
    "Gemfile",
    "init.rb",
    "License.txt",
    "Rakefile",
    "README.markdown",
    "ruby-satisfaction.gemspec",
    "VERSION.yml",
    "lib/satisfaction.rb",
    "lib/satisfaction/associations.rb",
    "lib/satisfaction/cache",
    "lib/satisfaction/cache/hash.rb",
    "lib/satisfaction/cache/memcache.rb",
    "lib/satisfaction/company.rb",
    "lib/satisfaction/external_dependencies.rb",
    "lib/satisfaction/has_satisfaction.rb",
    "lib/satisfaction/identity_map.rb",
    "lib/satisfaction/loader.rb",
    "lib/satisfaction/person.rb",
    "lib/satisfaction/product.rb",
    "lib/satisfaction/reply.rb",
    "lib/satisfaction/resource",
    "lib/satisfaction/resource/attributes.rb",
    "lib/satisfaction/resource.rb",
    "lib/satisfaction/tag.rb",
    "lib/satisfaction/topic.rb",
    "lib/satisfaction/util.rb",
    "spec/satisfaction_spec.rb",
    "spec/spec_helper.rb",
    "spec/satisfaction/identity_map_spec.rb",
    "spec/satisfaction/loader_spec.rb"
  ]
  s.homepage = %q{https://github.com/satisfaction/ruby-satisfaction}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{satisfaction}
  s.summary = %q{Ruby interface to Get Satisfaction}
  s.test_files = [
    "spec/satisfaction_spec.rb",
    "spec/spec_helper.rb",
    "spec/satisfaction/identity_map_spec.rb",
    "spec/satisfaction/loader_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<memcache-client>, [">= 1.5.0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0.3.5"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 2.3"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.2"])
    else
      s.add_dependency(%q<memcache-client>, [">= 1.5.0"])
      s.add_dependency(%q<oauth>, [">= 0.3.5"])
      s.add_dependency(%q<activesupport>, ["~> 2.3"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.2"])
    end
  else
    s.add_dependency(%q<memcache-client>, [">= 1.5.0"])
    s.add_dependency(%q<oauth>, [">= 0.3.5"])
    s.add_dependency(%q<activesupport>, ["~> 2.3"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.2"])
  end
end
