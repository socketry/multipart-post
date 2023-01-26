# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

source "https://rubygems.org"

gemspec

gem "bake"

if RUBY_VERSION >= "2.7.0"
	group :maintenance, optional: true do
		gem "bake-gem"
		gem "bake-modernize"
	end
end

group :test do
	gem "bake-test"
	gem "bake-test-external"
end
