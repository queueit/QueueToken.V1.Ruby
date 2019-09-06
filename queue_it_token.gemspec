# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'queue_it_token/version'

Gem::Specification.new do |spec|
  spec.name          = 'queue_it.queue_token.v1'
  spec.version       = QueueItToken::VERSION
  spec.authors       = ['QoQa services SA', 'Queue-it']
  spec.email         = ['dev@qoqa.com']

  spec.summary       = 'Gem for implementing QueueIt Token V1'
  spec.homepage      = 'https://queue-it.com/'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']
end
