Gem::Specification.new do |s|
  s.name = "bort"
  s.version = "0.0.1"
  s.date = "2011-05-27"

  s.authors = ["hc5duke"]
  s.email = "hc5duke@gmail.com"

  s.summary = "BART API ruby wrapper."
  s.homepage = "https://github.com/hc5duke/bort"
  s.description = "Bort makes BART API available in ruby."

  s.require_path = "lib"
  s.files = Dir["lib/**/*.rb"]
  s.add_dependency "hpricot"
end
