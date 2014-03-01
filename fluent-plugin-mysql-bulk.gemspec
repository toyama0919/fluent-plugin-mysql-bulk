# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-mysql-bulk"
  gem.version       = "0.0.5"
  gem.authors       = ["Hiroshi Toyama"]
  gem.email         = ["toyama0919@gmail.com"]
  gem.description   = %q{fluent plugin mysql bulk insert is high performance and on duplicate key update respond.}
  gem.summary       = %q{fluent plugin mysql bulk insert is high performance and on duplicate key update respond.}
  gem.homepage      = "https://github.com/toyama0919/fluent-plugin-mysql-bulk"
  gem.licenses    = ["MIT"]
  gem.has_rdoc    = false

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "mysql2-cs-bind"
  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "spork"
  gem.add_development_dependency "pry"

end
