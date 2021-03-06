# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'mp3gain'
  spec.version       = '1.0.2'
  spec.authors       = ['Christian Feier']
  spec.email         = ['christian.feier@gmail.com']

  spec.summary       = 'Simple wrapper for some common mp3gain console commands.'
  spec.description   = 'Takes mp3gain/aacgain binary path as an argument and offers methods to analyze and modify the'\
                       ' track/album gain of mp3 files.'
  spec.homepage      = 'https://github.com/cfe86/RubyMp3gain'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = 'https://github.com/cfe86/RubyMp3gain'
  spec.metadata['source_code_uri'] = 'https://github.com/cfe86/RubyMp3gain'
  spec.metadata['changelog_uri'] = 'https://github.com/cfe86/RubyMp3gain'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
