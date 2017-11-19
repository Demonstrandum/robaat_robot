require_relative 'lib/robaat_robot'

Gem::Specification.new do |s|
  s.name        = 'robaat_robot'
  s.version     = Robåt::version
  s.required_ruby_version = '>= 2.0.0'
  s.executables << 'robaat-robot'
  s.date        = Time.now.to_s.split(/\s/)[0]
  s.summary     = "A Norwegian Telegram Bot"
  s.description = "Simple, Norwegian, Rowboat enthusiast Robot."
  s.authors     = ["Demonstrandum"]
  s.email       = 'knutsen@jetspace.co'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.require_path= 'lib'
  s.add_dependency 'telegram-bot-ruby', '~> 0.8', '>=0.8.5'
  s.add_dependency 'whenever', '~> 0'
  s.homepage    = 'https://github.com/Demonstrandum/robaat_robot'
  s.license     = 'GPL-3.0'
end
