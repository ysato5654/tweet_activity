require_relative 'lib/tweet_activity/version'

Gem::Specification.new do |spec|
  spec.name          = 'tweet_activity'
  spec.version       = TweetActivity::VERSION
  spec.authors       = ['Yuya Sato']
  spec.email         = ['ysato.5654@gmail.com']

  spec.summary       = %q{tweet activity}
  spec.description   = %q{tweet activity}
  spec.homepage      = 'https://github.com/ysato5654/tweet_activity'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ysato5654/tweet_activity'
  spec.metadata['changelog_uri'] = 'https://github.com/ysato5654/tweet_activity/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 5.2.2'
  spec.add_dependency 'sqlite3', '~> 1.3'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
