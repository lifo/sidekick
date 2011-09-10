Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'sidekick'
  s.version = '3.0.1'
  s.summary = 'Lazy preloading for Active Record.'
  s.description = 'Sidekick provides lazy preloading for Active Record.'

  s.author = 'Pratik Naik'
  s.email = 'pratiknaik@gmail.com'
  s.homepage = 'http://m.onkey.org'

  s.add_dependency('activerecord', '~> 3.0.9')

  s.files = Dir['README', 'MIT-LICENSE', 'lib/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'
end
