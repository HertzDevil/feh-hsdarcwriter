
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "feh/hsdarc_writer/version"

Gem::Specification.new do |spec|
  spec.name          = "feh-hsdarcwriter"
  spec.version       = Feh::HSDArcWriter::VERSION
  spec.authors       = ["Quinton Miller"]
  spec.email         = ["nicetas.c@gmail.com"]

  spec.summary       = "HSDArc file builder for Fire Emblem Heroes"
  spec.description   = "Builder interface for the HSDArc file format used in Fire Emblem Heroes."
  spec.homepage      = "https://github.com/HertzDevil/feh-hsdarcwriter"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
