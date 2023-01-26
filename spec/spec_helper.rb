# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2022, by Samuel Williams.
# Copyright, 2019, by Patrick Davey.

require "bundler/setup"
require "covered/rspec"

MULTIBYTE = File.join(__dir__, 'fixtures/multibyte.txt')
TEMP_FILE = "temp.txt"

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
