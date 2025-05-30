# frozen_string_literal: true

require_relative "lib/rubocop/packaging/version"

Gem::Specification.new do |spec|
  spec.name          = "rubocop-packaging"
  spec.version       = RuboCop::Packaging::VERSION
  spec.authors       = ["Utkarsh Gupta"]
  spec.email         = ["utkarsh@debian.org"]
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/utkarsh2102/rubocop-packaging"
  spec.summary       = "Automatic downstream compatibility checking tool for Ruby code"
  spec.description   = <<~DESCRIPTION
    A collection of RuboCop cops to check for downstream compatibility issues in the
    Ruby code.
  DESCRIPTION

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/utkarsh2102/rubocop-packaging"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files         = Dir["config/default.yml", "lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["default_lint_roller_plugin"] = "RuboCop::Packaging::Plugin"

  spec.add_dependency "lint_roller", "~> 1.1.0"
  spec.add_dependency "rubocop", ">= 1.72.1", "< 2.0"

  spec.add_development_dependency "bump", "~> 0.8"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.9"
end
