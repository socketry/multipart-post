# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Tohru Hashimoto.
# Copyright, 2011-2013, by Nick Sieger.
# Copyright, 2017-2024, by Samuel Williams.

source "https://rubygems.org"

gemspec

gem "bake"

if RUBY_VERSION >= "2.7.0"
	group :maintenance, optional: true do
		gem "bake-gem"
		gem "bake-modernize"
		
		gem "utopia-project"
	end
end

group :test do
	gem "covered"
	gem "rspec", "~> 3.4"
	
	gem "bake-test"
	gem "bake-test-external"
end
