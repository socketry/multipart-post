# frozen_string_literal: true

require_relative "lib/multipart/post/version"

Gem::Specification.new do |spec|
	spec.name = "multipart-post"
	spec.version = Multipart::Post::VERSION
	
	spec.summary = "A multipart form post accessory for Net::HTTP."
	spec.authors = ["Nick Sieger", "Samuel Williams", "Olle Jonsson", "McClain Looney", "Lewis Cowles", "Gustav Ernberg", "Patrick Davey", "Steven Davidovitz", "Alex Koppel", "Ethan Turkeltaub", "Jagtesh Chadha", "Jason York", "Nick", "VincWebwag", "hasimo", "hexfet", "Christine Yen", "David Moles", "Eric Hutzelman", "Feuda Nan", "Gerrit Riessen", "Jan Piotrowski", "Jan-Joost Spanjers", "Jason Moore", "Jeff Hodges", "Johannes Wagener", "Jordi Massaguer Pla", "Lachlan Priest", "Leo Cassarani", "Lonre Wang", "Luke Redpath", "Matt Colyer", "Mislav Marohnić", "Socrates Vicente", "Steffen Grunwald", "Tim Barkley"]
	spec.license = "MIT"

	spec.required_ruby_version = ">= 2.6.0"

	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/multipart-post"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec", "~> 3.4"
end
