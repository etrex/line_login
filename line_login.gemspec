
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "line_login/version"

Gem::Specification.new do |spec|
  spec.name          = "line_login"
  spec.version       = LineLogin::VERSION
  spec.authors       = ["etrex kuo"]
  spec.email         = ["et284vu065k3@gmail.com"]

  spec.summary       = "Line Login 2.1 Client"
  spec.description   = "Line Login 2.1 Client for Ruby"
  spec.homepage      = "https://github.com/etrex/line_login"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "webmock"
  spec.add_runtime_dependency "json"
end
