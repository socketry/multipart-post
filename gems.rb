source "https://rubygems.org"

gemspec

gem "bake"

if RUBY_VERSION >= "2.7.0"
	group :maintenance, optional: true do
		gem "bake-gem"
		gem "bake-modernize"
	end
end
