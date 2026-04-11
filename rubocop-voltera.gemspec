# frozen_string_literal: true

require_relative 'lib/rubocop/voltera/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-voltera'
  spec.version = RuboCop::Voltera::VERSION
  spec.authors = ['Wendel Scardua']
  spec.summary = 'Custom RuboCop cops for Voltera projects.'
  spec.homepage = 'https://github.com/voltera-energia/rubocop-voltera'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.files = Dir['lib/**/*', 'config/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.72.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['lint_roller_plugin'] = 'RuboCop::Voltera::Plugin'
end
