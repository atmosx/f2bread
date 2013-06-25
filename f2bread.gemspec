Gem::Specification.new do |s|
  s.name        = 'f2bread'
  s.version     = '0.0.1'
  s.executables << 'f2bread'
  s.date        = '2013-06-28'
  s.summary     = "Fail2ban statistics"
  s.description = "A simple gem that reads 'fail2ban.log' and displays statistics"
  s.authors     = ["Panagiotis Atmatzidis"]
  s.email       = 'atma@convalesco.org'
  s.files       = ["bin/f2bread"]
  s.homepage    = 'https://github.com/atmosx/f2bread'
  s.add_dependency "geoip", "1.2.1"
  s.add_dependency "time_diff", "0.3.0"
end
