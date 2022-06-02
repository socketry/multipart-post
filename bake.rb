# frozen_string_literal: true

def external
	require 'bundler'
	
	Bundler.with_unbundled_env do
		clone_and_test("faraday-multipart", "https://github.com/lostisland/faraday-multipart.git")
		clone_and_test("jira-ruby", "https://github.com/sumoheavy/jira-ruby.git")
		clone_and_test("zendesk_api", "https://github.com/zendesk/zendesk_api_client_rb.git")
	end
end

private

def clone_and_test(name, remote)
	require 'fileutils'
	
	path = "external/#{name}"
	FileUtils.rm_rf path
	FileUtils.mkdir_p path
	
	system("git clone #{remote} #{path}")
	
	# I tried using `bundle config --local local.async ../` but it simply doesn't work.
	# system("bundle", "config", "--local", "local.async", __dir__, chdir: path)
	
	gemfile_paths = ["#{path}/Gemfile", "#{path}/gems.rb"]
	gemfile_path = gemfile_paths.find{|path| File.exist?(path)}
	
	File.open(gemfile_path, "a") do |file| 
		file.puts('gem "multipart-post", path: "../../"')
	end
	
	system("cd #{path} && bundle install && bundle exec rspec") or abort("Tests failed!")
end
