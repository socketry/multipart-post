begin
require 'rubygems'
require 'hoe'

require 'lib/multipart_post'

hoe = Hoe.new("multipart-post", MultipartPost::VERSION) do |p|
  p.rubyforge_name = "caldersphere"
  p.author = "Nick Sieger"
  p.url = "http://github.com/nicksieger/multipart-post"
  p.email = "nick@nicksieger.com"
  p.description = "Use with Net::HTTP to do multipart form posts.  IO values that have #content_type, #original_filename, and #local_path will be posted as a binary file."
  p.summary = "Creates a multipart form post accessory for Net::HTTP."
end

task :gemspec do
  File.open("#{hoe.name}.gemspec", "w") {|f| f << hoe.spec.to_ruby }
end
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end
