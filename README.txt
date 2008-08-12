= multipart-post

* http://svn.caldersphere.net/svn/main/multipart-post

== DESCRIPTION:

Adds a multipart form post capability to Net::HTTP.

== FEATURES/PROBLEMS:

I wrote this a while ago and never ended up using it. It appears to work,
but I don't know for sure. If you find any bugs or improvements, please 
let me know!

== SYNOPSIS:

    require 'net/http/post/multipart'

    url = URI.parse('http://www.example.com/upload')
    File.open("./image.jpg") do |jpg|
      req = Net::HTTP::Post::Multipart.new(url.path, {
        "file" => UploadIO.convert!(jpg, "image/jpeg", "image.jpg", "./image.jpg")})
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    end

== REQUIREMENTS:

None

== INSTALL:


== LICENSE:

(The MIT License)

Copyright (c) 2007-2008 Nick Sieger <nick@nicksieger.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
