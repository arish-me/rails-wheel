require_relative "lib/public_site/version"

Gem::Specification.new do |spec|
  spec.name        = "public_site"
  spec.version     = PublicSite::VERSION
  spec.authors     = [ "Arish" ]
  spec.email       = [ "thermic.arish@gmail.com" ]
  spec.homepage    = "http://mygemserver.com"
  spec.summary     = " Summary of PublicSite."
  spec.description = " Description of PublicSite."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = 'http://mygemserver.com'

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.1"
  spec.add_dependency "liquid"
end
